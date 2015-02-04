Run In Docker
=============

## Development

First, you need to build development image:

``` bash
docker build -t splendidbacon/dev - < docker/Dockerfile.dev
```

Then simply run

``` bash
docker run -p 1337:5000 -v $(pwd):/var/www -v $(pwd)/docker/gems:/var/bundle -i -t splendidbacon/dev:latest
```

If this is the first run, run install script:

``` bash
install-splendidbeacon
```

Start service:

``` bash
bundle exec foreman start
```

Simply access splendid beacon at [localhost:1337](http://localhost:1337)

## Production

First, you need to build development image:

``` bash
docker build -t splendidbacon/app - < docker/Dockerfile.app
```

Then simply run

``` bash
docker run -p 1337:5000 -i -t splendidbacon/app
```
