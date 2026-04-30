FROM dart:stable AS build

WORKDIR /app
COPY shared/pubspec.* shared/
COPY backend/pubspec.* backend/

# Get shared dependencies first
WORKDIR /app/shared
RUN dart pub get

WORKDIR /app/backend
RUN dart pub get

WORKDIR /app
COPY shared/ shared/
COPY backend/ backend/

WORKDIR /app/backend
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

FROM debian:bookworm-slim
COPY --from=build /app/backend/bin/server /app/bin/
EXPOSE 8080
CMD ["/app/bin/server"]
