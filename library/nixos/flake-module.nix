{
  flake.nixosModules = {
    backups = import ./backups.nix;
    basePkgs = import ./basepkgs.nix;
    certbotVaultGandi = import ./certbot-vault-gandi.nix;
    simpleMTA = import ./simplemta.nix;
  };
}
