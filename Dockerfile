FROM elixir:1.20.5-otp-29-alpine AS build
ENV MIX_ENV=prod
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod && mix deps.compile
COPY config ./config
COPY lib ./lib
COPY priv ./priv
RUN mix release

FROM elixir:1.20.5-otp-29-alpine
WORKDIR /app
RUN apk add --no-cache ca-certificates
RUN addgroup -S ecidadao && adduser -S ecidadao -G ecidadao
COPY --from=build --chown=ecidadao:ecidadao /app/_build/prod/rel/ecidadao ./
USER ecidadao
EXPOSE 4000
CMD ["/app/bin/ecidadao", "start"]
