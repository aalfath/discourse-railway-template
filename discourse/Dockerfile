# Discourse 2026.11.0-latest.1 (the "latest" release channel, Discourse's default for production),
# from Discourse's own prebuilt image, pinned by digest.
FROM discourse/discourse:2026.11.0-latest.1@sha256:f0984232b31ca6f4baf019d53dd252c53e5e8805f711b4616c805e4ca3cbb716

# One-time first-admin setup: a runit service that waits until Discourse answers,
# then creates the admin account from DISCOURSE_DEVELOPER_EMAILS and ADMIN_PASSWORD.
COPY first-admin.rb /usr/local/share/railway/first-admin.rb
COPY first-admin-run /etc/service/railway-first-admin/run

# Debian's default nginx site would catch every request on port 80 with a 404.
# Removed at build time and again at boot (on Railway the image's deletion can be undone).
COPY remove-default-site /etc/runit/1.d/00-remove-default-site
RUN chmod 0755 /etc/service/railway-first-admin/run /etc/runit/1.d/00-remove-default-site \
 && rm -f /etc/nginx/sites-enabled/default

# nginx inside the image listens on port 80 (Railway: PORT=80). Data lives in /shared (volume).
EXPOSE 80
CMD ["/sbin/boot"]
