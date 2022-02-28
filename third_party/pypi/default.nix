{ buildPlatformPkgs, hostPlatformPkgs }:
  rec {
    aiosc = import ./aiosc.nix {
      inherit buildPlatformPkgs hostPlatformPkgs;
    };
    pymonome = import ./pymonome.nix {
      inherit buildPlatformPkgs hostPlatformPkgs aiosc;
    };
    remote-pdb = import ./remote-pdb.nix {
      inherit buildPlatformPkgs hostPlatformPkgs;
    };
  }
