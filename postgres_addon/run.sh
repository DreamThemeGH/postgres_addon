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

# Создание пользователя postgres, если он не существует
if ! id postgres &>/dev/null; then
    adduser -D -h "$PG_DATA_DIR" -s /bin/ash postgres
fi

# Инициализация базы данных PostgreSQL, если она не существует
if [ ! -f "$PG_DATA_DIR/PG_VERSION" ]; then
    bashio::log.info "Initializing PostgreSQL database in $PG_DATA_DIR..."
    mkdir -p "$PG_DATA_DIR"
    chown postgres:postgres "$PG_DATA_DIR"
    
    # Инициализация БД от имени пользователя postgres
    su postgres -c "initdb -D $PG_DATA_DIR"
fi

# Настройка PostgreSQL для ограничения памяти
cat > "$PG_DATA_DIR/postgresql.conf" << EOF
# Базовые настройки
listen_addresses = '*'
port = 5432

# Настройки памяти для ограничения в 512 МБ
shared_buffers = 128MB
temp_buffers = 8MB
work_mem = 4MB
maintenance_work_mem = 64MB
max_connections = 100

# Логирование
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d.log'
log_statement = 'none'
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d '
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
su postgres -c "pg_ctl -D $PG_DATA_DIR start"

# Ожидание запуска PostgreSQL
sleep 5

# Создание пользователя и базы данных
if [ "$ADMIN_USER" != "postgres" ]; then
    # Создание нового админ-пользователя, игнорируем ошибку если пользователь уже существует
    su postgres -c "psql -c \"CREATE USER $ADMIN_USER WITH SUPERUSER ENCRYPTED PASSWORD '$ADMIN_PASSWORD';\"" || true
fi

# Создание базы данных, игнорируем ошибку если база уже существует
su postgres -c "psql -c \"CREATE DATABASE $DATABASE_NAME;\"" || true
su postgres -c "psql -c \"ALTER DATABASE $DATABASE_NAME OWNER TO $ADMIN_USER;\"" || true

# Создание пользователя ha, игнорируем ошибку если пользователь уже существует
su postgres -c "psql -c \"CREATE USER ha WITH PASSWORD '$HA_PASSWORD';\"" || true
su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO ha;\"" || true

# Вывод информации о созданном пользователе ha
bashio::log.info "PostgreSQL successfully configured!"
bashio::log.info "Generated Home Assistant user:"
bashio::log.info "Username: ha"
bashio::log.info "Password: $HA_PASSWORD"

# Сохранение данных о пользователе ha для отображения в интерфейсе
echo "{\"ha_user\": \"ha\", \"ha_password\": \"$HA_PASSWORD\"}" > /data/ha_user_info.json

# Держим процесс запущенным и проверяем состояние PostgreSQL
while true; do
    sleep 300
    # Проверяем, работает ли PostgreSQL, и перезапускаем его при необходимости
    if ! su postgres -c "pg_isready" > /dev/null 2>&1; then
        bashio::log.warning "PostgreSQL is not running. Attempting to restart..."
        su postgres -c "pg_ctl -D $PG_DATA_DIR start"
    fi
done