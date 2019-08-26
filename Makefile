# This is ONLY for DEV usage. Do not use self-signed certs for production services
gen-dev-certs:
	-rm .ssl/server.cert.pem .ssl/server.crt .ssl/server.key .ssl/server.key.pem
	-rm .certs/client/client.crt .certs/client/client.csr .certs/client/client.key .certs/client/client.cert.pem .certs/client/client.key.pem .certs/client/client.key.unencrypted.pem
	-rm .certs/server/server.crt .certs/server/server.csr .certs/server/server.key .certs/server/server.key.pem .certs/server/server.key.unencrypted.pem
	-rm .certs/ca.cert.pem .certs/ca.crt .certs/ca.key
	./gen-dev-certs.sh

remove-all:
	-docker rm -f  my-app-cont_1  my-app-cont_2  my-app-cont_3 my-app-db my-app-nginx
	-docker rmi my-app-img my-app-postgres-img my-app-nginx-img
	-docker system prune

start-apps:
	-docker network create my-bridge-network
	-docker-compose up -d app1 app2 app3 nginx

remove-apps:
	-docker rm -f  my-app-cont_1  my-app-cont_2  my-app-cont_3 my-app-nginx
	-docker rmi my-app-img my-app-nginx-img
	-docker system prune

start-db:
	-docker network create my-bridge-network
	docker-compose up -d db

remove-db:
	-docker rm -f my-app-db
	-docker rmi my-app-postgres-img

start-dev:
	make dev-generate-keys
	make start-all-containers