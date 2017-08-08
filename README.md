# docker-sapl
Docker containers for SAPL. Initially only for version 2.5.

## Requirements

### Docker

To use this image you need docker daemon installed. Run the following commands as root:

```
curl -ssl https://get.docker.com | sh
```

### Docker-compose

Docker-compose is desirable (run as root as well):

```
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
```

## Docker-compose Example

Save the following snippet as docker-compose.yaml in any folder you like, or clone this repository, which contains the same file.

```
sapl:
  image: interlegis/sapl25:latest
  ports:
    - "8080:8080"
  environment:
    - MYSQL_PASSWORD=saplInterlegis
    - ZEO_CLIENT=True
    - ZEO_ADDRESS=zeoserver:8100
  links:
    - mysql
    - zeoserver

zeoserver:
  image: interlegis/zeoserver:2.9.12
  volumes:
    - zeodata:/opt/zope/instances/zeo/var

mysql:
  image: mysql
  environment:
    - MYSQL_ROOT_PASSWORD=mysqlInterlegis
    - MYSQL_DATABASE=sapl
    - MYSQL_USER=sapl
    - MYSQL_PASSWORD=saplInterlegis
  volumes:
    - mysqldata:/var/lib/mysql
```

## Running

```
cd <folder where docker-compose.yaml is>
docker-compose up -d
```

## Contributing

Pull requests welcome!
