{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.glimr.postgres;
  inherit (import ./scripts/constants.nix { inherit config; }) dbPermissionsAndOwnership;
in
{
  options.services.glimr.postgres = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "Database user.";
      default = "glimr";
    };
    dbName = lib.mkOption {
      type = lib.types.str;
      description = "Database user.";
      default = "glimr";
    };
  };

  config = {
    services.postgres = {
      enable = true;
      package = pkgs.postgresql_18;
      initialDatabases = [
        {
          name = cfg.dbName;
        }
      ];
      listen_addresses = "*";
      initialScript = ''
        CREATE ROLE postgres WITH LOGIN SUPERUSER;
        CREATE ROLE ${cfg.user} WITH LOGIN;

        ${dbPermissionsAndOwnership}
      '';
    };
  };
}
