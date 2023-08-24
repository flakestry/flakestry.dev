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
  processes.frontend.exec = "elm-land server";

  pre-commit.hooks.shellcheck.enable = true;
  #pre-commit.hooks.shellcheck.args = [ "--exclude=SC1090" ];
  pre-commit.hooks.ruff.enable = true;
}