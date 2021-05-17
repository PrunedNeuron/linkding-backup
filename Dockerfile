FROM rclone/rclone:latest
RUN apk --no-cache add curl

ENV APP_DIR=/app
WORKDIR ${APP_DIR}

COPY src/*.sh  ${APP_DIR}
COPY config/rclone.conf ${APP_DIR}

ENTRYPOINT sh "${APP_DIR}/app.sh"
