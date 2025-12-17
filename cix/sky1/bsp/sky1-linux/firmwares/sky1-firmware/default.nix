{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sky1-firmware";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Sky1-Linux";
    repo = "sky1-firmware";
    tag = "v1.1.0";
    hash = "";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firmware/
    cp -r firmware/* $out/lib/firmware/

    runHook postInstall
  '';

  meta = {
    description = "Firmware files for CIX Sky1 SoC";
    homepage = "https://github.com/Sky1-Linux/sky1-firmware";
    license = lib.licenses.unfreeRedistributableFirmware;
    platforms = lib.platforms.linux;
  };
})
