FROM --platform=linux/amd64 cirrusci/flutter:2.10.4 AS builder

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --web-renderer html

FROM node:16-alpine

WORKDIR /app
COPY --from=builder /app/build/web/ /app/public/
COPY backend/package.json .
COPY backend/yarn.lock .
RUN yarn install --production
RUN yarn cache clean
COPY backend/index.js .

CMD ["node", "index.js"]
