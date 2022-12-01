{
  perSystem = { pkgs, self', ... }:
    let
      mkAiosc = import ../../../third_party/pypi/aiosc.nix;
      _mkPymonome = import ../../../third_party/pypi/pymonome.nix;
      mkPymonome = pkgs: _mkPymonome (pkgs // { aiosc = mkAiosc pkgs; });
      mkMonolight = { pkgs, pymonome, lightsc }:
        pkgs.python3Packages.buildPythonApplication {
          pname = "monolight";
          src = ./.;
          version = "1.0.0-rc.1";
          doCheck = false;
          propagatedBuildInputs = [
            pkgs.python3Packages.click
            pymonome
            lightsc
          ];
        };
      systemPkgs = { buildPlatformPkgs = pkgs; hostPlatformPkgs = pkgs; };
      rpiPkgs = {
        buildPlatformPkgs = pkgs;
        hostPlatformPkgs = pkgs.pkgsCross.raspberryPi;
      };
      monolight = mkMonolight {
        inherit pkgs;
        pymonome = mkPymonome systemPkgs;
        lightsc = self'.packages.lightsc;
      };
      monolightRPi = mkMonolight {
        pkgs = pkgs.pkgsCross.raspberryPi;
        pymonome = mkPymonome rpiPkgs;
        lightsc = self'.packages.lightsc_rpi;
      };
      dockerImages = import ../../../third_party/docker/images.nix;
      alpineImageDetailsBySystem = dockerImages.alpineDetailsBySystem;
      alpineImageDetailsRPi = alpineImageDetailsBySystem."armv6l-linux";
      # Pull that out of config somehow?
      monolightUID = "61017";
      serialoscUID = "61016";
      lightsdUID = "61018";
      lightsdPort = "56742";
      lightsdURL = "tcp+jsonrpc://rpi-sfo-arch.kalessin.fr:${lightsdPort}";
      mkRPiDockerImage = { config, contents, name, }:
        with pkgs.pkgsCross.raspberryPi; dockerTools.buildLayeredImage {
          inherit name;
          tag = "latest";
          contents = [ tini ] ++ contents;
          fromImage = dockerTools.pullImage alpineImageDetailsRPi;
          config = config // {
            Entrypoint = [ "/bin/tini" "--" ];
            Env = [
#             "PYTHONBREAKPOINT=remote_pdb.set_trace"
              "REMOTE_PDB_HOST=0.0.0.0"
              "REMOTE_PDB_PORT=4444"
            ];
          };
        };
    in {
      packages.monolight = monolight;
      packages.serialosc = pkgs.serialosc;
      packages.lightsd = pkgs.lightsd;
      packages.monolight_docker_rpi = mkRPiDockerImage {
        name = "docker-registry.kalessin.fr/nix/armv6l/monolight";
        contents = [ monolightRPi ];
        config = {
          User = "${monolightUID}:${monolightUID}";
          Cmd = [ "/bin/monolight" "--lightsd-url" lightsdURL ];
        };
      };
      packages.serialosc_docker_rpi = mkRPiDockerImage {
        name = "docker-registry.kalessin.fr/nix/armv6l/serialosc";
        contents = [ pkgs.pkgsCross.raspberryPi.serialosc ];
        config = {
          User = "${serialoscUID}:${serialoscUID}";
          Cmd = [ "/bin/serialoscd" ];
        };
      };
      packages.lightsd_docker_rpi = mkRPiDockerImage {
        name = "docker-registry.kalessin.fr/nix/armv6l/lightsd";
        contents = [ pkgs.pkgsCross.raspberryPi.lightsd ];
        config = {
          User = "${lightsdUID}:${lightsdUID}";
          Cmd = [
            "/bin/lightsd"
            "--no-timestamps"
            "--verbosity" "info"
            "--listen" ":::${lightsdPort}"
          ];
        };
      };
    };
}
