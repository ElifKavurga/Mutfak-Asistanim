FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter config --enable-web && flutter pub get

COPY . .
RUN flutter build web --release --pwa-strategy=none

FROM node:20-alpine

WORKDIR /app

COPY --from=build /app/build/web ./build/web
COPY serve_web.js ./serve_web.js

ENV NODE_ENV=production
ENV PORT=8080

EXPOSE 8080

CMD ["node", "serve_web.js"]
