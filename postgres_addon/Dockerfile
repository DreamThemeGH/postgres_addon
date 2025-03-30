ARG BUILD_FROM
FROM $BUILD_FROM

# Установка PostgreSQL 15
RUN apk add --no-cache postgresql15 postgresql15-client

# Копирование скриптов
COPY run.sh /
RUN chmod a+x /run.sh

# Устанавливаем рабочую директорию
WORKDIR /data

# Настраиваем порт
EXPOSE 5432

# Команда по умолчанию
CMD [ "/run.sh" ]