{ hostSystem ? "buildPlatform" }:
with (import ../../..) { inherit hostSystem; }; let
  params = {
    pname = "fake_sun";
    src = ./.;
    version = "1.0.0-rc.1";
    doCheck = false;
    propagatedBuildInputs = [
      hostPlatformPkgs.python39Packages.click
      thirdPkgs.redshift
    ];
  };
in hostPlatformPkgs.python39Packages.buildPythonApplication params
