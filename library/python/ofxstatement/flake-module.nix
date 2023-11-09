{
  perSystem = { pkgs, ... }:
    let
      python3Debug = pkgs.python3.override {
        self = python3Debug;
        stdenv = pkgs.stdenvAdapters.keepDebugInfo pkgs.stdenv;
      };

      python3Packages = python3Debug.pkgs;
      systemPkgs = { buildPlatformPkgs = pkgs; inherit python3Packages; };

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
          inherit python3Packages ofxstatement;
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
          inherit python3Packages ofxstatement ofxstatement-common;
        };
    in {
      devShells.ofxstatement = pkgs.mkShell {
        buildInputs = [ ofxstatement-us-schwab python3Packages.ipython ];
      };
    };
}
