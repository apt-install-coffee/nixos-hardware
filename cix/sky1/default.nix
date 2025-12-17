{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.hardware.cix.sky1;
in
{
  options.hardware.cix.sky1 = {
    enable = lib.mkEnableOption "CIX Sky1 support";

    bspRelease = lib.mkOption {
      type = lib.types.enum [
        "2025.04"
        "2025.09"
        "none"
        "sky1-linux"
      ];
      default = "2025.09";
      description = ''
        Select the BSP release that will be used on the system.

        A special `none` option is available to disable system configuration
        associated with a specific BSP release. Only packages are added via the
        overlay to allow manual configuration.
      '';
    };
  };

  imports = [
    ./bsp/2025.04
    ./bsp/2025.09
    ./bsp/none
    ./bsp/sky1-linux
  ];

  config = lib.mkIf cfg.enable {
    hardware.cix.enable = true;
  };
}
