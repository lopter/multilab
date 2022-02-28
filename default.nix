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
    thirdPkgs = import ./third_party/. {
      inherit hostSystem buildPlatformPkgs hostPlatformPkgs;
    };
  }
