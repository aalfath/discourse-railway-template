# Changelog

## Unreleased (2026-11-16)

- README: Deploy on Railway button for the published template `discourse-1`. No change to the images or start scripts.

## 2026.11.0-latest.1 (2026-11-16)

First release.

- Discourse 2026.11.0-latest.1: `discourse/discourse:2026.11.0-latest.1@sha256:f0984232b31ca6f4baf019d53dd252c53e5e8805f711b4616c805e4ca3cbb716`.
- PostgreSQL 18.7 with pgvector 0.8.7: `pgvector/pgvector:0.8.7-pg18-trixie@sha256:ab49524d18df7200b74ac9a475e1db6297fc1eb57da4c214c63d10ecc4b754fa`, `vector` extension created on first start.
- First admin created on first boot from `DISCOURSE_DEVELOPER_EMAILS` and the generated `ADMIN_PASSWORD`; `force_https` turned on.
- nginx: Debian's default site is removed at boot, so requests on port 80 reach Discourse on Railway too.
- Volumes: Discourse `/shared`, Postgres `/var/lib/postgresql`.
