# The site is plain files, served by nginx with Netlify's URL rules
# (nginx.conf). It runs on jiji, behind Caddy and the Cloudflare tunnel.
FROM mirror.gcr.io/nginxinc/nginx-unprivileged:1.30-alpine@sha256:56b8272e43a0525f67aed68d1e0794a712d10e3e45a563e118e9a77c817e6f86

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --link index.html robots.txt /srv/site/
COPY --link assets /srv/site/assets

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=5s --start-period=10s \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
