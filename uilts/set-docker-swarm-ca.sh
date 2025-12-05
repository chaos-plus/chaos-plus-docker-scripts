docker swarm update --cert-expiry 867240h0m0s
docker swarm ca --rotate | openssl x509 -text -noout
docker swarm ca --rotate

docker system info | grep Duration