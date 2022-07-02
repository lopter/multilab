# We always want a shell where buildPlatform == hostPlatform,
with (import ../../..) { }; let
  pythonPackages = ps: [
    ps.click
    ps.fastapi
    ps.ipython
    ps.inotify-simple
    ps.uvicorn
  ];
in with buildPlatform;
  pkgs.mkShell {
    buildInputs = [
      (python.withPackages pythonPackages)
      pkgs.mypy
    ];
  }
