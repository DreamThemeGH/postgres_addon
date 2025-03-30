# PostgreSQL Add-on for Home Assistant

This add-on provides a PostgreSQL 15 database server for Home Assistant with memory limitations set to 512MB.

## Features

- PostgreSQL 15 database server
- Memory limitation to 512MB
- Automatic configuration of admin user
- Generation of Home Assistant user with random password
- Easy integration with Home Assistant

## Installation

1. Add the repository URL to your Home Assistant add-on store.
2. Install the "PostgreSQL Database" add-on.
3. Configure the add-on with your admin username, password, and database name.
4. Start the add-on.

## Configuration

When you start the add-on for the first time, it will automatically create a database and set up the users according to your configuration.

The add-on will also create a Home Assistant user (username: `ha`) with a randomly generated password that will be displayed in the add-on logs and configuration page after installation.

## Usage

You can connect to the PostgreSQL server using the following details:
- Host: The IP address of your Home Assistant instance
- Port: 5432
- Database: The database name you configured
- Username: Either the admin user you configured or the generated `ha` user
- Password: The password for the respective user

This PostgreSQL server can be used for Home Assistant recorder, AppDaemon, and other integrations that require a database.