# TODO:
#
# Make sure the renewal command works correctly
# and setup a periodic job to call cerbot.
{ config, lib, pkgs, ... }:
let
  cfg = config.certbot-vault-gandi;
in
{
  options.certbot-vault-gandi = with lib; with types; {
    configDir = mkOption {
      description = mdDoc "`--config-dir` option for certbot.";
      type = path;
    };
    workDir = mkOption {
      description = mdDoc ''
        `--workDir` option for certbot. Defaults
        to the value for the `configDir` option.
      '';
      type = path;
      default = cfg.configDir;
    };
    configINI = mkOption {
      description = mdDoc ''
        Contents for the file passed to the `--config` option for certbot.
      '';
      type = lines;
      default = ''
        agree-tos = true
        non-interactive = true
        keep-until-expiring = true
        key-type = ecdsa
        # ed25519 not yet supported, secp521r1 also an option see RFC 8446:
        elliptic-curve = secp384r1
      '';
    };
    email = mkOption {
      description = mdDoc "`--email` option for certbot.";
      type = str;
    };
    logDir = mkOption {
      description = mdDoc ''
        `--log-dir` option for certbot, if `null` this defaults to
        `/var/log/certbot` managed with the following `systemd.tmpfiles` rule:

            "d ''${logDir} 0750 certbot certbot 180d -"
      '';
      type = nullOr path;
      default = null;
    };
    vaultAddr = mkOption {
      description = mdDoc "`--vault-addr` option for certbot.";
      type = str;
    };
    vaultMount = mkOption {
      description = mdDoc "`--vault-mount` option for certbot.";
      type = str;
    };
    vaultPath = mkOption {
      description = mdDoc "`--vault-path` option for certbot.";
      type = str;
    };
    vaultCredentialsFile = mkOption {
      type = types.path;
      description = mdDoc ''
        Path to a shell script that exports the variables:

        - `VAULT_ROLE_ID`
        - & `VAULT_SECRET_ID`
      '';
    };

    gandiCredentialsFile = mkOption {
      type = types.path;
      description = mdDoc ''
        Path to the ini file containing `dns_gandi_token = FOOBAR`.
      '';
    };
  };

  config = 
  let
    certbotPlugins = certbotPythonPkgs: with pkgs; [
        (python3Packages.callPackage ../../third_party/pypi/certbot-plugin-gandi.nix { })
        (python3Packages.callPackage ../../third_party/pypi/certbot-vault.nix { })
    ];
    certbotConfigINI = pkgs.writeText "cli.ini" cfg.configINI;
    logDir = if cfg.logDir == null then "/var/log/certbot" else cfg.logDir;
    certbotVaultGandi = pkgs.writeScriptBin "certbot-vault-gandi" ''
        #!${pkgs.stdenv.shell}

        . ${cfg.vaultCredentialsFile}

        exec certbot \
            --config-dir ${cfg.configDir} \
            --logs-dir ${logDir} \
            --work-dir ${cfg.workDir} \
            --config ${certbotConfigINI} \
            --authenticator dns-gandi \
            --dns-gandi-credentials ${cfg.gandiCredentialsFile} \
            --installer vault \
            --vault-addr ${cfg.vaultAddr} \
            --vault-mount ${cfg.vaultMount} \
            --vault-path ${cfg.vaultPath} \
            "$@"
      '';
  in {
    systemd.tmpfiles.rules = lib.mkIf (cfg.logDir == null) [
      "d ${logDir} 0750 certbot certbot 180d -"
    ];

    environment.systemPackages = with pkgs; [
      (python3Packages.certbot.withPlugins certbotPlugins)

      certbotVaultGandi
    ];
  };
}
