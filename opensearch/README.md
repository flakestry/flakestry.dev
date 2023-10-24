$ env=staging
$ flyctl apps create flakestry-$env-opensearch
$ flyctl deploy -a flakestry-$env-opensearch
$ flyctl scale vm shared-cpu-2x --vm-memory 4096 -a flakestry-$env-opensearch