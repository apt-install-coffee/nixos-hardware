final: _prev: {
  linuxKernel = _prev.linuxKernel // {
    kernels = _prev.linuxKernel.kernels // {
      linux_6_18_1 = final.callPackage ./kernel {};
    };
    vanillaPackages = _prev.linuxKernel.vanillaPackages // {
      linux_6_18_1 = final.lib.recurseIntoAttrs ((final.linuxKernel.packagesFor final.linuxKernel.kernels.linux_6_18_1).extend (
        _: _: {
          cix_npu_driver = final.linuxKernel.packages.linux_6_18_1.callPackage ./modules/cix_npu_driver { };
          cix_vpu_driver = final.linuxKernel.packages.linux_6_18_1.callPackage ./modules/cix_vpu_driver { };
        }
      ));
    };
  };
  linuxPackages_6_18_1 = final.linuxKernel.packages.linux_6_18_1;
  linux_6_18_1 = final.linuxKernel.kernels.linux_6_18_1;

  cix_gpu_firmware_2025_09 = final.callPackage ./firmwares/cix_gpu_firmware {};
  cix_vpu_firmware_2025_09 = final.callPackage ./firmwares/cix_vpu_firmware {};
}
