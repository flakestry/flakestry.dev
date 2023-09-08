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

    nixos = GitHubOwner(name="nixos")
    nix_community = GitHubOwner(name="nix-community")

    session.add(nixos)
    session.add(nix_community)

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
    home_manager_repo = GitHubRepo(
        name="home-manager",
        description="",
        owner=nix_community,
    )
    disko_repo = GitHubRepo(
        name="disko",
        description="Format disks with nix-config [maintainer=@Lassulus]",
        owner=nix_community,
    )

    session.add(nixos_repo)
    session.add(nix_repo)
    session.add(home_manager_repo)
    session.add(disko_repo)

    nixpkgs_release = Release(
        repo=nixos_repo,
        version="23.05",
        readme="<h1>Nixpkgs</h1>\n<p>Some text</p>",
        commit="123",
        meta_data={},
        meta_data_errors="",
        outputs={},
        outputs_errors="",
    )
    home_manager_release = Release(
        repo=home_manager_repo,
        version="23.05",
        readme="<h1>Home Manager</h1>",
        commit="123",
        meta_data={},
        meta_data_errors="",
        outputs={},
        outputs_errors="",
    )

    session.add(nixpkgs_release)
    session.add(home_manager_release)

    session.commit()

if __name__ == "__main__":
    main()

