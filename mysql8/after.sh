#!/bin/bash -e



until docker exec mysql8 mysqladmin ping -uroot -p${PASSWORD} --silent; do
  echo "⏳ Waiting for MySQL 8 to be ready..."
  sleep 2
done

echo "✅ MySQL 8 is ready!"