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
    rev = "870e5f4344a4872dc0e232d7e068df36b99e31b9";
    hash = "sha256-dl/gDXF7TuAxW+hjw+yOv5vSAsjTNHZAvp2Dwn5GwzY=";
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
