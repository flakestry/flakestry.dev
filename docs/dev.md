# Setting up fly.io

1. Begin with opensearch/README.md

2. 
```
$ env=staging
$ flyctl apps create flakestry-$env
$ flyctl ext sentry create --app flakestry-$env
$ fly postgres create -n flakestry-$env-postgres
> ams

$ flyctl postgres attach --app flakestry-$env flakestry-$env-postgres
$ deploy-$env
```

3. Follow https://micahjon.com/2022/proxy-flyio-cloudflare/