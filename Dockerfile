# The site is plain files, served by nginx with Netlify's URL rules
# (nginx.conf). It runs on jiji, behind Caddy and the Cloudflare tunnel.
FROM mirror.gcr.io/nginxinc/nginx-unprivileged:1.30-alpine@sha256:f5116ed4606f3eb015dd4a8e28cb9b351476dc0ad4bc6e9f93b19cec130cdf03

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --link index.html robots.txt /srv/site/
COPY --link assets /srv/site/assets

EXPOSE 8080
HEALTHCHECK --interval=60s --timeout=5s --start-period=10s \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1
