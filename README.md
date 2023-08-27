# flakestry.dev

A public registry of Nix flakes aiming to replace [search.nixos.org](https://search.nixos.org/flakes).

Built using [elm.land](https://elm.land/) and [FastAPI](https://fastapi.tiangolo.com/).

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

4. Start the development server:

   ```bash
   devenv up
   ```

## TODO

- [ ] fly.io deployment: staging.flakestry.dev, flakestry.dev
- [ ] action to publish: evaluate, get flake metadata, outputs
- [ ] /publish
- [ ] /flake/github/{owner}
- [ ] /flake/github/{owner}/{repo}
- [ ] /search (opensearch)

## Roadmap

- [ ] Prototype [semantic versioning of flakes](https://github.com/NixOS/rfcs/pull/144).

- [ ] [Show flake metadata like dependencies and packages for each flake](https://github.com/flakestry/flakestry.dev/issues/2).

- [ ] [Support uploading non-github flakes](https://github.com/flakestry/flakestry.dev/issues/1).