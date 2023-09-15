https://hub.docker.com/r/opensearchproject/opensearch

$ flyctl apps create flakestry-staging-opensearch
$ flyctl deploy -a flakestry-staging-opensearch
$ flyctl scale vm shared-cpu-2x --vm-memory 4096 -a flakestry-staging-opensearch