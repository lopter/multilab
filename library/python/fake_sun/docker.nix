{ hostSystem ? "buildPlatform" }:
with (import ../../..) { inherit hostSystem; }; let
  rpiFakeSun = import ./. { inherit hostSystem; };
  fakeSunUID = "61014";
  fakeSunGID = "61014";
  gpioGID = "61019";
in
  hostPlatformPkgs.dockerTools.buildLayeredImage {
    name = "docker-registry.kalessin.fr/nix/fake-sun";
    tag = "latest";
    contents = [ hostPlatformPkgs.tini rpiFakeSun ];
    fromImage = thirdPkgs.docker.alpine;
    config = {
      Entrypoint = [ "/bin/tini" "--" ];
      Env = [
#       "PYTHONBREAKPOINT=remote_pdb.set_trace"
        "REMOTE_PDB_HOST=0.0.0.0"
        "REMOTE_PDB_PORT=4444"
      ];
    };
  }
