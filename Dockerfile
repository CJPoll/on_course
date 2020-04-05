FROM elixir:1.7-alpine AS elixir

RUN mix local.hex --force && mix local.rebar --force

RUN apk update
RUN apk add git nodejs npm inotify-tools bash curl tar xz alpine-sdk

ARG MIX_ENV=prod

WORKDIR /app

COPY mix.exs mix.exs
COPY mix.lock mix.lock
RUN mix deps.get

COPY config config
RUN mix deps.compile

COPY . .

RUN mix compile

# BREAK

FROM elixir:1.7-alpine AS javascript

RUN apk update
RUN apk add git nodejs npm inotify-tools bash curl tar xz alpine-sdk

COPY --from=elixir /app/assets /app/assets
COPY --from=elixir /app/deps /app/deps

WORKDIR /app/assets

RUN npm install
RUN npm run deploy

# BREAK

FROM elixir:1.7-alpine

RUN mix local.hex --force && mix local.rebar --force

RUN apk update
RUN apk add git nodejs npm inotify-tools bash curl tar xz alpine-sdk

WORKDIR /app

COPY --from=elixir /app /app
COPY --from=javascript /app/assets /app/assets
