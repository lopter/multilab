{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs) nixpkgs;
in
{
  perSystem = { pkgs, ... }: {
    devShells.secrets = with pkgs; mkShell {
      buildInputs = [ sops ];
    };
  };

  flake.nixosConfigurations = {
    certbot-sfo-ashpool = lib.nixosSystem {
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ./machines/certbot-sfo-ashpool/configuration.nix
      ];
    };
  };
}
