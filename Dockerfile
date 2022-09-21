FROM node:16.15.0-alpine3.15 AS builder

RUN apk update
RUN apk add --no-cache sqlite

WORKDIR /node

RUN mkdir db
VOLUME /node/db

COPY package*.json ./
RUN npm install && npm cache clean --force

WORKDIR /node/app

COPY . .
RUN npm run build

ENV NODE_PATH=./build

FROM nginx:latest as production
ENV NODE_ENV production

COPY --from=builder /node/app/build /usr/share/nginx/html

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD [ "node", "build/index.js" ]
CMD ["nginx", "-g", "daemon off;"]
