https://hub.docker.com/r/opensearchproject/opensearch

$ flyctl apps create flakestry-opensearch-staging
$ flyctl deploy --vm-memory 4096 -a flakestry-opensearch-staging