{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cix_vpu_driver";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Sky1-Linux";
    repo = "sky1-drivers-dkms";
    tag = "v1.0.0";
    hash = "";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  patches = [
    # based on https://github.com/armbian/linux-cix/pull/5
    ./chromium.patch
  ];

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "driver"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)/vpu/src"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    BUILD_OUTPUT=(
      amvx.ko
    )
    for i in "''${BUILD_OUTPUT[@]}"; do
      install -D vpu/src/$i $out/lib/modules/${kernel.modDirVersion}/extra/$i
    done

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Sky1-Linux/sky1-drivers-dkms";
    description = "CIX VPU driver";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
