{ hostSystem ? "buildPlatform" }:
with (import ../../..) { inherit hostSystem; }; let
  aclWatcher = import ./. { inherit hostSystem; };
in
  hostPlatformPkgs.dockerTools.buildLayeredImage {
    name = "docker-registry.kalessin.fr/nix/acl-watcher";
    tag = "latest";
    contents = [ hostPlatformPkgs.tini aclWatcher ];
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
