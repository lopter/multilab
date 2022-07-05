{ hostSystem, buildPlatformPkgs, hostPlatformPkgs }:
  if hostSystem == "raspberryPi" then {
    alpine = buildPlatformPkgs.dockerTools.pullImage {
      imageName = "arm32v6/alpine";
      imageDigest = "sha256:e047bc2af17934d38c5a7fa9f46d443f1de3a7675546402592ef805cfa929f9d";
      sha256 = "uYg5MFs87WlHwwYdWDWm4bKVzWc5ifmHzrCTw6idQsw=";
      finalImageName = "arm32v6/alpine";
      finalImageTag = "3.16.0";
    };
  # XXX: properly get the current hostSystem using nixpkgs:
  } else if hostSystem == "buildPlatform" then {
    alpine = buildPlatformPkgs.dockerTools.pullImage {
      imageName = "amd64/alpine";
      imageDigest = "sha256:4ff3ca91275773af45cb4b0834e12b7eb47d1c18f770a0b151381cd227f4c253";
      sha256 = "rBfwij9kDWqq1g+AGdoaQLWmV9Wa3Oxv/H0XYRHT4Xg=";
      finalImageName = "amd64/alpine";
      finalImageTag = "3.16.0";
    };
  } else throw "Missing alpine docker image for hostSystem ${hostSystem} in third_party/docker/default.nix"
