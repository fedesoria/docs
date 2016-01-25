# The upper.io documentation site

This is the documentation site for `upper.io`.

## How to install and run

Install dependencies with `make deps`:

```
make deps
```

Run the server:

```
make run
```

And open `127.0.0.1:9000`.

Editable files are under the `upper.io` directory, you'll find `default`, `v1`
and `v2` subdirectories inside.

Each one of the subdirectories follows a simple structure:

```
content/
templates/
webroot/
site.yaml
```

You'll find markdown files under the `content/` subdirectory.

## Using docker

You can also run this site with docker:

```
make docker-run
```
