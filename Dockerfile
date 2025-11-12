FROM node:18 AS builder
WORKDIR /usr/src/app
COPY package.json .
RUN npm install 
COPY . . 


# Multi-stage build
FROM node:18-alpine
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app .
ENV PORT=3000 \
    DB="" \
    DBUSER="" \
    DBPASS="" \
    DBHOST="" \
    DBPORT=""
EXPOSE 3001
# USER node
CMD ["npm","start"]
