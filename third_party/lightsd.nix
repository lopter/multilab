{ buildPlatformPkgs, hostPlatformPkgs }:
let
  mkLightsd = { pname, version, src, meta }:
    hostPlatformPkgs.stdenv.mkDerivation {
      inherit pname version src meta;

      nativeBuildInputs = [
        buildPlatformPkgs.cmake
      ];

      cmakeFlags = [
        # My CMakeLists.txt apparently doesn't set CFLAGS correctly
        # if the build type isn't specified in uppercase.
        "-DCMAKE_BUILD_TYPE=RELEASE"
      ];

      buildInputs = [
        hostPlatformPkgs.libevent
      ];
    };
in
  mkLightsd rec {
    pname = "lightsd";
    version = "1.2.1";

    src = buildPlatformPkgs.fetchFromGitHub {
      owner = "lopter";
      repo = "lightsd";
      rev = "${version}";
      sha256 = "wCwV6RSwAsqxbTRii1c3SqVEzo8BZlmvyoxRpWP7n30=";
    };

    meta = with buildPlatformPkgs.lib; {
      description = "A daemon to control smart bulbs";
      longDescription = ''
        lightsd acts a central point of control for your LIFX WiFi bulbs.
        lightsd should be a small, simple and fast daemon exposing an easy
        to use protocol inspired by how musicpd works.
      '';
      license = licenses.gpl3Plus;
      homepage = "https://www.lightsd.io/";
    };
  }
