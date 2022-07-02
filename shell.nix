# We always want a shell where buildPlatform == hostPlatform,
# specifying hostSystem is only useful when using nix-build.
with (import ./.) { }; let
  pythonPackages = ps: [
    ps.ipython
    ps.click
  ];
in with buildPlatform;
  pkgs.mkShell {
    buildInputs = [
      (python.withPackages pythonPackages)
      pkgs.mypy
    ];
  }
