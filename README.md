# Feature Control

> The Pragmatic Feature Management Platform for Developers

- **Feature Flags**: with Advanced Rollout Strategies and Audiences
- **Dynamic Config**: Keep your application subscribed to updates
- **Low Cost**: Flat Pricing with a full-featured Free Tier

## Editions

### Cloud

> Let us do the heavy lifting for you.  Simple and efficient.

Get started with a free account at https://cloud.featurecontrol.app

### Hosted

> Host on your own network.  Buy it once and keep it forever.

Read [HOSTED.md](https://github.com/Zalphion/FeatureControl-Server/blob/main/HOSTED.md) to get started, 
or get your hands dirty right now.

```sh
$ docker run \
    --env DATABASE_TYPE=SqliteMemory \
    --env ORIGIN=http://localhost:8000 \
    -p 8000:8000 \
    ghcr.io/zalphion/feature-control:latest
```
