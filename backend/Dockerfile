FROM dart:stable AS build

WORKDIR /app
COPY shared/pubspec.* shared/
COPY backend/pubspec.* backend/
COPY scraper/pubspec.* scraper/

# Get shared dependencies first
WORKDIR /app/shared
RUN dart pub get

WORKDIR /app/scraper
RUN dart pub get

WORKDIR /app/backend
RUN dart pub get

WORKDIR /app
COPY shared/ shared/
COPY scraper/ scraper/
COPY backend/ backend/

WORKDIR /app/backend
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

FROM debian:bookworm-slim
RUN apt-get update \
  && apt-get install -y --no-install-recommends gdal-bin \
  && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/backend/bin/server /app/bin/
COPY --from=build /app/backend/migrations /app/migrations/
EXPOSE 8080
CMD ["/app/bin/server"]
