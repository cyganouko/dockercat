FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm config set fetch-retry-maxtimeout 600000 \
 && npm config set fetch-retry-mintimeout 20000 \
 && npm config set fetch-timeout 600000 \
 && npm install --legacy-peer-deps

COPY . .

EXPOSE 3000

ENV HOST=0.0.0.0

CMD ["npm","start"]
