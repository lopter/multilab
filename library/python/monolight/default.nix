{ hostSystem ? "buildPlatform" }:
with (import ../../..) { inherit hostSystem; }; let
  lightsc = import ../lightsc/. { inherit hostSystem; };
  params = {
    pname = "monolight";
    src = ./.;
    version = "1.0.0-rc.1";
    doCheck = false;
    propagatedBuildInputs = [
      hostPlatformPkgs.python39Packages.click
      thirdPkgs.pypi.pymonome
      lightsc
    ];
  };
in hostPlatformPkgs.python39Packages.buildPythonApplication params
