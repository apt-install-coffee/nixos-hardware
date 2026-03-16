{
  lib,
  fetchpatch2,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  kver = "6.18.2";

  kPatch = (f: {
    name = "${f}";
    patch = f;
  });

  patchList = (p: lib.filter (f: lib.hasSuffix ".patch" f.name) (lib.map kPatch p));

  sky1Patches = fetchFromGitHub {
    owner = "Sky1-Linux";
    repo = "linux-sky1";
    rev = "988766097769c17b16a62742fb9537a7b3a983c7";
    hash = "sha256-SXp2FXWYl2hEDOZ6bswaALqQBLWQVkT+gMbTpkULAx0=";
  };

  args' =
    {
      version = "${kver}";
      pname = "linux-sky1";

      src = fetchFromGitHub {
        owner = "gregkh";
        repo = "linux";
        tag = "v${kver}";
        hash = "sha256-cxRuaF1JFm1BWUTDsT55p8aFgp0TfCT6TbGHpObwEw8=";
      };

      kernelPatches = patchList (lib.filesystem.listFilesRecursive "${sky1Patches}/patches");
      structuredExtraConfig = {
        RUST_FW_LOADER_ABSTRACTIONS = lib.kernel.yes;
      };

      configfile = "${sky1Patches}/config/config.sky1";

      isLTS = true;
      buildDTBs = true;

      ignoreConfigErrors = true;
    }
    // (args.argsOverride or { });
in
buildLinux args'
