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
  config = lib.mkIf (cfg.enable && cfg.bspRelease == "2025.09") {
    nixpkgs.overlays = [
      (import ./overlay.nix)
    ];

    boot = {
      kernelPackages = lib.mkOverride 900 pkgs.linuxPackages_cix;
      extraModulePackages = with config.boot.kernelPackages; [
        # cix_gpu_kernel
        cix_isp_driver
        cix_npu_driver
        cix_vpu_driver
      ];
    };

    hardware.firmware = with pkgs[
      cix_gpu_firmware
      cix_vpu_firmware
    ];
  };
}