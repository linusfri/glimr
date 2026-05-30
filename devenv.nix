{
  pkgs,
  inputs,
  config,
  ...
}:
let
  appName = "glimr";
  backendDomain = "glimr.local";
  backendPort = 8080;
in
{
  imports = [
    ./nix_modules/postgres.nix
    ./nix_modules/scripts/db.nix
    ./nix_modules/scripts/utils.nix
  ];

  config = {
    # hosts.${backendDomain} = "127.0.0.1";

    packages = with pkgs; [
      git
      graphviz
    ];

    env = {
      APP_NAME = appName;
      APP_PORT = backendPort;
      APP_DEBUG = true;
      APP_URL = "http://${backendDomain}:${toString backendPort}";
      APP_KEY = "lF9qDzUXnS1hbEMAo8xNkYLBo8xU6px5pGIFQE7tOg05nXuCogVG7vNuxTNUPcpwWet2U4dvJqtiaVUHAoj0iA==";

      DB_HOST = "127.0.0.1";
      DB_PORT = 5432;
      DB_DATABASE = appName;
      DB_USERNAME = appName;
      # DB_PASSWORD = "";
      DB_POOL_SIZE = 15;
    };

    services.${appName}.postgres = {
      user = appName;
      dbName = appName;
    };

    processes = {
      application = {
        exec = "./glimr run";
        after = [ "devenv:processes:postgres" ];
      };
    };

    languages = {
      gleam = {
        enable = true;
      };
      javascript = {
        enable = true;
        npm.enable = true;
      };
      java.enable = true;
    };
  };
}
