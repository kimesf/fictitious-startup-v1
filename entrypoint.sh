#!/bin/bash

# Prepare local environment
if [ "$ENVIRONMENT" = "local" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"

    # Create the database if it doesn't exist - connect to 'postgres' database initially
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB'" | grep -q 1 || PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d postgres -c "CREATE DATABASE $POSTGRES_DB"

    echo "Database $POSTGRES_DB is ready"

    # Apply database migrations
    echo "Applying database migrations..."
    python manage.py migrate

    # Collect static files
    echo "Collecting static files..."
    python manage.py collectstatic --noinput --clear
fi

exec "$@"
