# Setting up fly.io

Begin with opensearch/README.md

```
$ flyctl apps create flakestry-staging
$ deploy-staging
$ flyctl ext sentry create 

$ fly postgres create
> name: flakestry-postgres
...

$ flyctl postgres attach --app flakestry-staging flakestry-postgres
```

Follow https://micahjon.com/2022/proxy-flyio-cloudflare/