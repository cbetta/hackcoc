# The site is plain files, served by nginx with Netlify's URL rules
# (nginx.conf). It runs on jiji, behind Caddy and the Cloudflare tunnel.
FROM nginxinc/nginx-unprivileged:1.30-alpine@sha256:ed04ec1ff34502c339ee5c3ae3f855442398edc1d05591e2b98981dcbbd20b1e

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --link index.html robots.txt /srv/site/
COPY --link assets /srv/site/assets

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=5s --start-period=10s \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
