{ hostSystem ? "buildPlatform" }:
with (import ../../..) { inherit hostSystem; }; let
  params = {
    pname = "acl_watcher";
    src = ./.;
    version = "1.0.0-rc.1";
    doCheck = false;
    propagatedBuildInputs = [
      hostPlatformPkgs.acl
      hostPlatformPkgs.python39Packages.click
      hostPlatformPkgs.python39Packages.pywatchman
    ];
  };
in hostPlatformPkgs.python39Packages.buildPythonApplication params
