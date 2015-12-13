FROM debian:jessie

RUN apt-get update

RUN apt-get install -y curl

ENV DOC_ROOT /var/site

ENV LUMINOS_URL https://github.com/xiam/luminos/releases/download/v0.9.1/luminos_linux_amd64.gz

RUN curl --silent -L ${LUMINOS_URL} | gzip -d > /bin/luminos

RUN chmod +x /bin/luminos

RUN mkdir -p ${DOC_ROOT}

COPY settings.yaml /etc/settings.yaml

EXPOSE 9000

ENTRYPOINT ["/bin/luminos"]

CMD ["run"]

