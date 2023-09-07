from flakestry.sql import (
    create_db_and_tables,
    get_session,
    GitHubOwner,
    GitHubRepo,
    Release,
)

def main() -> None:
    session = next(get_session())

    session.exec("DROP TABLE IF EXISTS release CASCADE")
    session.exec("DROP TABLE IF EXISTS githubrepo CASCADE")
    session.exec("DROP TABLE IF EXISTS githubowner CASCADE")
    session.commit()

    create_db_and_tables()

    cachix = GitHubOwner(name="cachix")
    nixos = GitHubOwner(name="nixos")
    nix_community = GitHubOwner(name="nix-community")

    session.add(cachix)
    session.add(nixos)
    session.add(nix_community)

    cachix_repo = GitHubRepo(
        name="cachix",
        description="Cachix CLI",
        owner=cachix,
    )
    nixos_repo = GitHubRepo(
        name="nixpkgs",
        description="Nix Packages collection & NixOS",
        owner=nixos,
    )
    nix_repo = GitHubRepo(
        name="nix",
        description="Nix, the purely functional package manager",
        owner=nixos,
    )
    nix_community_repo = GitHubRepo(
        name="nix-community",
        description="",
        owner=nix_community,
    )

    session.add(cachix_repo)
    session.add(nixos_repo)
    session.add(nix_repo)
    session.add(nix_community_repo)

    cachix_release = Release(
        repo=cachix_repo,
        version="1.0.0",
        readme="<h1>Cachix</h1>",
        commit="123",
        meta_data={},
        meta_data_errors="",
        outputs={},
        outputs_errors="",
    )
    nixpkgs_release = Release(
        repo=nixos_repo,
        version="23.05",
        readme="<h1>Nixpkgs</h1>",
        commit="123",
        meta_data={},
        meta_data_errors="",
        outputs={},
        outputs_errors="",
    )

    session.add(cachix_release)
    session.add(nixpkgs_release)

    session.commit()

if __name__ == "__main__":
    main()

