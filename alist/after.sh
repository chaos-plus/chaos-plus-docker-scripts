
#!/bin/bash -e

sleep 10

docker exec -it alist ./alist admin set ${PASSWORD} || true