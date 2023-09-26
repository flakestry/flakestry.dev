import os
from flakestry.sql import (
    create_db_and_tables,
    get_session,
    GitHubOwner,
    GitHubRepo,
    Release,
)
from flakestry.search import get_opensearch, opensearch_index

# TODO: reuse /publish logic for this
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

    pwd = os.path.dirname(__file__)
    with open(os.path.join(pwd, "seed/nixpkgs-readme.md"), "r") as f:
        readme = f.read()
        nixpkgs_release_22 = Release(
            repo=nixos_repo,
            version="22.05",
            readme=readme,
            description="nixpkgs is official package collection",
            commit="566",
            meta_data={},
            meta_data_errors="",
            outputs={},
            outputs_errors="",
        )
    with open(os.path.join(pwd, "seed/nixpkgs-readme.md"), "r") as f:
        readme = f.read()
        nixpkgs_release = Release(
            repo=nixos_repo,
            version="23.05",
            readme=readme,
            description="nixpkgs is official package collection",
            commit="123",
            meta_data={},
            meta_data_errors="",
            outputs={},
            outputs_errors="",
        )

    with open(os.path.join(pwd, "seed/home-manager-readme.md"), "r") as f:
        readme = f.read()
        home_manager_release = Release(
            repo=home_manager_repo,
            version="23.05",
            readme=readme,
            commit="123",
            meta_data={},
            meta_data_errors="",
            outputs={},
            outputs_errors="",
        )

    session.add(nixpkgs_release)
    session.add(home_manager_release)

    session.commit()

    opensearch = get_opensearch()
    opensearch.indices.delete(index=opensearch_index, ignore=[400, 404])

    for release in [nixpkgs_release, nixpkgs_release_22, home_manager_release]:
        document = {
            'description': release.repo.description,
            'readme': release.readme,
            'outputs': str(release.outputs),
        }
        opensearch.index(
            index = opensearch_index,
            body = document,
            id = release.id,
            refresh = True
        )


if __name__ == "__main__":
    main()

