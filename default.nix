{ hostSystem ? "buildPlatform" }:
  let
    sources = import ./nix/sources.nix;
    pkgs = import sources.nixpkgs { };
    buildPlatformPkgs = pkgs;
    hostPlatformPkgs =
      if hostSystem == "buildPlatform" then pkgs
      else if hostSystem == "raspberryPi" then pkgs.pkgsCross.raspberryPi
      else throw "Unknown hostSystem ${hostSystem}";
  in {
    sources = sources;
    buildPlatformPkgs = buildPlatformPkgs;
    hostPlatformPkgs = hostPlatformPkgs;
    hostPlatform = {
      pkgs = hostPlatformPkgs;
      python = hostPlatformPkgs.python39;
      pythonPkgs = hostPlatformPkgs.python39Packages;
    };
    buildPlatform = {
      pkgs = buildPlatformPkgs;
      python = buildPlatformPkgs.python39;
      pythonPkgs = buildPlatformPkgs.python39Packages;
    };
    thirdPkgs = import ./third_party/. {
      inherit hostSystem buildPlatformPkgs hostPlatformPkgs;
    };
  }
