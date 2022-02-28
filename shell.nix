# We always want a shell where buildPlatform == hostPlatform,
# hostSystem is only useful when using nix-build.
with (import ./.) { hostSystem = "buildPlatform"; }; let
  pkgs = buildPlatformPkgs;
in
  pkgs.mkShell {
    buildInputs = [
      (pkgs.python39.withPackages (ps: [ps.ipython]))
      pkgs.mypy
    ];
  }
