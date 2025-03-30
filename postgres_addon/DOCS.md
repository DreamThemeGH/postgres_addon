# PostgreSQL Add-on Documentation

## Overview

This add-on provides a PostgreSQL 15 database server for your Home Assistant instance. It's configured with memory limitations to ensure it doesn't consume more than 512MB of RAM.

## Installation

Follow these steps to install the add-on:

1. Navigate to the Home Assistant add-on store
2. Add this repository URL: `https://github.com/DreamThemeGH/ha-postgres-addon`
3. Find the "PostgreSQL Database" add-on and click install

## Configuration

### Required configuration options

- `admin_user`: The admin username for PostgreSQL (default: postgres)
- `admin_password`: The password for the admin user
- `database_name`: The name of the database to create

Example configuration:

```yaml
admin_user: postgres
admin_password: mysecretpassword
database_name: homeassistant
```

### Home Assistant User

Upon installation, the add-on automatically creates a user named `ha` with a randomly generated password. This information will be displayed in the add-on logs and in the add-on information tab after installation.

You can use this user to connect Home Assistant to PostgreSQL.

## Using with Home Assistant

To use this PostgreSQL server with Home Assistant, update your `configuration.yaml`:

```yaml
recorder:
  db_url: postgresql://ha:PASSWORD@core-postgres:5432/homeassistant
```

Replace `PASSWORD` with the generated password for the `ha` user.

## Network Access

The PostgreSQL server is accessible on port 5432. If you need to connect from external applications, make sure to configure your network settings accordingly.

## Backup and Restore

This add-on stores its data in `/data/postgres`. To back up your PostgreSQL data, you should back up this directory.

## Limitations

- The PostgreSQL server is limited to 512MB of RAM.
- The database files are stored in the add-on data directory, so make sure you have enough disk space available.

## Support

For issues and feature requests, please open an issue on GitHub.