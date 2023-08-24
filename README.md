# flakestry.dev

(TODO: generated with gpt, revise)

## Flakes are the future of Nix development.

Flakes are a new package management feature introduced in the Nix ecosystem. They're essentially composable, reproducible Nix projects. With flakes, it becomes easier to manage Nix projects, dependencies, and to create reproducible builds. They help users avoid "dependency hell" by clearly specifying and isolating dependencies. By saying they are the "future of Nix development", it implies that the Nix community sees a significant benefit in adopting them, as they may offer a more streamlined, efficient, and reliable way to handle Nix projects compared to traditional methods.

## Discoverability and registry is important.

A registry is like a central directory where users can find and fetch various software packages or projects. For a package management system, discoverability refers to how easy it is for users to find and utilize the packages or projects they need. If you have a well-maintained and organized registry, users can easily discover, share, and utilize software. This in turn enhances the user experience, fosters collaboration, and helps the ecosystem grow.

## Flakeshub.

Flakeshub, as per the context, seems like a platform or hub related to Nix flakes. It might be designed to provide a centralized place for users to discover and access flakes. Such platforms are integral for any package management ecosystem because they simplify the process of sharing and discovering new packages, thus promoting collaboration and growth within the community.

## Flakes are experimental, but it's important that we have an OSS (Open Source Software) implementation of the registry.

Even though flakes are still in an experimental phase, it's crucial for the Nix community to have an open-source implementation of the registry. Open-source means that the source code is freely available and can be modified and shared. This encourages community collaboration, ensuring that the registry meets the needs of its users and can be improved upon by the collective knowledge and skills of the community.

## Today it lives on flakestry.dev, but we hope to upstream it to flakestry.nix.dev.

This suggests that the current registry or related platform for flakes is hosted on the domain "flakestry.dev." However, there is an ambition to move or replicate it to a more official or recognized domain, "flakestry.nix.dev." This could mean that as the feature becomes more mature or accepted within the community, it might be integrated more closely with other official Nix tools or platforms.

In summary, the Nix community sees potential in the flakes system as a way to improve and modernize Nix development. The establishment and maintenance of a central registry, potentially in the form of Flakeshub, is a crucial part of this vision. And even though flakes are still in an experimental stage, having an open-source registry ensures transparency, trust, and community-driven improvements. The mention of domain changes suggests that there are ongoing efforts to make this system more mainstream and official within the Nix ecosystem.

## Development

1. [Install direnv](https://direnv.net/docs/installation.html)
2. `nix profile install --accept-flake-config tarball+https://install.devenv.sh/latest`
2. `direnv allow .`

## TODO

- [ ] action to publish: evaluate, get flake metadata, outputs
- [ ] /publish
- [ ] /flake
- [ ] /flake/{owner}
- [ ] /flake/{owner}/{repo}
- [ ] /search (opensearch)
- [ ] fly.io deployment: staging.flakestry.dev, flakestry.dev

## Roadmap

- [ ] Implement a prototype of [semantic versioning of flakes](https://github.com/NixOS/rfcs/pull/144).

- [ ] Hook up [NixOS infra building infrastructure](https://nixos.org/community/teams/infrastructure.html) to build flakes and publish the binaries.