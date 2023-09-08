# Setting up fly.io

```
$ flyctl apps create flakestry-staging
$ flyctl deploy --vm-memory 4096 -a flakestry-staging --image registry.fly.io/flakestry-staging:latest

$ fly postgres create
> name: flakestry-postgres
...

$ flyctl postgres attach --app flakestry flakestry-postgres
```

Follow https://micahjon.com/2022/proxy-flyio-cloudflare/