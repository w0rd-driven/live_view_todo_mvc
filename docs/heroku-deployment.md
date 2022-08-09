# Heroku Deployment

### Table of Contents

* [Supported Builds](#supported-builds)
* [Instructions](#instructions)

## Supported Builds

It wasn't terribly easy to find the supported builds for OTP. While the url below from the Phoenix Framework documentation points to the Github repository, the [Version Support](https://github.com/HashNuke/heroku-buildpack-elixir#version-support) heading is what we're really after as we're currently on the `heroku-20` stack.

[Supported Erlang/OTP versions](https://repo.hex.pm/builds/otp/ubuntu-20.04/builds.txt).

## Instructions

We're following along with [the official documentation](https://hexdocs.pm/phoenix/1.5.9/heroku.html) with supplemental notes from [Deploy Elixir Phoenix to Heroku Containers with Docker](https://staknine.com/deploy-elixir-phoenix-heroku-containers-docker/) on StakNine.

1. Get the `heroku` CLI installed locally
2. Run `heroku create --buildpack hashnuke/elixir` to add the `Elixir Buildpack`.
    1. This should create a new host url. Replace `pacific-savannah-85771.herokuapp.com` with this value in all places used below.
3. Create `elixir_buildpack.config` that matches our `.tool-versions` file used by the `asdf` version manager.

    ```shell
    # Elixir version
    elixir_version=1.12.2

    # Erlang version
    # available versions https://github.com/HashNuke/heroku-buildpack-elixir-otp-builds/blob/master/otp-versions
    erlang_version=24.0.3
    ```

4. Run `heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git` to add the `Phoenix Server and Assets Buildpack`.
5. Create `phoenix_static_buildpack.config` that adds our Node.js version.

    ```shell
    # Node.js version
    node_version=10.23.0
    ```

6. Create `Procfile` with our startup command `web: mix phx.server`.
7. Update `config/prod.exs` with our Heroku url.

    ```elixir
    http: [port: {:system, "PORT"}],
    url: [scheme: "https", host: "pacific-savannah-85771.herokuapp.com", port: 443],
    force_ssl: [rewrite_on: [:x_forwarded_proto]],
    ```

8. Turn on SSL in `config/prod.secret.exs` by uncommenting `ssl: true`.
9. Configure websocket timeout in `lib/todo_mvc_web/endpoint.ex` by replacing `websocket: true,` with `websocket: [timeout: 45_000],`.
10. Configured the Heroku Postgres hobby database via `heroku addons:create heroku-postgresql:hobby-dev`.
11. Configured the `POOL_SIZE` variable as `heroku config:set POOL_SIZE=8`. May attempt to reuse this database as multitenancy for other apps.
12. Generated a new secret key base via `mix phx.gen.secret`.
13. Configure Heroku's `SECRET_KEY_BASE` environment variable via `heroku config:set SECRET_KEY_BASE="(key)"`.
14. Deploy via `git push heroku master`.
15. Visit [https://pacific-savannah-85771.herokuapp.com/] to receive `Internal Server Error` message.
    1. Investigate problem by looking at the Postgres data store.
    2. The utilization section showed `0 tables`.
16. Create the database table structure using `heroku run "POOL_SIZE=2 mix ecto.migrate"`.
17. The site [https://pacific-savannah-85771.herokuapp.com/] now works as expected.
