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
  config = lib.mkIf (cfg.enable && cfg.bspRelease == "2025.04") {
    nixpkgs.overlays = [
      (import ./overlay.nix)
      (final: prev: {
        linuxPackages_cix = final.linuxPackages_6_6_10;
      })
    ];

    boot = {
      kernelPackages = lib.mkOverride 900 pkgs.linuxPackages_cix;
    };
  };
}
