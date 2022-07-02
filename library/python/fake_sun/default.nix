{ hostSystem ? "buildPlatform" }:
with (import ../../..) { inherit hostSystem; }; let
  params = {
    pname = "fake_sun";
    src = ./.;
    version = "1.0.0-rc.1";
    doCheck = false;
    propagatedBuildInputs = [
      hostPlatform.pythonPkgs.click
      hostPlatform.pythonPkgs.fastapi
      hostPlatform.pythonPkgs.inotify-simple
      hostPlatform.pythonPkgs.uvicorn
      thirdPkgs.redshift
    ];
  };
in hostPlatform.pythonPkgs.buildPythonApplication params
