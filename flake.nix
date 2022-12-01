{
  description = "An homelab";

  inputs = {
    nixpkgs.url = "github:lopter/nixpkgs/release-22.05-lo-patches";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
        ./library/python/acl_watcher/flake-module.nix
        ./library/python/fake_sun/flake-module.nix
        ./library/python/lightsc/flake-module.nix
        ./library/python/monolight/flake-module.nix
      ];
      systems = [ "x86_64-linux" ]; # "armv6l-linux" "aarch64-darwin"
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        #packages.default = pkgs.hello;

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = import ./third_party/overlays.nix;
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
