ARG BUILD_FROM
FROM $BUILD_FROM

# Установка PostgreSQL 15 и bash
RUN apk add --no-cache postgresql15 postgresql15-client bash jq curl

# Установка bashio
RUN curl -J -L -o /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/v0.15.0.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# Копирование скриптов
COPY run.sh /
RUN chmod a+x /run.sh

# Устанавливаем рабочую директорию
WORKDIR /data

# Настраиваем порт
EXPOSE 5432

# Команда по умолчанию
CMD [ "/run.sh" ]