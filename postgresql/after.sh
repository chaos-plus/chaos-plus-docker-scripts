#!/bin/bash

echo "⏳ Waiting for PostgreSQL to be ready..."

until docker exec postgresql psql -U root -d postgres -c "SELECT 1" &>/dev/null; do
  echo "⏳ Waiting for PostgreSQL..."
  sleep 2
done

echo "✅ PostgreSQL is ready!"
