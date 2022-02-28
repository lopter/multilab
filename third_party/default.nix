{ hostSystem, buildPlatformPkgs, hostPlatformPkgs }:
  rec {
    docker = import ./docker/. {
      inherit hostSystem buildPlatformPkgs hostPlatformPkgs;
    };
    libmonome = import ./libmonome.nix {
      inherit buildPlatformPkgs hostPlatformPkgs;
    };
    # We'll pull lightsd in this repository at some point,
    # but treat it as a third party dependency for now.
    lightsd = import ./lightsd.nix {
      inherit buildPlatformPkgs hostPlatformPkgs;
    };
    pypi = import ./pypi/. {
      inherit buildPlatformPkgs hostPlatformPkgs;
    };
    redshift = import ./redshift.nix {
      inherit buildPlatformPkgs hostPlatformPkgs;
    };
    serialosc = import ./serialosc.nix {
      inherit buildPlatformPkgs hostPlatformPkgs libmonome;
    };
  }
