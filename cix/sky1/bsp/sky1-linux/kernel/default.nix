{
  lib,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  kver = "7.2";

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
    # branch: sky1-7.2 (rebased onto Linux v7.2)
    rev = "2766477b627081772d2131462801733d5da37921";
    hash = "sha256-fkp2wGglwncBpAfkjZT4Z9XPH6x2oGmd1aiBil8dux0=";
  };

  args' = {
    version = "${kver}";
    pname = "linux-sky1";

    src = fetchFromGitHub {
      owner = "gregkh";
      repo = "linux";
      tag = "v${kver}";
      hash = "sha256-GAjLGXXJiU42En31XWWx31IRT63G2pNsDN4ifNGtHis=";
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
