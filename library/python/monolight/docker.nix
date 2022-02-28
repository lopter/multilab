{ hostSystem ? "buildPlatform" }:
with (import ../../..) { inherit hostSystem; }; let
  monolight = import ./. { inherit hostSystem; };
  monolightUID = "61017";
  serialoscUID = "61016";
  lightsdUID = "61018";
  lightsdURL = "tcp+jsonrpc://rpi-sfo-arch.kalessin.fr:56742";
  monolightImage = hostPlatformPkgs.dockerTools.buildLayeredImage {
    name = "docker-registry.kalessin.fr/nix/monolight";
    tag = "latest";
    contents = [ hostPlatformPkgs.tini monolight ];
    fromImage = thirdPkgs.docker.alpine;
    config = {
      Entrypoint = [ "/bin/tini" "--" ];
      Env = [
#       "PYTHONBREAKPOINT=remote_pdb.set_trace"
        "REMOTE_PDB_HOST=0.0.0.0"
        "REMOTE_PDB_PORT=4444"
      ];
      User = "${monolightUID}:${monolightUID}";
      Cmd = [ "/bin/monolight" "--lightsd-url" lightsdURL ];
    };
  };
  serialoscImage = hostPlatformPkgs.dockerTools.buildLayeredImage {
    name = "docker-registry.kalessin.fr/nix/serialosc";
    tag = "latest";
    contents = [ hostPlatformPkgs.tini thirdPkgs.serialosc ];
    fromImage = thirdPkgs.docker.alpine;
    config = {
      Entrypoint = [ "/bin/tini" "--" ];
      User = "${serialoscUID}:${serialoscUID}";
      Cmd = [ "/bin/serialoscd" ];
    };
  };
  lightsdImage = hostPlatformPkgs.dockerTools.buildLayeredImage {
    name = "docker-registry.kalessin.fr/nix/lightsd";
    tag = "latest";
    contents = [ hostPlatformPkgs.tini thirdPkgs.lightsd ];
    fromImage = thirdPkgs.docker.alpine;
    config = {
      Entrypoint = [ "/bin/tini" "--" ];
      User = "${lightsdUID}:${lightsdUID}";
      Cmd = [ "/bin/lightsd" "--no-timestamps" "--verbosity" "info" "--listen" ":::56742" ];
    };
  };
in [ monolightImage serialoscImage lightsdImage ]
