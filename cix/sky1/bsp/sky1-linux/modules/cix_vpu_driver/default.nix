{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cix_vpu_driver";
  version = "1.0.0-2-unstable-20251218";

  src = fetchFromGitHub {
    owner = "Sky1-Linux";
    repo = "sky1-drivers-dkms";
    rev = "62fadd6cbec8c72872f5aebeab7448e455ded40d";
    hash = "sha256-5S0vJ9I4JS5I3VF+QQCpR6jCOLn0fCGRqlIlYJCHevs=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
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
