{
  perSystem = { pkgs, ... }:
  let
    backups = pkgs.python3Packages.buildPythonPackage {
      pname = "multilab-backups";
      version = "0.0.1";
      src = ./.;
      buildInputs = with pkgs.python3Packages; [
        setuptools
        setuptools-scm
      ];
      propagatedBuildInputs = [
        pkgs.util-linux
        pkgs.python3Packages.click
      ];
    };
  in {
    packages.backups = backups;
    devShells.backups = pkgs.mkShell {
      propagatedBuildInputs = with pkgs.python3Packages; [
        backups
        ipython
      ];
    };
  };
}
