deps:
	go get -d -v menteslibres.net/luminos

run:
	luminos run -c settings.yaml

docker:
	docker build -t upper/site .

docker-run: docker
	docker run -d -p 9000:9000 -v $$PWD:/var/site --name upper-site -t upper/site

