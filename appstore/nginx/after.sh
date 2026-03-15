


get_container_name() {
    local service_name=$1
    docker ps --filter "name=${service_name}" --filter "status=running" --format "{{.Names}}" | head -n 1
}

NGINX_CONTAINER=$(get_container_name "nginx")
if [ -z "$NGINX_CONTAINER" ]; then
    echo "nginx container not found"
    exit 1
fi
docker exec -it $NGINX_CONTAINER sh -c "nginx -t && nginx -s reload"
