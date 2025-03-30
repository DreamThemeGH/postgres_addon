ARG BUILD_FROM
FROM $BUILD_FROM

# Установка PostgreSQL 15
RUN apt-get update && \
    apt-get install -y lsb-release wget gnupg2 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-15 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Копирование скриптов
COPY run.sh /
RUN chmod a+x /run.sh

# Устанавливаем рабочую директорию
WORKDIR /data

# Настраиваем порт
EXPOSE 5432

# Команда по умолчанию
CMD [ "/run.sh" ]