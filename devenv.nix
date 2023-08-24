{ config, pkgs, ... }: {
  packages = [
    pkgs.flyctl
  ];

  languages.python = {
    enable = true;
    venv.enable = true;
    venv.requirements = ./requirements.txt;
  };

  languages.javascript = {
    enable = true;
    npm.install.enable = true;
  };

  services.opensearch.enable = true;
  services.postgres.enable = true;

  enterShell = ''
    export PATH="${config.devenv.root}/node_modules/.bin:$PATH"
  '';

  processes.backend.exec = "uvicorn main:app --reload";
  processes.frontend.exec = "cd frontend && elm-land server";

  containers.processes.name = "flakestry.dev";
  containers.processes.registry = "docker://registry.fly.io/";
  containers.processes.defaultCopyArgs = [
    "--dest-creds"
    "x:\"$(${pkgs.flyctl}/bin/flyctl auth token)\""
  ];

  pre-commit.hooks = {
    shellcheck.enable = true;
    #shellcheck.args = [ "--exclude=SC1090" ];
    nixpkgs-fmt.enable = true;
    ruff.enable = true;
    elm-format.enable = true;
  };
}
