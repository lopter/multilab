{
  perSystem = { pkgs, ... }:
    let
      params = {
        pname = "lightsc";
        src = ./.;
        version = "1.0.0-rc.1";
        doCheck = false;
      };
    in {
      packages.lightsc = pkgs.python3Packages.buildPythonPackage params;
      packages.lightsc_rpi =
        pkgs.pkgsCross.raspberryPi.python3Packages.buildPythonPackage params;
    };
}
