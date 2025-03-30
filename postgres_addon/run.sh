#!/usr/bin/with-contenv bashio

# Получение настроек
ADMIN_USER=$(bashio::config 'admin_user')
ADMIN_PASSWORD=$(bashio::config 'admin_password')
DATABASE_NAME=$(bashio::config 'database_name')

# Генерация случайного пароля для пользователя HA
HA_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

# Настройка каталога данных PostgreSQL
PG_DATA_DIR="/data/postgres"
mkdir -p "$PG_DATA_DIR"

# Инициализация базы данных PostgreSQL, если она не существует
if [ ! -f "$PG_DATA_DIR/PG_VERSION" ]; then
    bashio::log.info "Initializing PostgreSQL database in $PG_DATA_DIR..."
    # Создаем пользователя postgres для совместимости с функциями инициализации
    adduser --system --no-create-home --home "$PG_DATA_DIR" --shell /bin/bash postgres
    mkdir -p "$PG_DATA_DIR"
    chown postgres:postgres "$PG_DATA_DIR"
    
    # Инициализация БД от имени пользователя postgres
    su -c "initdb -D $PG_DATA_DIR" postgres
fi

# Настройка PostgreSQL
cat > "$PG_DATA_DIR/postgresql.conf" << EOF
# Настройки памяти
shared_buffers = 128MB
temp_buffers = 8MB
work_mem = 4MB
maintenance_work_mem = 64MB
max_connections = 100
listen_addresses = '*'
EOF

# Настройка доступа
cat > "$PG_DATA_DIR/pg_hba.conf" << EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    all             all             0.0.0.0/0               md5
EOF

# Владелец должен быть postgres
chown -R postgres:postgres "$PG_DATA_DIR"

# Запуск PostgreSQL
bashio::log.info "Starting PostgreSQL..."
su -c "pg_ctl -D $PG_DATA_DIR start" postgres

# Ожидание запуска PostgreSQL
sleep 5

# Создание пользователя и базы данных
if [ "$ADMIN_USER" != "postgres" ]; then
    # Создание нового админ-пользователя
    su -c "psql -c \"CREATE USER $ADMIN_USER WITH SUPERUSER ENCRYPTED PASSWORD '$ADMIN_PASSWORD';\"" postgres
fi

# Создание базы данных
su -c "psql -c \"CREATE DATABASE $DATABASE_NAME OWNER $ADMIN_USER;\"" postgres

# Создание пользователя ha
su -c "psql -c \"CREATE USER ha WITH PASSWORD '$HA_PASSWORD';\"" postgres
su -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO ha;\"" postgres

# Вывод информации о созданном пользователе ha
bashio::log.info "PostgreSQL successfully configured!"
bashio::log.info "Generated Home Assistant user:"
bashio::log.info "Username: ha"
bashio::log.info "Password: $HA_PASSWORD"

# Сохранение данных о пользователе ha для отображения в интерфейсе
echo "{\"ha_user\": \"ha\", \"ha_password\": \"$HA_PASSWORD\"}" > /data/ha_user_info.json

# Держим процесс запущенным
while true; do
    sleep 86400
done