{ buildPlatformPkgs, hostPlatformPkgs }:
  let
    mkPymonome = { pname, version, src, meta }:
      hostPlatformPkgs.python3Packages.buildPythonPackage rec {
        inherit pname version src meta;
      };
  in
    mkPymonome rec {
      pname = "remote-pdb";
      version = "2.1.0";
      src = buildPlatformPkgs.python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "LXDG9B4Oq/AWXo8b5Y+CqnpgWq6rjyrv65ziRkMQkcE=";
      };
      meta = with buildPlatformPkgs.lib; {
        homepage = "https://github.com/ionelmc/python-remote-pdb";
        downloadPage = "https://github.com/ionelmc/python-remote-pdb/releases";
        description = "PDB over TCP sockets";
        licenses = licenses.bsd2;
      };
    }

