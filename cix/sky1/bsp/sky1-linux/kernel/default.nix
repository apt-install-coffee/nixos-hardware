{
  lib,
  fetchpatch2,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  kver = "6.18.1";

  kPatch = (f: {
    name = "${f}";
    patch = f;
  });

  patchList = (p: lib.filter (f: lib.hasSuffix ".patch" f.name) (lib.map kPatch p));

  sky1Patches = fetchFromGitHub {
    owner = "Sky1-Linux";
    repo = "linux-sky1";
    tag = "v${kver}-1";
    hash = "sha256-u4UM23+mFJXc9GmooxDzcXEUFOG2XxFTrUEUzaPkjjk=";
  };

  args' =
    {
      version = "${kver}";
      pname = "linux-sky1";

      src = fetchFromGitHub {
        owner = "gregkh";
        repo = "linux";
        tag = "v${kver}";
        hash = "sha256-+8MBtrBKR78W5ShwUIIgCrw2P+lLMkLqoIkE0bIfn6M=";
      };

      kernelPatches = patchList (lib.filesystem.listFilesRecursive "${sky1Patches}/debian/patches");

      configfile = "${sky1Patches}/debian/config/arm64/config";

      isLTS = true;

      ignoreConfigErrors = true;
    }
    // (args.argsOverride or { });
in
buildLinux args'
