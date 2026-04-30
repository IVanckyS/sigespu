FROM dart:stable AS build

WORKDIR /app
COPY shared/pubspec.* shared/
COPY scraper/pubspec.* scraper/

WORKDIR /app/shared
RUN dart pub get

WORKDIR /app/scraper
RUN dart pub get

WORKDIR /app
COPY shared/ shared/
COPY scraper/ scraper/

WORKDIR /app/scraper
RUN dart pub get --offline
RUN dart compile exe bin/scraper.dart -o bin/scraper

FROM debian:bookworm-slim
COPY --from=build /app/scraper/bin/scraper /app/bin/
CMD ["/app/bin/scraper"]
