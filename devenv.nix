{ config, pkgs, lib, ... }:
let
  mkContainer = env: {
    name = "flakestry-${env}";
    registry = "docker://registry.fly.io/";
    defaultCopyArgs = [
      "--dest-creds"
      "x:\"$(${pkgs.flyctl}/bin/flyctl auth token)\""
    ];
    # Avoid copying the poetry virtual environment.
    # This is not portable and should be built in the container.
    copyToRoot =
      builtins.filterSource
        (path: type: baseNameOf path != ".venv")
        ./.;
    # start processses
    startupCommand = config.procfileScript;
  };

  mkDeploy = env: ''
    export OPENSEARCH_HOST=flakestry-${env}-opensearch.internal
    generate-elm-api
    pushd frontend
    elm-land build
    popd
    devenv container ${env} --copy
    flyctl deploy --vm-memory 1024 -a flakestry-${env} \
      --image registry.fly.io/flakestry-${env}:latest \
      --env FLAKESTRY_URL=$FLAKESTRY_URL \
      --env OPENSEARCH_HOST=$OPENSEARCH_HOST \
      --wait-timeout 300
  '';
in
{
  packages = [
    pkgs.postgresql
    pkgs.gnused
    pkgs.openssl
  ] ++ lib.optionals (!config.container.isBuilding) [
    pkgs.flyctl
    pkgs.cloudflared
    pkgs.openapi-generator-cli
    pkgs.pyright
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.CF
    pkgs.darwin.Security
    pkgs.darwin.configd
    pkgs.darwin.dyld
  ];

  # https://github.com/cachix/devenv/pull/745
  env.LD_LIBRARY_PATH = "";

  languages.python = {
    enable = true;
    poetry.enable = true;
  };

  languages.javascript = {
    enable = true;
    npm.install.enable = true;
  };

  languages.typescript.enable = true;

  languages.elm.enable = true;

  languages.rust = {
    enable = true;
    # https://github.com/launchbadge/sqlx/blob/main/FAQ.md#what-versions-of-rust-does-sqlx-support-what-is-sqlxs-msrv
    channel = "stable";
  };

  services.opensearch.enable = !config.container.isBuilding;
  services.postgres.enable = !config.container.isBuilding;
  services.caddy.enable = true;
  services.caddy.virtualHosts.":8888" = {
    extraConfig = ''
      root * ${config.devenv.root}/frontend/dist

      route {
        handle_path /api/* {
          reverse_proxy localhost:8000
        }

        ${ if config.container.isBuilding then ''
          try_files {path} /
          file_server
        '' else ''
          reverse_proxy localhost:5200
        ''}
      }
    '';
  };

  # TODO: add this to javascript.npm implementation
  enterShell = ''
    export PATH="${config.devenv.root}/node_modules/.bin:$PATH"
  '';

  enterTest = ''
    pushd backend-rs
    cargo build
    popd
  '';

  scripts.fetch-openapi-templates.exec =
    let
      openApiSrc = pkgs.fetchFromGitHub {
        owner = "OpenAPITools";
        repo = "openapi-generator";
        rev = "v${pkgs.openapi-generator-cli.version}";
        hash = "sha256-J3ukIIH4k6VsCF+FqUEaLcEeVrQcSfFeJrmAO8buhGw=";
      };
    in
    ''
      ${pkgs.rsync}/bin/rsync --recursive --delete --chmod=ugo=rwX \
        ${openApiSrc}/modules/openapi-generator/src/main/resources/elm/ \
        ${config.devenv.root}/frontend/templates/
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
      --enable-post-process-file \
      --generator-name elm \
      --template-dir ${config.devenv.root}/frontend/templates \
      --type-mappings object=JsonObject \
      --output ${config.devenv.root}/frontend/generated-api

    # Replace cross-origin requests with requests to the same host
    sed -i "s#Url.Builder.crossOrigin req.basePath req.pathParams#Url.Builder.absolute (\"api\" :: req.pathParams)#g" \
      ${config.devenv.root}/frontend/generated-api/src/Api.elm
  '';

  processes = {
    backend.exec = "cd ${config.devenv.root} && uvicorn --app-dir backend ${lib.optionalString (!config.container.isBuilding) "--reload"} flakestry.main:app";
  } // lib.optionalAttrs (!config.container.isBuilding) {
    frontend.exec = "cd ${config.devenv.root}/frontend && elm-land server";
  };

  containers.staging = mkContainer "staging";
  containers.production = mkContainer "production";

  scripts.deploy-staging.exec = ''
    export FLAKESTRY_URL=https://staging.flakestry.dev
    ${mkDeploy "staging"}
  '';
  scripts.deploy-production.exec = ''
    export FLAKESTRY_URL=https://flakestry.dev
    ${mkDeploy "production"}
  '';

  pre-commit.hooks = {
    shellcheck.enable = true;
    #shellcheck.args = [ "--exclude=SC1090" ];
    nixpkgs-fmt.enable = true;
    ruff.enable = true;
    # Format with black until ruff gains auto-formatting capabilities
    # https://github.com/astral-sh/ruff/issues/1904
    black.enable = true;
    elm-format.enable = true;
  };
}
