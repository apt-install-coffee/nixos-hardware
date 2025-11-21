{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  kver = "6.6.89";
  rev = "7a822ac9aea389869a28f259b507ceaf5fa4f527";
  hash = "sha256-ySM+XHPwcPweszvba7GshBlrWlpds3y5InMw2HTHhvg=";

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
          patch = ./0001-DPTSW-16669-0-clocksource-timer-sky1-gpt-remove-rese.patch;
        }
        {
          name = "0002-DPTSW-16669-1-pwm-remove-reset-operation";
          patch = ./0002-DPTSW-16669-1-pwm-remove-reset-operation.patch;
        }
        {
          name = "0003-DPTSW-16669-2-arch-arm64-dts-cix-disable-uart1";
          patch = ./0003-DPTSW-16669-2-arch-arm64-dts-cix-disable-uart1.patch;
        }
        {
          name = "0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe";
          patch = ./0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe.patch;
        }
        {
          name = "0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe";
          patch = fetchurl {
            url = "https://gitlab.com/cix-linux/cix_opensource/linux/-/merge_requests/1.patch";
            hash = "sha256-KhYsffNvqdOCaJi8oGP915HQ4za8RvEXlRseFkwhhWE=";
          };
        }
        {
          name = "logmem_add";
          patch = ./logmem_add.patch;
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
      };

      isLTS = true;

      ignoreConfigErrors = true;
    }
    // (args.argsOverride or { });
in
buildLinux args'
