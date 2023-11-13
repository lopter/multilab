{ config, lib, pkgs, inputs', ... }:
{
  options.backups = with lib; with types; {
    jobsByName = mkOption {
      description = mdDoc ''
        The list of backup jobs, the name of each backup job is used to look up
        public and private keys used with rsync jobs.
      '';
      type = attrsOf (submodule {
        options = {
          type = mkOption {
            description = mdDoc "The backup method used by this job.";
            type = enum [ "restic-b2" "rsync" ];
          };
          direction = mkOption {
            description = mdDoc ''
              Whether this backup is pushed or pulled from `localHost`. For
              `restic-b2` jobs only `push` is supported.
            '';
            type = enum [ "push" "pull" ];
          };
          localHost = mkOption {
            description = mdDoc "The FQDN of the local host";
            type = nonEmptyStr;
          };
          localPath = mkOption {
            description = mdDoc ''
              When `direction` is `pull` then this is the path where to store
              the backup at, otherwise it is the path to backup and send to
              `remoteHost`.
            '';
            type = path;
          };
          remoteHost = mkOption {
            description = mdDoc ''
              The FQDN of the remote host. This is only valid for `rsync` jobs.
            '';
            type = nullOr nonEmptyStr;
            default = null;
          };
          remotePath = mkOption {
            description = mdDoc ''
              When `direction` is `pull` then this is the path to backup on
              `remoteHost` otherwise this is the path where to store the
              backup at on `remoteHost`. This only valid for `rsync` jobs.
            '';
            type = nullOr nonEmptyStr;
            default = null;
          };
          oneFileSystem = mkEnableOption {
            description = mdDoc ''
              Do not cross filesystem boundaries, this is option is not honored
              and is always true with `rsync` jobs.
            '';
            default = true;
          };
          publicKeyPath = mkOption {
            description = mdDoc ''
              The SSH public key to be used with `rsync`. Unused for
              `restic-b2`.
            '';
            type = nullOr path;
            default = null;
          };
          privateKeyPath = mkOption {
            description = mdDoc ''
              The SSH private key to be used with `rsync`. Unused for
              `restic-b2`.
            '';
            type = nullOr path;
            default = null;
          };
          passwordPath = mkOption {
            description = mdDoc ''
              The password file to be used with `restic-b2`. Unused for
              `rsync`.
            '';
            type = nullOr path;
            default = null;
          };
          retention = mkOption {
            description = mdDoc ''
              How long to keep backup history for. This only used with
              `restic-b2` jobs. `rsync` jobs do not keep different versions.
            '';
            type = nullOr nonEmptyStr;
            default = null;
          };
        };
      });
    };
    restic = {
      cacheDir = mkOption {
        description = mdDoc ''
          Path to a cache directory that can be used by restic.
        '';
        type = path;
      };
      b2 = {
        bucket = mkOption {
          description = mdDoc "B2 bucket where backups are stored.";
          type = nonEmptyStr;
        };
        keyIdPath = mkOption {
          description = mdDoc "Key ID to access the B2 api";
          type = path;
        };
        applicationKeyPath = mkOption {
          description = mdDoc "Application key to access the B2 api";
          type = path;
        };
      };
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${config.backups.restic.cacheDir} 0700 root root - -"
    ];
    environment.etc."multilab-backups.json" = {
      text = builtins.toJSON config.backups;
    };
    environment.systemPackages = with pkgs; [
      restic
      rsync
      inputs'.multilab.packages.backups
    ];
  };
}
