FROM --platform=linux/amd64 cirrusci/flutter:2.10.3 AS builder

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web

FROM node:16-alpine

WORKDIR /app
COPY --from=builder /app/build/web/ /app/public/
COPY fetch/package.json .
COPY fetch/yarn.lock .
RUN yarn install --production
RUN yarn cache clean
COPY fetch/index.js .

CMD ["node", "index.js"]