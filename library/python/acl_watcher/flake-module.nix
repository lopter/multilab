{
  perSystem = {pkgs, system, ...}:
    let
      dockerImages = import ../../../third_party/docker/images.nix;
      alpineImageDetailsBySystem = dockerImages.alpineDetailsBySystem;
      params = {
        pname = "acl-watcher";
        src = ./.;
        version = "1.0.0-rc.1";
        doCheck = false;
        propagatedBuildInputs = [
          pkgs.acl
          pkgs.python3Packages.click
          pkgs.python3Packages.pywatchman
        ];
      };
      aclWatcher = pkgs.python3Packages.buildPythonApplication params;
    in {
      packages.acl_watcher = aclWatcher;
      packages.acl_watcher_docker = pkgs.dockerTools.buildLayeredImage {
        name = "docker-registry.kalessin.fr/nix/acl-watcher";
        tag = "latest";
        contents = [ pkgs.tini aclWatcher ];
        fromImage = pkgs.dockerTools.pullImage alpineImageDetailsBySystem.${system};
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
