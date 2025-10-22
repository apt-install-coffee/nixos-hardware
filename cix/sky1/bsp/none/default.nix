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
  config = lib.mkIf (cfg.enable && cfg.bspRelease == "none") {
    nixpkgs.overlays = [
      (import ../2025.04/overlay.nix)
      (import ../2025.09/overlay.nix)
    ];
  };
}
