# The site is plain files, served by nginx with Netlify's URL rules
# (nginx.conf). It runs on jiji, behind Caddy and the Cloudflare tunnel.
FROM mirror.gcr.io/nginxinc/nginx-unprivileged:1.30-alpine@sha256:15c994d10d6d78658721c3bcafff14cb281fba2a4bdf9d5ba92c416a472516e3

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --link index.html robots.txt /srv/site/
COPY --link assets /srv/site/assets

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=5s --start-period=10s \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
