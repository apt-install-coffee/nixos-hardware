{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.hardware.cix;
in
{
  imports = [
    ./sky1
  ];

  options.hardware.cix = {
    enable = lib.mkEnableOption "CIX SoC support";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelParams = [
        "console=tty1"
        "console=ttyAMA0,115200n8"
        "console=ttyAMA2,115200n8"
        "acpi=force"
        "kasan=off"
      ];
    };
  };
}
