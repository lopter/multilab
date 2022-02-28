{ hostSystem ? "buildPlatform" }:
with (import ../../..) { hostSystem = hostSystem; }; let
  params = {
    pname = "lightsc";
    src = ./.;
    version = "1.0.0-rc.1";
    doCheck = false;
  };
in hostPlatformPkgs.python39Packages.buildPythonPackage params
