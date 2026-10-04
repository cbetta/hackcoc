# The Hack Code of Conduct

See [hackcodeofconduct.org](https://hackcodeofconduct.org)

## Hosting

The site is plain files (`index.html`, `assets/`, `robots.txt`), served by
nginx on jiji, Cristiano's home server, behind its Cloudflare tunnel.
`nginx.conf` keeps Netlify's URL rules.

A push to `master` runs `.github/workflows/publish.yml`: CI, then the image
`ghcr.io/cbetta/hackcoc`, which it pins in jiji's `docker-compose.yml` to
deploy. `scripts/check.sh` checks every local link resolves;
`scripts/smoke.sh` builds the image and boots it.
