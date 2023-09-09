# Setting up fly.io

```
$ flyctl apps create flakestry-staging
$ flyctl deploy --vm-memory 4096 -a flakestry-staging --image registry.fly.io/flakestry-staging:latest --env FLAKESTRY_URL https://staging.flakestry.dev

$ fly postgres create
> name: flakestry-postgres
...

$ flyctl postgres attach --app flakestry-staging flakestry-postgres
```

Follow https://micahjon.com/2022/proxy-flyio-cloudflare/