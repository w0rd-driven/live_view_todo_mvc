# Heroku Deployment

## Instructions

We're following along with [the official documentation](https://hexdocs.pm/phoenix/1.5.9/heroku.html) with supplemental notes from [Deploy Elixir Phoenix to Heroku Containers with Docker](https://staknine.com/deploy-elixir-phoenix-heroku-containers-docker/) on StakNine.

1. Get the `heroku` CLI installed locally
2. Run `heroku create --buildpack hashnuke/elixir` to add the `Elixir Buildpack`.
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
7. 