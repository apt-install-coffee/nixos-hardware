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
    structuredExtraConfig = with lib.kernel; {
      RUST_FW_LOADER_ABSTRACTIONS = yes;
      CIX_CPU_IPA = yes;

      NVMEM_SKY1 = yes;
      PWM_SKY1 = yes;
      SKY1_GPT_TIMER = yes;
      USB_CDNS_SUPPORT = yes;
      USB_CDNSP_SKY1 = yes;
      USB_CDNSP = yes;

      #PCIE_CADENCE = no;
      #PCI_SKY1 = no;

      CRYPTO_AEGIS128_SIMD = lib.mkForce yes;
      CRYPTO_CHACHA20POLY1305 = yes;
      CRYPTO_BLOWFISH = yes;
      CRYPTO_CRC32 = yes;
      CRYPTO_NHPOLY1305_NEON = yes;
      CRYPTO_LZ4HC = yes;
      CRYPTO_LZ4 = yes;
      KERNEL_MODE_NEON = yes;

    };

    configfile = "${sky1Patches}/config/config.sky1-latest";
    preferBuiltin = true;
    withRust = true;

    isLTS = false;

    ignoreConfigErrors = true;
  }
  // (args.argsOverride or { });
in
buildLinux args'
