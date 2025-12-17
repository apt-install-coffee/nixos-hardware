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
  config = lib.mkIf (cfg.enable && cfg.bspRelease == "sky1-linux") {
    nixpkgs.overlays = [
      (import ./overlay.nix)
      (final: prev: {
        linuxPackages_cix = final.linuxPackages_6_18_1;
      })
    ];

    boot = {
      kernelPackages = lib.mkOverride 900 pkgs.linuxPackages_cix;
      extraModulePackages = with config.boot.kernelPackages; [
        # cix_npu_driver
        cix_vpu_driver
      ];
      extraModprobeConfig = ''
        options linlon-dp enable_render=0 # conflict with Panthor
      '';
    };

    hardware.firmware = with pkgs; [
      sky1-firmware
    ];
  };
}
