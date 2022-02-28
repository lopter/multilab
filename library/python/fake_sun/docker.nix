let
  hostSystem = "raspberryPi";
in
  with (import ../../..) { inherit hostSystem; }; let
    rpiFakeSun = import (./.) { inherit hostSystem; };
    baseImage = buildPlatformPkgs.dockerTools.pullImage {
      imageName = "arm32v6/alpine";
      imageDigest = "sha256:e047bc2af17934d38c5a7fa9f46d443f1de3a7675546402592ef805cfa929f9d";
      sha256 = "1ch2klpwcqm56rryjh5lhldy2v3rivz1x9fdcrhmvxk2qxvmlkyq";
      finalImageName = "arm32v6/alpine";
      finalImageTag = "latest";
    };
  in
    hostPlatformPkgs.dockerTools.buildImage {
      name = "fake_sun";
      tag = "latest";

      fromImage = baseImage;
      fromImageTag = "latest";

      contents = rpiFakeSun;
    }
