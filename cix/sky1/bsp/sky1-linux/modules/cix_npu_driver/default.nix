{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cix_npu_driver";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Sky1-Linux";
    repo = "sky1-drivers-dkms";
    tag = "v1.0.0";
    hash = "";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)/npu/src"
    "COMPASS_DRV_BTENVAR_KPATH=$(KDIR)"
    "BUILD_AIPU_VERSION_KMD=BUILD_ZHOUYI_V3"
    "COMPASS_DRV_BTENVAR_KMD_VERSION=5.11.0"
		"BUILD_TARGET_PLATFORM_KMD=BUILD_PLATFORM_SKY1"
		"BUILD_NPU_DEVFREQ=y"
  ];

  enableParallelBuilding = true;

  buildFlags = [
    "modules"
  ];

  preBuild = ''
    substituteInPlace npu/src/Makefile --replace-fail '$(PWD)' $PWD/npu/src
  '';

  installPhase = ''
    runHook preInstall

    BUILD_OUTPUT=(
      aipu.ko
    )
    for i in "''${BUILD_OUTPUT[@]}"; do
      install -D npu/src/$i $out/lib/modules/${kernel.modDirVersion}/extra/$i
    done

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Sky1-Linux/sky1-drivers-dkms";
    description = "CIX NPU driver";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
