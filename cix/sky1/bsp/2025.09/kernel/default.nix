{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  kver = "6.6.89";
  rev = "915a940499a619f362d7e4b2203c105313941f88";
  hash = "sha256-d3nVowJlsB26FwRH/lA2b4U2u5orV3SwEvk3xVArrgc=";

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
            url = "https://github.com/radxa-pkg/linux-sky1/raw/refs/heads/main/debian/patches/cix/wip/0001-DPTSW-16669-0-clocksource-timer-sky1-gpt-remove-rese.patch";
            sha256 = "sha256-MdyOe1tsjDHEnI0zq6Qf+ZOF30ljl9Gk3BWdWtmbivs=";
          };
        }
        {
          name = "0002-DPTSW-16669-1-pwm-remove-reset-operation";
          patch = fetchurl {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/refs/heads/main/debian/patches/cix/wip/0002-DPTSW-16669-1-pwm-remove-reset-operation.patch";
            sha256 = "sha256-1nW/3eXV061Elh++W78V0AGeskyashgz2fyS0EQAGLE=";
          };
        }
        {
          name = "0003-DPTSW-16669-2-arch-arm64-dts-cix-disable-uart1";
          patch = fetchurl {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/refs/heads/main/debian/patches/cix/wip/0003-DPTSW-16669-2-arch-arm64-dts-cix-disable-uart1.patch";
            sha256 = "sha256-RInyObRL1afEf9XBj8jMtDcFYYKS3s1n8kt0YeGRopo=";
          };
        }
        {
          name = "0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe";
          patch = fetchurl {
            url = "https://github.com/radxa-pkg/linux-sky1/raw/refs/heads/main/debian/patches/cix/wip/0004-DPTSW-17177-pwm-sky1-remove-pwm-clock-auto-enable-fe.patch";
            sha256 = "sha256-E3JWI2HM0YTsXvK7hjvRtAdvp6yga4XjAfjtvShZK4c=";
          };
        }
        {
          name = "fix-fwnode_regulator";
          patch = ./fix-fwnode_regulator.patch;
        }
        {
          name = "fix-cix-ec";
          patch = ./fix-cix-ec.patch;
        }
        {
          name = "incompatible-pointer";
          patch = ./incompatible-pointer.patch;
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
