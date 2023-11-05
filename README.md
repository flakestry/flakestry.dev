# [flakestry.dev](https://flakestry.dev)

A public registry of Nix flakes aiming to supersede [search.nixos.org](https://search.nixos.org/flakes).

Built using [elm.land](https://elm.land/) and [FastAPI](https://fastapi.tiangolo.com/).

Maintainers: [@domenkozar](https://github.com/domenkozar).

## Development

1. [Install direnv](https://direnv.net/docs/installation.html)

2. [Install devenv](https://devenv.sh/getting-started/)

   ```bash
   nix profile install --accept-flake-config tarball+https://install.devenv.sh/latest
   ```

3. Load the development environment:

   ```bash
   direnv allow
   ```

4. Generate the Elm API:

    ```bash
    devenv shell generate-elm-api
    ```

5. Start the development server:

   ```bash
   devenv up
   ```

## Roadmap

- [x] [Show flake metadata like dependencies and packages for each flake](https://github.com/flakestry/flakestry.dev/issues/2).

- [ ] [Support uploading non-github flakes](https://github.com/flakestry/flakestry.dev/issues/1).

- [ ] Prototype [semantic versioning of flakes](https://github.com/NixOS/rfcs/pull/144).
