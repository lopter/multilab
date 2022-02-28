{ buildPlatformPkgs, hostPlatformPkgs }:
let
  mkLibMonome = { pname, version, src, meta }:
    hostPlatformPkgs.stdenv.mkDerivation {
      inherit pname version src meta;

      nativeBuildInputs = [
        buildPlatformPkgs.wafHook
        buildPlatformPkgs.python3
      ];

      buildInputs = [
        hostPlatformPkgs.liblo
      ];

      patches = [
        # Do not execute the program compiled to check if udev or liblo
        # were present, since it does not work when cross-compiling.
        ./libmonome_wscript_check_cc_execute_false.patch
      ];

      wafConfigureFlags = [
        "--disable-udev"
      ];

      enableParallelBuilding = true;
    };
in
  mkLibMonome rec {
    pname = "libmonome";
    version = "1.4.5";

    src = buildPlatformPkgs.fetchFromGitHub {
      owner = "monome";
      repo = "libmonome";
      rev = "v${version}";
      sha256 = "Kj5/+6gnqKfeClNh3gAcghJ6q9KpygbN32ulSf2Q7iw=";
    };

    meta = with buildPlatformPkgs.lib; {
      description = "A library for easy interaction with monome devices";
      license = licenses.isc;
      homepage = "https://github.com/monome/libmonome";
    };
  }
