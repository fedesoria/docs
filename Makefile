deps:
	go get -d -v menteslibres.net/luminos

run:
	luminos run -c settings.yaml

docker-run:
	sudo docker build -t luminos . && \
	sudo docker run -p 9000:9000 --privileged -v $$PWD:/var/site --name luminos -t luminos -c /etc/settings.yaml run
