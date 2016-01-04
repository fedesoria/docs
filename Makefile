deps:
	go get -d -v menteslibres.net/luminos

run:
	luminos -c settings-local.yaml run

docker:
	docker build -t upper/site .

docker-run: docker
	docker run -d -p 9000:9000 -v $$PWD:/var/site --name upper-site -t upper/site
