{
  lib,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  kver = "6.19.4";

  kPatch = (
    f: {
      name = "${f}";
      patch = f;
    }
  );

  patchList = (p: lib.filter (f: lib.hasSuffix ".patch" f.name) (lib.map kPatch p));

  sky1Patches = fetchFromGitHub {
    owner = "Sky1-Linux";
    repo = "linux-sky1";
    rev = "57e018a398248d7e5e4d798610df79a557c0629f";
    hash = "sha256-cPQdu9pTNsn3gAcX5kr8VxxLMorD8FQoDFu7t63Zo2A=";
  };

  args' = {
    version = "${kver}";
    pname = "linux-sky1";

    src = fetchFromGitHub {
      owner = "gregkh";
      repo = "linux";
      tag = "v${kver}";
      hash = "sha256-8Z3qxIUJAme3vY8KTmgZ5fZkqHytW6HVTx6pqGJsmRo=";
    };

    kernelPatches = patchList (lib.filesystem.listFilesRecursive "${sky1Patches}/patches-latest");
    structuredExtraConfig = {
      RUST_FW_LOADER_ABSTRACTIONS = lib.kernel.yes;
      CIX_CPU_IPA = lib.kernel.yes;
    };

    configfile = "${sky1Patches}/config/config.sky1-latest";

    isLTS = false;

    ignoreConfigErrors = true;
  }
  // (args.argsOverride or { });
in
buildLinux args'
