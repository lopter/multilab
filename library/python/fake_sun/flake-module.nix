{
  perSystem = { pkgs, system, self', ... }:
    let
      buildInputs = extra: ps: with ps; extra ++ [
        click
        fastapi
        inotify-simple
        uvicorn
      ];
      mkFakeSun = pkgs: pkgs.python3Packages.buildPythonApplication {
        pname = "fake_sun";
        src = ./.;
        version = "1.0.0-rc.1";
        doCheck = false;
        propagatedBuildInputs = buildInputs [ pkgs.redshift ] pkgs.python3Packages;
      };
      fakeSun = mkFakeSun pkgs;
      # Pull that out of config somehow?
      fakeSunUID = "61014";
      fakeSunGID = "61014";
      gpioGID = "61019";
      dockerImages = import ../../../third_party/docker/images.nix;
      alpineImageDetailsBySystem = dockerImages.alpineDetailsBySystem;
      mkDockerImage = { pkgs, name, fakeSun, alpineImageDetails }:
        pkgs.dockerTools.buildLayeredImage {
          inherit name;
          tag = "latest";
          contents = [ pkgs.tini fakeSun ];
          fromImage = pkgs.dockerTools.pullImage alpineImageDetails;
          config = {
            Entrypoint = [ "/bin/tini" "--" ];
            Env = [
#             "PYTHONBREAKPOINT=remote_pdb.set_trace"
              "REMOTE_PDB_HOST=0.0.0.0"
              "REMOTE_PDB_PORT=4444"
            ];
          };
        };
    in {
      devShells.fake_sun = pkgs.mkShell {
        buildInputs = [
          pkgs.redshift
          (pkgs.python3.withPackages (buildInputs [
            pkgs.python3Packages.mypy
            pkgs.python3Packages.ipython
          ]))
        ];
      };
      packages.fake_sun = fakeSun;
      packages.fake_sun_docker = mkDockerImage {
        inherit pkgs fakeSun;
        name = "docker-registry.kalessin.fr/nix/fake-sun";
        alpineImageDetails = alpineImageDetailsBySystem.${system};
      };
      packages.fake_sun_docker_rpi = mkDockerImage {
        name = "docker-registry.kalessin.fr/nix/armv6l/fake-sun";
        pkgs = pkgs.pkgsCross.raspberryPi;
        fakeSun = mkFakeSun pkgs.pkgsCross.raspberryPi;
        alpineImageDetails = alpineImageDetailsBySystem."armv6l-linux";
      };
    };
}
