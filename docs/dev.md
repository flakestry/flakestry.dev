# Setting up fly.io

Begin with opensearch/README.md

```
$ env=staging
$ flyctl apps create flakestry-$env
$ flyctl ext sentry create --app flakestry-$env
$ fly postgres create -n flakestry-$env-postgres
> ams

$ flyctl postgres attach --app flakestry-$env flakestry-$env-postgres
$ deploy-$env
```

Follow https://micahjon.com/2022/proxy-flyio-cloudflare/