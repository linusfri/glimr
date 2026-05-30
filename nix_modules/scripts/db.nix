{ config, ... }:
{
  scripts.migrate.exec = ''
    ${config.devenv.root}/glimr db_gen --migrate
  '';
}
