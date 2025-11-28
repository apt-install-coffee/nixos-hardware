{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  kver = "6.6.89";
  rev = "4f8ec1ee12efa6e5ac0cb190a7bc5e34171d5f5c";
  hash = "";

  args' =
    {
      version = "${kver}";
      modDirVersion = "${kver}-cix-build";
      pname = "linux-sky1";

      src = fetchFromGitHub {
        owner = "radxa";
        repo = "kernel";
        inherit rev hash;
      };

      kernelPatches = [
        {
          name = "0001-DPTSW-16669-0-clocksource-timer-sky1-gpt-remove-rese";
          patch = fetchurl {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/99dae262da2185f18503720328b42c4c244a1a0d/debian/patches/cix/wip/0001-DPTSW-16669-0-clocksource-timer-sky1-gpt-remove-rese.patch";
            hash = "sha256-tUNGipYogpTsX0Sc290avZAtZGCyjVz4MhyNiOzY51c=";
          };
        }
        {
          name = "0002-DPTSW-16669-1-pwm-remove-reset-operation";
          patch = fetchurl {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/99dae262da2185f18503720328b42c4c244a1a0d/debian/patches/cix/wip/0002-DPTSW-16669-1-pwm-remove-reset-operation.patch";
            hash = "";
          };
        }
        {
          name = "0003-DPTSW-16669-2-arch-arm64-dts-cix-disable-uart1";
          patch = fetchurl {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/99dae262da2185f18503720328b42c4c244a1a0d/debian/patches/cix/wip/0003-DPTSW-16669-2-arch-arm64-dts-cix-disable-uart1.patch";
            hash = "sha256-ctGReQu8RonZIp5v7c1LnIGDBGXPXXFJiDKV+DcUjhs=";
          };
        }
        {
          name = "0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe";
          patch = fetchurl {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/99dae262da2185f18503720328b42c4c244a1a0d/debian/patches/cix/wip/0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe.patch";
            hash = "sha256-kmOy+lsQosv176rKZ35qvdhsMk7Oe9k1kn7ZdvyN4c4=";
          };
        }
        {
          name = "drm/panthor: Add ACPI support";
          patch = fetchurl {
            url = "https://gitlab.com/cix-linux/cix_opensource/linux/-/merge_requests/1.patch";
            hash = "sha256-KhYsffNvqdOCaJi8oGP915HQ4za8RvEXlRseFkwhhWE=";
          };
        }
        {
          name = "rdr_pub";
          patch = ./rdr_pub.patch;
        }
      ];

      defconfig = "defconfig cix.config";

      structuredExtraConfig = with lib.kernel; {
        # Referencing non existing function
        CIX_CORE_CTL = lib.mkForce no;
        # drm_gpuvm.h conflict
        DRM_NOUVEAU = lib.mkForce no;
        # Non existing DP_CONF_SIGNALLING_SHIFT constant
        TYPEC_DP_ALTMODE = lib.mkForce no;
        # Non existing INV_ICM42600_REG_DRIVE_CONFIG constant
        INV_ICM42600_I2C = lib.mkForce no;
        # NULL dereference panic on reboot
        CIX_DST = lib.mkForce no;
      };

      isLTS = true;

      ignoreConfigErrors = true;
    }
    // (args.argsOverride or { });
in
buildLinux args'
