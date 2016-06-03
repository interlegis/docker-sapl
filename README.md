# docker-sapl
Docker containers for SAPL. Initially only for version 2.5.

## Requirements

### Docker

To use this image you need docker daemon installed:

```
curl -ssl https://get.docker.com | sh
```

### Docker-compose

Docker-compose is desirable:

```
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
```

## Docker-compose Example

```
sapl:
  image: interlegis/sapl:2.5
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

mysql:
  image: mysql
  environment:
    - MYSQL_ROOT_PASSWORD=mysqlInterlegis
    - MYSQL_DATABASE=sapl
    - MYSQL_USER=sapl
    - MYSQL_PASSWORD=saplInterlegis
```

## Running

```
cd docker-sapl
docker-compose up -d
```

## Contributing

Pull requests welcome!
