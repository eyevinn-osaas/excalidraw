FROM node:18 AS build

WORKDIR /opt/node_app

COPY . .

# do not ignore optional dependencies:
# Error: Cannot find module @rollup/rollup-linux-x64-gnu
RUN yarn --network-timeout 600000

ARG NODE_ENV=production

RUN yarn build:app:docker

FROM nginx:1.27-alpine

COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html
COPY --from=build /opt/node_app/osc-entrypoint.sh ./osc-entrypoint.sh
RUN chmod +x ./osc-entrypoint.sh
EXPOSE 8080

ENTRYPOINT ["./osc-entrypoint.sh"]
CMD [ "nginx", "-g", "daemon off;" ]
HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
