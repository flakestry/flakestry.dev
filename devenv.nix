{
  languages.python = {
    enable = true;
    venv.enable = true;
    venv.requirements = ./requirements.txt;
  };

  languages.javascript = {
    enable = true;
    npm.install.enable = true;
  };

  processes.backend.exec = "uvicorn main:app --reload";
  processes.frontend.exec = "cd frontend && elm-land server";

  pre-commit.hooks = {
    shellcheck.enable = true;
    #shellcheck.args = [ "--exclude=SC1090" ];
    nixpkgs-fmt.enable = true;
    ruff.enable = true;
    elm-format.enable = true;
  };
}
