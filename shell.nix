# We always want a shell where buildPlatform == hostPlatform,
# hostSystem is only useful when using nix-build.
with (import ./.) { hostSystem = "buildPlatform"; }; let
  pkgs = buildPlatformPkgs;
  pythonPackages = ps: [
    ps.ipython
    ps.click
  ];
in
  pkgs.mkShell {
    buildInputs = [
      (pkgs.python39.withPackages pythonPackages)
      pkgs.mypy
    ];
  }
