# Discourse on Railway

Railway template for [Discourse](https://www.discourse.org/), the open-source discussion forum, with PostgreSQL (pgvector) and Redis.

This repo is what the template builds. Each service has its own folder:

| Folder | Service | What it is |
|---|---|---|
| `discourse/` | **Discourse** | Discourse's own prebuilt image `discourse/discourse:2026.11.0-latest.1`, pinned by digest, plus a one-time first-admin step |
| `postgres/` | **Postgres** | PostgreSQL 18.7 with pgvector 0.8.7 (`pgvector/pgvector:0.8.7-pg18-trixie`, pinned by digest). Discourse's bundled Discourse AI plugin needs the `vector` extension |
| (none) | **Redis** | Railway's Redis database service |

## What you get

- **Discourse 2026.11.0-latest.1**, from the `latest` release channel, which Discourse uses by default for production installs. nginx, the Rails app (unicorn) and Sidekiq run in one container, as in Discourse's standard install.
- **Admin ready on first boot, no mail server needed.** When the database is first set up, an admin account is created for the email in `DISCOURSE_DEVELOPER_EMAILS`, with the password in `ADMIN_PASSWORD` (a random 32-character secret generated at deploy time; find it in the Discourse service's Variables tab). Log in with the email address and that password. There is no default password.
- **Persistent data:** uploads, backups and logs on a volume at `/shared`; the database on a volume at `/var/lib/postgresql`; Redis on its own volume.
- **HTTPS:** Railway terminates TLS; the template turns on Discourse's `force_https` setting on first boot so links and redirects use `https://`.
- **Private networking:** Discourse reaches Postgres and Redis over Railway's private network with reference variables. Neither database is exposed publicly.

## Variables (Discourse service)

| Variable | Default | Notes |
|---|---|---|
| `DISCOURSE_DEVELOPER_EMAILS` | (you enter it) | Your email. This account becomes the first admin |
| `ADMIN_PASSWORD` | `${{secret(32)}}` | Password of the first admin. Used only on the first boot: change it later in Discourse, not here |
| `DISCOURSE_HOSTNAME` | `${{RAILWAY_PUBLIC_DOMAIN}}` | Change it when you add a custom domain |
| `DISCOURSE_DB_*`, `DISCOURSE_REDIS_*` | references | Point at the Postgres and Redis services |
| `PORT` | `80` | nginx inside the image listens on 80 |

### Email (recommended after the first login)

Discourse needs an SMTP service to send sign-up confirmations, password resets and notifications. Add these to the Discourse service and redeploy:

```
DISCOURSE_SMTP_ADDRESS=smtp.example.com
DISCOURSE_SMTP_PORT=587
DISCOURSE_SMTP_USER_NAME=YOUR-SMTP-USER
DISCOURSE_SMTP_PASSWORD=YOUR-SMTP-PASSWORD
DISCOURSE_NOTIFICATION_EMAIL=noreply@YOUR-DOMAIN
```

Any variable starting with `DISCOURSE_` becomes a Discourse global setting (for example `DISCOURSE_MAXMIND_ACCOUNT_ID` and `DISCOURSE_MAXMIND_LICENSE_KEY` for IP location lookups).

## About the image

Discourse officially supports only its [standard install](https://github.com/discourse/discourse/blob/main/docs/INSTALL-cloud.md), which builds the container with the `launcher` script on a server you control. That isn't possible on Railway. This template uses `discourse/discourse`, the prebuilt image that Discourse's team builds from the same configuration and publishes daily ([build workflow](https://github.com/discourse/discourse_docker/blob/main/.github/workflows/build-web-only.yml)). As of November 2026 Discourse still describes it as experimental ([Meta discussion](https://meta.discourse.org/t/is-docker-image-discourse-discourse-considered-safe-and-production-ready/380646)). Take regular backups (Admin → Backups), and update by redeploying a new image, not with the in-app updater. Plugins can't be added to this image at runtime.

## Updates

Deployers get Railway's "update available" notice when this repo's `main` branch changes. Each change is listed in [CHANGELOG.md](CHANGELOG.md); read it before you apply an update. Discourse runs its database migrations automatically when the new version boots. Take a backup first.

## Local run

```sh
docker build -t discourse-rw discourse/ && docker build -t discourse-pg postgres/
```

Then run Postgres (with `POSTGRES_PASSWORD`, `POSTGRES_DB=discourse`), Redis and Discourse with the variables above, Discourse on port 80.
