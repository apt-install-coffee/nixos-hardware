final: _prev: {
  linuxKernel = _prev.linuxKernel // {
    kernels = _prev.linuxKernel.kernels // {
      linux_6_18_2 = final.callPackage ./kernel { };
    };
    vanillaPackages = _prev.linuxKernel.vanillaPackages // {
      linux_6_18_2 = final.lib.recurseIntoAttrs (
        (final.linuxKernel.packagesFor final.linuxKernel.kernels.linux_6_18_2).extend (
          _: _: {
            cix_npu_driver = final.linuxKernel.packages.linux_6_18_2.callPackage ./modules/cix_npu_driver { };
            cix_vpu_driver = final.linuxKernel.packages.linux_6_18_2.callPackage ./modules/cix_vpu_driver { };
          }
        )
      );
    };
  };
  linuxPackages_6_18_2 = final.linuxKernel.packages.linux_6_18_2;
  linux_6_18_2 = final.linuxKernel.kernels.linux_6_18_2;

  sky1-firmware = final.callPackage ./firmwares/sky1-firmware { };
}
