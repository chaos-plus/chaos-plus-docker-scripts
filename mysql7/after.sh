#!/bin/bash -e



until docker exec mysql7 mysqladmin ping -uroot -p${PASSWORD} --silent; do
  echo "⏳ Waiting for MySQL 7 to be ready..."
  sleep 2
done

echo "✅ MySQL 7 is ready!"