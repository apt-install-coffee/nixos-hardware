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
      PCI_SKY1 = yes;
      PINCTRL_SKY1_BASE = yes;
      PINCTRL_SKY1 = yes;
      HWSPINLOCK_SKY1 = yes;
      USB_CDNSP_HOST = yes;  
      PHY_CIX_USB2 = yes;
      PHY_CIX_USB3 = yes;
      PHY_CIX_USBDP = yes;
      PHY_CIX_PCIE = yes;
      ARMCHINA_NPU_ARCH_V3 = yes;
      ARMCHINA_NPU_SOC_SKY1 = yes;
      DMABUF_HEAPS_CMA_LEGACY = yes;
      DMABUF_HEAPS_CMA = yes;
      DMABUF_HEAPS_DSP = yes;
      DMABUF_HEAPS_SYSTEM = yes;
      DMABUF_HEAPS = yes;
      NVME_CORE = yes;
      BLK_DEV_NVME = yes;
      TYPEC = yes;
      GPIO_CADENCE = yes;
      SKY1_WATCHDOG = yes;
      RPMB = yes;
      MMC_BLOCK = yes;
      OPTEE = yes;
      POWER_SEQUENCING = yes;
      USB_CDNS3 = yes;
      VFIO = yes;
      GRACE_PERIOD = yes;
    };

    configfile = "${sky1Patches}/config/config.sky1-latest";
    preferBuiltin = true;

    isLTS = false;

    ignoreConfigErrors = true;
  }
  // (args.argsOverride or { });
in
buildLinux args'
