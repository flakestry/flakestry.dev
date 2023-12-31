# ruff: noqa
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
            meta_data={
                "description": "test description",
                "lastModified": 1698341678,
                "locked": {
                    "lastModified": 1698341678,
                    "narHash": "sha256-GhD0THsY8SvP7j4GKP0guSldv7rtXSZGvkx6oYh/iz4=",
                    "ref": "refs/heads/main",
                    "rev": "f8f9f95b9f4cf91f6ad552132f196741daf3b1ad",
                    "revCount": 6,
                    "type": "git",
                    "url": "file:///home/domen/dev/flakestry-publish-test",
                },
                "locks": {
                    "nodes": {
                        "nixpkgs": {
                            "locked": {
                                "lastModified": 1693771906,
                                "narHash": "sha256-32EnPCaVjOiEERZ+o/2Ir7JH9pkfwJZJ27SKHNvt4yk=",
                                "owner": "NixOS",
                                "repo": "nixpkgs",
                                "rev": "da5adce0ffaff10f6d0fee72a02a5ed9d01b52fc",
                                "type": "github",
                            },
                            "original": {
                                "owner": "NixOS",
                                "ref": "nixos-23.05",
                                "repo": "nixpkgs",
                                "type": "github",
                            },
                        },
                        "root": {"inputs": {"nixpkgs": "nixpkgs"}},
                    },
                    "root": "root",
                    "version": 7,
                },
                "original": {
                    "type": "git",
                    "url": "file:///home/domen/dev/flakestry-publish-test",
                },
                "originalUrl": "git+file:///home/domen/dev/flakestry-publish-test",
                "path": "/nix/store/y64za3z1hg7d1mp57mh0wwhagys28ywf-source",
                "resolved": {
                    "type": "git",
                    "url": "file:///home/domen/dev/flakestry-publish-test",
                },
                "resolvedUrl": "git+file:///home/domen/dev/flakestry-publish-test",
                "revCount": 6,
                "revision": "f8f9f95b9f4cf91f6ad552132f196741daf3b1ad",
                "url": "git+file:///home/domen/dev/flakestry-publish-test?ref=refs/heads/main&rev=f8f9f95b9f4cf91f6ad552132f196741daf3b1ad",
            },
            meta_data_errors="",
            outputs={
                "apps": {"x86_64-linux": {"default": {"type": "app"}}},
                "checks": {
                    "x86_64-linux": {
                        "git": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        }
                    }
                },
                "devShells": {
                    "x86_64-linux": {
                        "default": {
                            "description": "Nix code formatter for nixpkgs",
                            "name": "nixpkgs-fmt-1.3.0",
                            "type": "derivation",
                        }
                    }
                },
                "formatter": {
                    "x86_64-linux": {
                        "description": "Nix code formatter for nixpkgs",
                        "name": "nixpkgs-fmt-1.3.0",
                        "type": "derivation",
                    }
                },
                "nixosConfigurations": {"myhostname": {"type": "nixos-configuration"}},
                "nixosModules": {"myhostname": {"type": "nixos-module"}},
                "overlays": {"myoverlay": {"type": "nixpkgs-overlay"}},
                "packages": {
                    "x86_64-darwin": {
                        "git": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git2": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git3": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git4": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git5": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git6": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git7": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git8": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git9": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git10": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "git11": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                    },
                    "x86_64-linux": {
                        "git": {
                            "description": "Distributed version control system",
                            "name": "git-2.40.1",
                            "type": "derivation",
                        },
                        "vim": {
                            "description": "The most popular clone of the VI editor",
                            "name": "vim-9.0.1441",
                            "type": "derivation",
                        },
                    },
                },
                "templates": {
                    "default": {"description": "template test", "type": "template"}
                },
            },
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
            outputs={
                "checks": {
                    "x86_64-linux": {
                        "pre-commit-check": {
                            "name": "pre-commit-run",
                            "type": "derivation",
                        }
                    }
                },
                "overlay": {"type": "nixpkgs-overlay"},
                "packages": {
                    "x86_64-linux": {
                        "mlir": {"name": "mlir-6d43651", "type": "derivation"},
                        "jless": {"name": "jless-v0.7.1", "type": "derivation"},
                        "qprez": {"name": "r-qprez", "type": "derivation"},
                        "daphne": {"name": "daphne-0.1", "type": "derivation"},
                        "pajeng": {"name": "pajeng", "type": "derivation"},
                        "starpu": {"name": "starpu", "type": "derivation"},
                        "topo5k": {"name": "topo5k", "type": "derivation"},
                        "vanidl": {"name": "python3.10-vanidl", "type": "derivation"},
                        "ondes3d": {"name": "ondes3d", "type": "derivation"},
                        "pajengr": {"name": "r-pajengr", "type": "derivation"},
                        "recorder": {"name": "Recorder", "type": "derivation"},
                        "snakefmt": {
                            "name": "python3.10-snakefmt-v0.8.0",
                            "type": "derivation",
                        },
                        "antlr-cpp": {"name": "antlr-cpp-master", "type": "derivation"},
                        "freetype2": {"name": "freetype2", "type": "derivation"},
                        "ggpattern": {"name": "r-ggpattern", "type": "derivation"},
                        "madbench2": {"name": "MADbench2", "type": "derivation"},
                        "pydarshan": {
                            "name": "python3.10-pydarshan",
                            "type": "derivation",
                        },
                        "globus-cli": {
                            "name": "python3.10-globus-cli",
                            "type": "derivation",
                        },
                        "globus-sdk": {
                            "name": "python3.10-globus-sdk",
                            "type": "derivation",
                        },
                        "httpimport": {
                            "name": "python3.10-httpimport",
                            "type": "derivation",
                        },
                        "facetscales": {"name": "r-facetscales", "type": "derivation"},
                        "ior-simgrid": {
                            "name": "ior-simgrid-3.3.0",
                            "type": "derivation",
                            "description": "Parallel file system I/O performance test",
                        },
                        "smpi_replay": {"name": "smpi_replay", "type": "derivation"},
                        "darshan-perl": {
                            "name": "perl-5.36.0-env",
                            "type": "derivation",
                            "description": "The standard implementation of the Perl 5 programmming language",
                        },
                        "darshan-util": {"name": "darshan-util", "type": "derivation"},
                        "geomtextpath": {
                            "name": "r-geomtextpath",
                            "type": "derivation",
                        },
                        "recorder-viz": {
                            "name": "python3.10-recorder-viz",
                            "type": "derivation",
                        },
                        "hackernewsTUI": {
                            "name": "hackernews-TUI-v0.7.1",
                            "type": "derivation",
                        },
                        "myTextshaping": {
                            "name": "r-textshaping",
                            "type": "derivation",
                        },
                        "python-control": {
                            "name": "python3.10-python-control-0.9.2",
                            "type": "derivation",
                        },
                        "uga_thesis_rmd": {
                            "name": "r-uga_thesis_rmd",
                            "type": "derivation",
                        },
                        "darshan-runtime": {
                            "name": "darshan-runtime",
                            "type": "derivation",
                        },
                        "madbench2-darshan": {
                            "name": "MADbench2",
                            "type": "derivation",
                        },
                        "globus-connect-personal": {
                            "name": "globus-connect-personal",
                            "type": "derivation",
                        },
                    }
                },
                "devShells": {
                    "x86_64-linux": {
                        "check": {"name": "nix-shell", "type": "derivation"},
                        "shell-R": {"name": "R", "type": "derivation"},
                        "shell-lua": {"name": "lua", "type": "derivation"},
                        "shell-julia": {"name": "julia", "type": "derivation"},
                        "shell-python": {"name": "python", "type": "derivation"},
                    }
                },
                "templates": {
                    "C": {"type": "template", "description": "a simple C template"},
                    "R": {"type": "template", "description": "R and friends"},
                    "md": {
                        "type": "template",
                        "description": "a Markdown + Pandoc template",
                    },
                    "Rmd": {"type": "template", "description": "a RMarkdown template"},
                    "QPrez": {"type": "template", "description": "a QPrez template"},
                    "python": {
                        "type": "template",
                        "description": "a Python3.8 template",
                    },
                    "default": {"type": "template", "description": "basic shell"},
                },
            },
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
            "description": release.repo.description,
            "readme": release.readme,
            "outputs": str(release.outputs),
            "repo": release.repo.name,
            "owner": release.repo.owner.name,
        }
        opensearch.index(
            index=opensearch_index, body=document, id=release.id, refresh=True
        )


if __name__ == "__main__":
    main()
