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

  # branch: sky1-7.2 (rebased onto Linux v7.2), hosted on the fork because
  # upstream Sky1-Linux does not carry the branch.
  sky1Patches = fetchFromGitHub {
    owner = "apt-install-coffee";
    repo = "linux-sky1";
    rev = "4805731a15d1b8ce66037978ce0c6345d0882020";
    hash = "sha256-iZ9540RglGXZP52a5Ot3TALdad7F8dJ3k2FIM4wEa00=";
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

      # The giant discrete-GPU drivers are irrelevant to the CIX Sky1
      # (Mali/panthor) SoC. Keeping them off also keeps debug-info out of the
      # module tree, which otherwise overflows the build scratch disk.
      DRM_AMDGPU = lib.mkForce no;
      DRM_I915 = lib.mkForce no;
      DRM_XE = lib.mkForce no;
      DRM_NOUVEAU = lib.mkForce no;
      DRM_RADEON = lib.mkForce no;
      # Disk strategy for the 100G build host: the v7.2 module tree with DWARF
      # debug info needs >25G of build scratch and hit ENOSPC. Select the
      # "None" debug-info choice; kallsyms symbol names remain available for
      # traces. This also rules out vmlinux/module BTF (already impossible
      # under DEBUG_INFO_REDUCED=y from config.sky1-latest), so bpftune
      # behaviour is unchanged vs the 6.19 system.
      # NOTE: plain DEBUG_INFO=no does NOT work here - nixpkgs sets the
      # DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT choice member, which implies
      # DEBUG_INFO=y at olddefconfig time regardless of the bool.
      DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = lib.mkForce no;
      DEBUG_INFO_NONE = lib.mkForce yes;

      NVMEM_SKY1 = yes;
      PWM_SKY1 = yes;
      SKY1_GPT_TIMER = yes;
      USB_CDNS_SUPPORT = yes;
      # cdnsp-plat (USB_CDNSP=y, built-in) references the Cadence DRD core
      # (cdns_init/cdns_resume/... from USB_CDNS3) and cdnsp_gadget_init
      # (USB_CDNSP_GADGET). Force those built-in too, or the vmlinux link
      # fails with undefined references to those symbols.
      USB_CDNS3 = yes;
      USB_CDNS3_GADGET = yes;
      USB_CDNSP = yes;
      USB_CDNSP_GADGET = yes;
      USB_CDNSP_SKY1 = yes;
      # Sky1 uses the platform/SoC CDNSP driver, not the PCI variant. The PCI
      # module (cdnsp-udc-pci) bundles cdnsp-gadget.o, which re-exports
      # cdnsp_gadget_init already built into vmlinux -> modpost "exported twice".
      USB_CDNSP_PCI = no;

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
