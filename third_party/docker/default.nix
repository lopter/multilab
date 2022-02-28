{ hostSystem, buildPlatformPkgs, hostPlatformPkgs }:
  if hostSystem == "raspberryPi" then {
    alpine = buildPlatformPkgs.dockerTools.pullImage {
      imageName = "arm32v6/alpine";
      imageDigest = "sha256:e047bc2af17934d38c5a7fa9f46d443f1de3a7675546402592ef805cfa929f9d";
      sha256 = "xb5RU3ZQpnhIArDtw53FueQlXb5IggbgTIpB3f9m9mA=";
      finalImageName = "arm32v6/alpine";
      finalImageTag = "3.15.0";
    };
  } else throw "Missing alpine docker image for hostSystem ${hostSystem} in third_party/docker/default.nix"
