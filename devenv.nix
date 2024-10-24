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
  env.DATABASE_URL = "postgres://flakestry@localhost:5431/";
  env.BASE_PATH = "localhost:3000";

  packages = [
    pkgs.openssl
    pkgs.cargo-watch
    pkgs.elmPackages.elm-land
  ] ++ lib.optionals (!config.container.isBuilding) [
    pkgs.flyctl
    pkgs.openapi-generator-cli
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.CF
    pkgs.darwin.Security
    pkgs.darwin.configd
    pkgs.darwin.dyld
  ];

  languages.javascript = {
    enable = true;
    npm.install.enable = true;
  };

  languages.python = {
    enable = true;
    poetry.enable = true;
  };
  languages.typescript.enable = true;
  languages.elm.enable = true;

  languages.rust = {
    enable = true;
    channel = "stable";
  };

  services.opensearch.enable = !config.container.isBuilding;
  services.postgres = {
    enable = !config.container.isBuilding;
    listen_addresses = "localhost";
    port = 5431;
    initialDatabases = [
      {
        name = "flakestry";
        user = "flakestry";
        pass = "secret";
      }
    ];
  };
  services.caddy.enable = true;
  services.caddy.virtualHosts.":8888" = {
    extraConfig = ''
      root * ${config.devenv.root}/frontend/dist

      route {
        handle_path /api/* {
          reverse_proxy localhost:3000
        }

        ${ if config.container.isBuilding then ''
          try_files {path} /
          file_server
        '' else ''
          reverse_proxy localhost:1234
        ''}
      }
    '';
  };

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
        hash = "sha256-9Gdkx/Ca6Zjb2lCV4Y9Gg4e4I1nkiVGUQVyUpCLAxuA=";
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
    generate-openapi

    echo generating frontend/generated-api
    openapi-generator-cli generate \
      --input-spec ${config.devenv.root}/backend-rs/openapi.json \
      --enable-post-process-file \
      --generator-name elm \
      --template-dir ${config.devenv.root}/frontend/templates \
      --type-mappings object=JsonObject \
      --output ${config.devenv.root}/frontend/generated-api
  '';

  scripts.generate-openapi.exec = ''
    cd backend-rs && cargo run --bin gen-openapi
  '';

  processes = {
    backend.exec = "cd ${config.devenv.root}/backend-rs && cargo watch -x run";
    frontend = {
      exec = "cd ${config.devenv.root}/frontend && elm-land server";
      process-compose.disabled = config.container.isBuilding;
    };
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

  pre-commit.settings.rust.cargoManifestPath = "./backend-rs/Cargo.toml";
  pre-commit.hooks = {
    rustfmt.enable = true;
    shellcheck.enable = true;
    nixpkgs-fmt.enable = true;
    elm-format.enable = true;
  };
}
