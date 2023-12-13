{
  perSystem = { pkgs, ... }:
    let
      systemPkgs = { buildPlatformPkgs = pkgs; inherit (pkgs) python3Packages; };

      mkOFXStatement = import ../../../third_party/pypi/ofxstatement.nix;
      ofxstatement = mkOFXStatement systemPkgs;

      mkOFXStatementCommon = { python3Packages, ofxstatement }:
        python3Packages.buildPythonPackage {
          pname = "ofxstatement-common";
          src = ./common;
          version = "0.0.1";
          propagatedBuildInputs = [ ofxstatement ];
        };
        ofxstatement-common = mkOFXStatementCommon {
          inherit ofxstatement;
          inherit (pkgs) python3Packages;
        };

      mkOFXStatementUSSchwab = { python3Packages, ofxstatement, ofxstatement-common }:
        python3Packages.buildPythonPackage {
          pname = "ofxstatement-us-schwab";
          src = ./us-schwab;
          version = "0.0.1";
          propagatedBuildInputs = [
            python3Packages.python-dateutil
            ofxstatement
            ofxstatement-common
          ];
          doCheck = false;
        };
        ofxstatement-us-schwab = mkOFXStatementUSSchwab {
          inherit ofxstatement ofxstatement-common;
          inherit (pkgs) python3Packages;
        };
    in {
      devShells.ofxstatement = pkgs.mkShell {
        buildInputs = [ ofxstatement-us-schwab pkgs.python3Packages.ipython ];
      };
    };
}
