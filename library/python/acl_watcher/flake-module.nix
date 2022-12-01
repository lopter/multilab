{
  perSystem = {pkgs, self', ...}:
    let
      params = {
        pname = "acl-watcher";
        src = ./.;
        version = "1.0.0-rc.1";
        doCheck = false;
        propagatedBuildInputs = [
          pkgs.acl
          pkgs.python39Packages.click
          pkgs.python39Packages.pywatchman
        ];
      };
      aclWatcher = pkgs.python39Packages.buildPythonApplication params;
    in {
      packages.acl_watcher = aclWatcher;
      packages.acl_watcher_docker = pkgs.dockerTools.buildLayeredImage {
        name = "docker-registry.kalessin.fr/nix/acl-watcher";
        tag = "latest";
        contents = [ pkgs.tini aclWatcher ];
        fromImage = self'.packages.docker_alpine;
        config = {
          Entrypoint = [ "/bin/tini" "--" ];
          Env = [
#           "PYTHONBREAKPOINT=remote_pdb.set_trace"
            "REMOTE_PDB_HOST=0.0.0.0"
            "REMOTE_PDB_PORT=4444"
          ];
        };
      };
    };
}
