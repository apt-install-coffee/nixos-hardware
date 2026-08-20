final: _prev: {
  linuxKernel = _prev.linuxKernel // {
    kernels = _prev.linuxKernel.kernels // {
      linux_7_2 = final.callPackage ./kernel { };
    };
    vanillaPackages = _prev.linuxKernel.vanillaPackages // {
      linux_7_2 = (final.linuxKernel.packagesFor final.linuxKernel.kernels.linux_7_2);
    };
  };
  linuxPackages_7_2 = final.linuxKernel.packages.linux_7_2;
  linux_7_2 = final.linuxKernel.kernels.linux_7_2;

  sky1-firmware = final.callPackage ./firmwares/sky1-firmware { };
}
