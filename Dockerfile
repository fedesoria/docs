FROM xiam/luminos

COPY settings.yaml /etc/settings.yaml

EXPOSE 9000

ENTRYPOINT [ \
	"/bin/luminos", \
	"-c", "/etc/settings.yaml", \
	"run" \
]
