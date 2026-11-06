# Feature Control: Hosted

## Quick-Start

```sh
$ docker run \
    --env DATABASE_TYPE=SqliteMemory \
    --env ORIGIN=http://localhost:8000 \
    -p 8000:8000 \
    ghcr.io/zalphion/feature-control:latest
```

## Pricing

Feature Control is available with a limited free tier, or as a one-time purchase.
A purchase entitles you to a year's worth of support and upgrades;
extensions can be purchased at signficant discount.

See [TODO](TODO) for details.

## Environment Variables

| Name                        | Required    | Description                                                                                                                                                             |
| --------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ORIGIN                      | Yes         | The base URI that users will access the service with. e.g. `https://features.acme.corp:8443`                                                                            |
| DATABASE_TYPE               | Yes         | Permitted values: `Postgresql`, `Sqlite`, and `SqliteMemory`                                                                                                            |
| DATABASE_URI                | Conditional | Required when `DATABASE_TYPE` is `Postgresql`. Requires a virtual database to be selected; schema is optional. e.g. `postgresql://mydb:5432/corp?current_schema=public` |
| DATABASE_USERNAME           | Conditional | Required when `DATABASE_TYPE` is `Postgresql`. Requires full control over the selected schema                                                                           |
| DATABASE_PASSWORD           | Conditional | Required when `DATABASE_TYPE` is `Postgresql`                                                                                                                           |
| DATABASE_PATH               | Conditional | Required when `DATABASE_TYPE` is `Sqlite`. Control location of the sqlite database file. WARNING: Should use an attached volume                                         |
| PORT                        | No          | Port the web service will bind to. **Default**: `8000`                                                                                                                  |
| PASSWORD_AUTHENTICATION     | No          | Prefer disabled in favour of Social Login. Permitted values: `true`, `false`. **Default**: `false`                                                                      |
| USER_SELF_REGISTRATION      | No          | Permit users to register their own accounts. **Default**: `true`                                                                                                        |
| SESSION_LENGTH              | No          | **ISO8601 Duration**. Length of a web session before it expires. **Default**: `P7D`                                                                                     |
| INVITATION_RETENTION_LENGTH | No          | **ISO8601 Duration**. How long until a team invitation expires. **Default**: `P7D`                                                                                      |
| SDK_CACHE_MAX_AGE           | No          | **ISO8601 Duration**. `max-age` cache-control directive. Higher means greater cache efficiency at the risk of larger drift. **Default**: `PT10S`                        |
| SDK_ACTIVE_TIMEOUT          | No          | **ISO8601 Duration**. How long without contact until an SDK is considered disconnected. **Default**: `PT10M`                                                            |
| SUPER_ADMIN_EMAILS          | No          | Give super admins privileges. e.g. `john@acme.com,jane@acme.com`                                                                                                        |
| GOOGLE_CLIENT_ID            | No          | Enables Google Social Login                                                                                                                                             |
| GITHUB_CLIENT_ID            | No          | Enables GitHub Social Login                                                                                                                                             |
| GITLAB_CLIENT_ID            | No          | Enables GitLab Social Login                                                                                                                                             |
| MICROSOFT_CLIENT_ID         | No          | Enables Microsoft Social Login                                                                                                                                          |
| WORKER_CONCURRENCY          | No          | Limit the number of parallel worker tasks. **Default**: 8                                                                                                               |
| GOOGLE_CLIENT_SECRET        | Conditional | Required when `GOOGLE_CLIENT_ID` is set                                                                                                                                 |
| GITHUB_CLIENT_SECRET        | Conditional | Required when `GITHUB_CLIENT_ID` is set                                                                                                                                 |
| GITLAB_CLIENT_SECRET        | Conditional | Required when `GITLAB_CLIENT_ID` is set                                                                                                                                 |
| MICROSOFT_CLIENT_SECRET     | Conditional | Required when `MICROSOFT_CLIENT_ID` is set                                                                                                                              |
| SMTP_HOST                   | Conditional | Required when `PASSWORD_AUTHENTICATION` is true. Hostname for your own SMTP server to send user management emails.                                                      |
| SMTP_PORT                   | No          | **Default**: 25                                                                                                                                                         |
| SMTP_TLS_MODE               | Conditional | Required when `SMTP_HOST` is set. Permitted values: `None`, `StartTls`, `SslOnConnect`.                                                                                 |
| SMTP_FROM_ADDRESS           | Conditional | Required when `SMTP_HOST` is set. The FROM address for user management emails.                                                                                          |
| SMTP_USERNAME               | No          | If your SMTP server requires authentication, provide the username.                                                                                                      |
| SMTP_PASSWORD               | Conditional | Required when `SMTP_USERNAME` is set.                                                                                                                                   |

## Database Support

### Postgresql

When in doubt, use Postgres. It's required when you want:

- multi-node deployments
- application replicas for performance and reliability
- automated backups and recovery from your RDBMS

### Sqlite

A simple, file-based database that's ideal for small-scale deployments.
Ensure you use a persistent volume, or you'll lose data when the container restarts.

### SqliteMemory

Only use for testing. You'll always lose data when the container restarts.

## Ports & Networking

| Port   | Protocol | Environment Variable | Description                    |
| ------ | -------- | -------------------- | ------------------------------ |
| `8000` | TCP      | `PORT`               | User HTTP traffic: Web UI, API |

## Docker Tags & Versioning

We follow [Semantic Versioning](https://semver.org/).

- `1.2.3`: Pinned to an exact patch release
- `1.2`: Tracks the latest patch for a specific minor version (recommended)
- `1`: Tracks the latest minor version for a specific major version
- `latest`: Tracks the latest stable release
- `snapshot`: Tracks the latest passing build

## Source Availability

The [Dockerfile](https://github.com/Zalphion/FeatureControl-Server/blob/main/Dockerfile)
and [Release Pipeline](https://github.com/Zalphion/FeatureControl-Server/blob/main/.github/workflows/release.yml)
are publicly available for your inspection.  The source code of the application itself is proprietary and unavailable.

## Deployment

If you're contemplating a self-hosted deployment, then we'll defer to you on all the infrastructure decisions.
If you're unsure how to deploy a production-ready docker application, then the
[Cloud Edition](https://cloud.featurecontrol.app) will be a better fit for you.
