{
  description = "The code library supporting a Nix'ed homelab";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    multilab-config.url = "git+ssh://gitolite.kalessin.fr/louis/multilab-config?ref=main";
    multilab-config.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # The flake-modules under library/nixos expect to be loaded alongside
        # the following module: { _module.args.inputs' = inputs' } with inputs'
        # obtained through withSystem, see: https://flake.parts/module-arguments.html#withsystem
        #
        # I wonder if there would be way to abstract that better with a
        # function we could define in this file as a flake.lib attribute.
        #
        # I also wonder what that means for people not using flake-parts.
        ./library/nixos/flake-module.nix

        ./library/python/acl_watcher/flake-module.nix
        ./library/python/backups/flake-module.nix
        ./library/python/fake_sun/flake-module.nix
        ./library/python/lightsc/flake-module.nix
        ./library/python/monolight/flake-module.nix
        ./library/python/ofxstatement/flake-module.nix
      ];
      systems = [ "x86_64-linux" ]; # "armv6l-linux" "aarch64-darwin"
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Looks like this has some setbacks see:
        #
        # https://discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/8
        # https://zimbatm.com/notes/1000-instances-of-nixpkgs
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = import ./third_party/overlays.nix;
        };
      };
    };
}
