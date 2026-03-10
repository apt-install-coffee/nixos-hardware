final: _prev: {
  linuxKernel = _prev.linuxKernel // {
    kernels = _prev.linuxKernel.kernels // {
      linux_6_19_4 = final.callPackage ./kernel { };
    };
    vanillaPackages = _prev.linuxKernel.vanillaPackages // {
      linux_6_19_4 = (final.linuxKernel.packagesFor final.linuxKernel.kernels.linux_6_19_4);
    };
  };
  linuxPackages_6_19_4 = final.linuxKernel.packages.linux_6_19_4;
  linux_6_19_4 = final.linuxKernel.kernels.linux_6_19_4;

  sky1-firmware = final.callPackage ./firmwares/sky1-firmware { };
}
