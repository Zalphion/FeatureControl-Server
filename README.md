# Feature Control

> The Pragmatic Feature Management Platform for Developers

- **Feature Flags**: with Advanced Rollout Strategies and Audiences
- **Dynamic Config**: Keep your application subscribed to updates
- **Low Cost**: Flat Pricing with a full-featured Free Tier
- **Postgres Server Optional**: Sometimes you just can't beat Sqlite
- **Distroless & Secure**: No shell, package manager, or extra binaries
- **No Security Theatre**: Any "master secret key" is just a pretence at confidentiality


## Quick-Start

```sh
$ docker run \
    --env DATABASE_TYPE=SqliteMemory \
    --env ORIGIN=http://localhost:8000 \
    -p 8000:8000 \
    zalphion/feature-control:latest
```

## Environment Variables

| Name                        | Type               | Required    | Default           | Description                                                                                                                                                                 |
|-----------------------------|--------------------|-------------|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ORIGIN                      | URI                | Yes         |                   | The base URI that users will access the service with.  e.g. https://features.acme.corp:8443                                                                                 |
| DATABASE_TYPE               | Option             | Yes         |                   | Supports `Postgresql`, `Sqlite`, and `SqliteMemory`                                                                                                                         |
| DATABASE_URI                | URI                | Conditional |                   | Required when `DATABASE_TYPE` is `Postgresql`.<br/>Requires a virtual database to be selected; schema is optional. e.g. `postgresql://mydb:5432/corp?current_schema=public` |
| DATABASE_USERNAME           | String             | Conditional |                   | Required when `DATABASE_TYPE` is `Postgresql`.<br/>Requires full control over the selected schema                                                                           |
| DATABASE_PASSWORD           | String             | Conditional |                   | Required when `DATABASE_TYPE` is `Postgresql`                                                                                                                               |
| DATABASE_PATH               | Path               | Conditional |                   | Required when `DATABASE_TYPE` is `Sqlite`.<br/>Control location of the sqlite database file.  WARNING: Should be an attached volume                                         |
| PORT                        | UInt               | No          | `8000`            | Port the web service will bind to                                                                                                                                           |
| ADMIN_PORT                  | UInt               | No          | `8001`            | Port the internal Admin API will bind to                                                                                                                                    |
| PASSWORD_AUTHENTICATION     | Boolean            | No          | `false`           | Prefer disabled in favour of Social Login                                                                                                                                   |
| BCRYPT_COST                 | Option             | No          | `12`              | Cost factor for BCrypt KDF operations. Permitted values: `4`, `8`, `10`, `12`, `14`, and `16`                                                                               |
| USER_SELF_REGISTRATION      | Boolean            | No          | `true`            | Require accounts to be provisioned by a super admin                                                                                                                         |
| APP_TITLE                   | String             | No          | `Feature Control` | Friendly name for the application                                                                                                                                           |
| SESSION_LENGTH              | ISO 8601 Duration  | No          | `P7D`             | Length of a web session before it expires                                                                                                                                   |
| INVITATION_RETENTION_LENGTH | ISO 8601 Duration  | No          | `P7D`             | How long until a team invitation expires                                                                                                                                    |
| PAGE_SIZE                   | UInt               | No          | `100`             | Internal page size for listing operation                                                                                                                                    |
| SDK_CACHE_MAX_AGE           | ISO 8601 Duration  | No          | `PT10S`           | `max-age` cache-control directive.  Higher means greater cache efficiency at the risk of larger drift                                                                       |
| SDK_ACTIVE_TIMEOUT          | ISO 8601 Duration  | No          | `PT10M`           | How long without contact until an SDK is considered disconnected                                                                                                            |
| SUPER_ADMIN_EMAILS          | List<EmailAddress> | No          |                   | Entitles the users with the given email addresses to be super admins                                                                                                        |
| GOOGLE_CLIENT_ID            | String             | No          |                   | Enables Google Social Login                                                                                                                                                 |
| GITHUB_CLIENT_ID            | String             | No          |                   | Enables GitHub Social Login                                                                                                                                                 |
| GITLAB_CLIENT_ID            | String             | No          |                   | Enables GitLab Social Login                                                                                                                                                 |
| MICROSOFT_CLIENT_ID         | String             | No          |                   | Enables Microsoft Social Login                                                                                                                                              |
| GOOGLE_CLIENT_SECRET        | String             | Conditional |                   | Required when `GOOGLE_CLIENT_ID` is set                                                                                                                                     |
| GITHUB_CLIENT_SECRET        | String             | Conditional |                   | Required when `GITHUB_CLIENT_ID` is set                                                                                                                                     |
| GITLAB_CLIENT_SECRET        | String             | Conditional |                   | Required when `GITLAB_CLIENT_ID` is set                                                                                                                                     |
| MICROSOFT_CLIENT_SECRET     | String             | Conditional |                   | Required when `MICROSOFT_CLIENT_ID` is set                                                                                                                                  |


## Database Support

### Postgresql

When in doubt, use this.  While sqlite is simpler, if you ever need to upgrade, you'll need to perform a migration.
Postgresql is required when you:

- want multi-node deployments
- want to leverage high availability and failover
- want to take advantage of the automated backups and recovery provided by your RBDMS
- reach a certain scale where sqlite becomes a bottleneck


### Sqlite

A simple, file-based database that's ideal for small-scale deployments.
Just ensure you use a persistent volume, or you'll lose data when the container restarts.
You are also in charge of automated backups and recovery, where a postgresql RBDMS might handle this for you.


### SqliteMemory

Only use this for testing.  You'll always lose data when the container restarts.


## Ports & Networking

| Port   | Protocol | Default Config    | Scope    | Description                                       |
|--------|----------|-------------------|----------|---------------------------------------------------|
| `8000` | TCP      | `PORT=8000`       | Primary  | User HTTP traffic: Web UI, API                    |
| `8001` | TCP      | `ADMIN_PORT=8001` | Internal | Not to be exposed.  See [System CLI](#system-cli) |


## System CLI

Feature Control is a distroless container; it does not contain a shell, nor any binaries beyond a stripped Java runtime.
Instead, the System CLI supports container health check and recovery via `docker exec`.

```shell
$ docker exec <container_name_or_id> java -jar app.jar --help
Usage: system [<options>] <command> [<args>]...

Options:
  -h, --help  Show this message and exit

Commands:
  start-server
  create-user
  generate-user-recovery-code
  check-health
```

The `start-server` and `check-health` commands are used internally by the Dockerfile,
but the remainder will be explained below.


### Bootstrapping when USER_SELF_REGISTRATION is Disabled

With `USER_SELF_REGISTRATION` set to `false`, there's a chicken-and-the-egg problem.
If users can't register themselves, how do you create the initial super admin?
First, ensure you have `SUPER_ADMIN_EMAILS` populated.
Then use the system CLI to create the initial user.

```sh
$ docker exec <container_id> \
    java -jar app.jar \
    create-user \
    --email-address john@acme.com
UserDto(id=3JpHFzRsyakZh3Jb1fCHN5Xlo9X, emailAddress=john@acme.com, name=john@acme.com, locale=en_CA)
```

If you have Social Login enabled, you can end here and login normally.  Otherwise, proceed to [Password Recovery](#password-recovery)


### Password Recovery

If you don't have Social Login enabled, forgetting a password requires super admin intervention.
But if you're a super admin, you can use the system CLI to generate a user recovery code,
which can be used to reset the password on the login page.

```sh
$ docker exec <container_id> \
    java -jar app.jar \
    generate-user-recovery-code \
    --email-address john@acme.com
CreatedRecoveryCodeDto(userId=3JpHFzRsyakZh3Jb1fCHN5Xlo9X, secret=xLqO06ApfXQ5CWRT, expires=2026-09-25T16:43:25.131351306Z)
```

## Docker Tags & Versioning

We follow [Semantic Versioning](https://semver.org/).
- `1.2.3`: Pinned to an exact patch release
- `1.2`: Tracks the latest patch for a specific minor version  (recommended)
- `1`: Tracks the latest minor version for a specific major version
- `latest`: Tracks the latest stable release
- `snapshot`: Tracks the latest passing build


## Docker Compose Example

A sample server running with an embedded sqlite database.
In production, you might ideally connect a feature-control replica set to an external Postgresql RDBMS cluster for superior scalability and durability.

```yaml
services:
  feature_control:
    image: zalphion/feature-control:latest
    container_name: feature-control
    environment:
      PORT: 8000
      ORIGIN: https://feature-control.mydomain.com
      DATABASE_TYPE: Sqlite
      DATABASE_PATH: /data/feature-control.db
      SUPER_ADMIN_EMAILS: john@acme.com,jane@acme.com
    ports:
      - "8000:8000"
    restart: unless-stopped
    volumes:
      - app_data:/data

volumes:
  app_data:
```
