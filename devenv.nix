{ config, pkgs, lib, ... }: {
  packages = [
    pkgs.flyctl
    pkgs.cloudflared
    pkgs.openapi-generator-cli
  ];

  env.LD_LIBRARY_PATH = "";

  languages.python = {
    enable = true;
    poetry.enable = true;
  };

  languages.javascript = {
    enable = true;
    npm.install.enable = true;
  };

  languages.elm.enable = true;

  services.opensearch.enable = true;
  services.postgres.enable = !config.container.isBuilding;
  services.caddy.enable = true;
  services.caddy.virtualHosts.":8888" = {
    extraConfig = ''
      root * ${config.devenv.root}/frontend/dist

      handle_path /api/* {
        reverse_proxy localhost:8000
      }

      ${ if config.container.isBuilding then ''
        file_server
      '' else ''
        reverse_proxy localhost:5200
      ''}
    '';
  };

  enterShell = ''
    export PATH="${config.devenv.root}/node_modules/.bin:$PATH"
  '' + lib.optionalString config.container.isBuilding ''
    cd ${config.devenv.root}frontend && elm-land build
  '';

  # Generate the Elm API client
  #
  # We replace the genererated cross-origin requests with requests to the same host.
  # An alternative would be to specify the server URL when created the FastAPI app.
  # You can also set the `--server-variables` option to fill in template variables in the server URL.
  scripts.generate-elm-api.exec = ''
    python ${config.devenv.root}/backend/gen_openapi.py

    echo generating frontend/generated-api
    openapi-generator-cli generate \
      --input-spec ${config.devenv.root}/frontend/openapi.json \
      --generator-name elm \
      --output ${config.devenv.root}/frontend/generated-api

    root_path=$(cat ${config.devenv.root}/frontend/openapi.json | jq '.servers[0].url')

    sed -i "s#Url.Builder.crossOrigin req.basePath req.pathParams#Url.Builder.absolute ($root_path :: req.pathParams)#g" \
      ${config.devenv.root}/frontend/generated-api/src/Api.elm
  '';

  processes = {
    backend.exec = "cd ${config.devenv.root} && uvicorn --app-dir backend --reload flakestry.main:app";
  } // lib.optionalAttrs (!config.container.isBuilding) {
    frontend.exec = "cd ${config.devenv.root}/frontend && elm-land server";
  };

  containers.processes.name = "flakestry-staging";
  containers.processes.version = "staging";
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
