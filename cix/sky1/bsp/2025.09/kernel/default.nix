{
  lib,
  fetchpatch2,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  kver = "6.6.89";
  rev = "4f8ec1ee12efa6e5ac0cb190a7bc5e34171d5f5c";
  hash = "sha256-oau9t6wYSCMIBFljF0WKeIf5DHtAKlD7ZWAhVRP12kk=";

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
          patch = fetchpatch2 {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/99dae262da2185f18503720328b42c4c244a1a0d/debian/patches/cix/wip/0001-DPTSW-16669-0-clocksource-timer-sky1-gpt-remove-rese.patch";
            hash = "sha256-4H5wZU9UGa+NXLy1oMCzESYayjCfE5g6TA2fNarMpRU=";
          };
        }
        {
          name = "0002-DPTSW-16669-1-pwm-remove-reset-operation";
          patch = fetchpatch2 {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/99dae262da2185f18503720328b42c4c244a1a0d/debian/patches/cix/wip/0002-DPTSW-16669-1-pwm-remove-reset-operation.patch";
            hash = "sha256-bAIyps9FFdC4yzcyqja0ZyhEyJOt3ivajXilSITvmUw=";
          };
        }
        {
          name = "0003-DPTSW-16669-2-arch-arm64-dts-cix-disable-uart1";
          patch = fetchpatch2 {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/99dae262da2185f18503720328b42c4c244a1a0d/debian/patches/cix/wip/0003-DPTSW-16669-2-arch-arm64-dts-cix-disable-uart1.patch";
            hash = "sha256-BcQt4KwhjdRvYpo7EDFROGAv+9JbBHiM1tK2RpmpCkk=";
          };
        }
        {
          name = "0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe";
          patch = fetchpatch2 {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/99dae262da2185f18503720328b42c4c244a1a0d/debian/patches/cix/wip/0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe.patch";
            hash = "sha256-feY75Q3DTt8sh8Swia6aq+wumfmHzrmkTFjkgXeHrZw=";
          };
        }
        {
          name = "drm/panthor: Add ACPI support";
          patch = fetchpatch2 {
            url = "https://gitlab.com/cix-linux/cix_opensource/linux/-/merge_requests/1.patch";
            hash = "sha256-XtMIDW/Uw7/yzUFW9BbpaZlfoxCxynzQenNTurL9c/E=";
          };
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
