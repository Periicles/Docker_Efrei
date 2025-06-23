# Advanced Docker

This README has a school purpose.
The goal of this course is to understand and manipulate docker in a more
advanced way.


## Part 1

### Simple run

First of all we need to pull an image to use. The one used here is for educational purposes and might not be working by the time you try it.

#

```bash
docker pull it4lik/meow-api:latest
```

This allows us to use the latest version of the image.

#
```bash
docker run -d -p 8000:8000 it4lik/meow-api
```

The docker run command runs the specified image.

- the `-d` flag intends to run the image in background.
- the `-p` flag intends to choose the ports the image will run on.

#
If you try accesssing the `http://YOUR_IP:PORT` `/` route, you will get this message:
```json
{
  "message": "Available routes",
  "routes": {
    "get_user_by_id": "http://localhost:8000/user/1",
    "list_all_users": "http://localhost:8000/users"
  }
}
```

#
You also can get logs by using
```bash 
docker logs (YOUR_ID)
```
Mine had this answer:

```bash
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8000
 * Running on http://172.17.0.2:8000
Press CTRL+C to quit
172.17.0.1 - - [23/Jun/2025 08:14:08] "GET / HTTP/1.1" 200 -
172.17.0.1 - - [23/Jun/2025 08:14:08] "GET /favicon.ico HTTP/1.1" 404 -
```

### Volumes

We can use the `-v` flag in order to mount a file at runtime.

I created a small `app.py` file.

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello World!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

```

Then I ran:

```bash
docker run -p 8000:8000 -v "$PWD/app.py":/app/app.py:z it4lik/meow-api
```

My `:z` stands to prevent my Fedora because of SELinux.

And this curl command can prove that this work properly.

```bash
curl -i http://localhost:8000

HTTP/1.1 200 OK
Server: Werkzeug/3.1.3 Python/3.12.11
Date: Mon, 23 Jun 2025 09:31:21 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 12
Connection: close

Hello World!%
```

### Environment variables

We can make our app listen on a custom port by using environment variables.
If the variable is defined, the app will listen on that port.
If not, it defaults to port 8000.

This command tells us to run the app using environment variable and the `-p` flag is updated to match.

```bash
docker run -p 7000:7000 -e LISTEN_PORT=7000 -v "$PWD/app.py":/app/app.py:z it4lik/meow-api
```

Then to prove it is working properly, just run this curl command:

```bash
curl -i http://localhost:7000

HTTP/1.1 200 OK
Server: Werkzeug/3.1.3 Python/3.12.11
Date: Mon, 23 Jun 2025 09:48:08 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 12
Connection: close

Hello World!%
```

## Part 2

### Public images

First of all we will pull specific images.
- Python 3.11
- mysql 8.0.42
- wordpress int its latest version
- linuxserver/wikijs in its latest version

```bash
docker pull python:3.11
    ``      mysql:8.0.42
    ``      wordpress:latest
    ``      linuxserver/wikijs:latest
```

To test, try running a bash in the Python image and verify Python is installed

```bash
docker run -it python:3.11 bash

root@42c909026c64:/# python
Python 3.11.13 (main, Jun 11 2025, 02:32:45) [GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>
```

### Build an image

#### Build the meow-api

Start by cloning the repository to use its `Dockerfile` and `app.py` in a new directory.

```bash
git clone https://gitlab.com/it4lik/b3e-docker-avance.git
```

```bash
mkdir my_directory
mv <cloned_dockerfile> <new_directory_location>
mv <cloned_app> <new_directory_location>
```

Now we need to build the image

```bash
docker build . -t meow-api

[+] Building 10.7s (11/11) FINISHED                                                                                                                      docker:default
 => [internal] load build definition from Dockerfile                                                                                                               0.0s
 => => transferring dockerfile: 626B                                                                                                                               0.0s
 => [internal] load metadata for docker.io/library/python:3.12-slim                                                                                                2.0s
 => [auth] library/python:pull token for registry-1.docker.io                                                                                                      0.0s
 => [internal] load .dockerignore                                                                                                                                  0.0s
 => => transferring context: 2B                                                                                                                                    0.0s
 => [internal] load build context                                                                                                                                  0.1s
 => => transferring context: 1.74kB                                                                                                                                0.0s
 => [1/5] FROM docker.io/library/python:3.12-slim@sha256:e55523f127124e5edc03ba201e3dbbc85172a2ec40d8651ac752364b23dfd733                                          0.2s
 => => resolve docker.io/library/python:3.12-slim@sha256:e55523f127124e5edc03ba201e3dbbc85172a2ec40d8651ac752364b23dfd733                                          0.1s
 => => sha256:87760eb43bfd3a69077f22c9746ab0095bb8677c359507ccf46e60f46b267dae 5.57kB / 5.57kB                                                                     0.0s
 => => sha256:e55523f127124e5edc03ba201e3dbbc85172a2ec40d8651ac752364b23dfd733 9.13kB / 9.13kB                                                                     0.0s
 => => sha256:85a16b09171c774647cf2c9f62027552de44a29386e8d09e76cc92a0bda66c22 1.75kB / 1.75kB                                                                     0.0s
 => [2/5] WORKDIR /app                                                                                                                                             0.1s
 => [3/5] COPY ./requirements.txt .                                                                                                                                0.0s
 => [4/5] RUN pip install --no-cache-dir -r requirements.txt                                                                                                       7.4s
 => [5/5] COPY ./app.py .                                                                                                                                          0.1s
 => exporting to image                                                                                                                                             0.6s
 => => exporting layers                                                                                                                                            0.6s
 => => writing image sha256:6574fa4dac3877f9179e7bf9bccb90f58284f60d4983e0b28878bb86ddd5b672                                                                       0.0s
 => => naming to docker.io/library/meow-api                                                                                                                        0.0s
```

Then check the meow-api image is here.

```bash
docker images

REPOSITORY           TAG       IMAGE ID       CREATED          SIZE
meow-api             latest    6574fa4dac38   30 seconds ago   234MB
```

Now we are able to run it.

```bash
docker run -d -p 8000:8000 meow-api
```

### Package an app

Using this code snippet

```python
import emoji

print(emoji.emojize("Cet exemple d'application est vraiment naze :thumbs_down:"))
```

Create a new directory using the same structure in order to build anew image.

Write a `Dockerfile` accordingly.

```bash
package
├── app.py
├── Dockerfile
└── requirement.txt
```

Dockerfile :

```bash
FROM python:3.11

WORKDIR /package

COPY ./requirement.txt .

RUN pip install --no-cache-dir -r requirement.txt

COPY ./app.py .

CMD ["python", "app.py"]
```

requirement.txt :

```txt
emoji
```

Then build the new image

```bash
docker build . -t python_app

[+] Building 0.4s (10/10) FINISHED                                                                                                                       docker:default
 => [internal] load build definition from Dockerfile                                                                                                               0.0s
 => => transferring dockerfile: 252B                                                                                                                               0.0s
 => [internal] load metadata for docker.io/library/python:3.11                                                                                                     0.0s
 => [internal] load .dockerignore                                                                                                                                  0.0s
 => => transferring context: 2B                                                                                                                                    0.0s
 => [1/5] FROM docker.io/library/python:3.11                                                                                                                       0.0s
 => [internal] load build context                                                                                                                                  0.0s
 => => transferring context: 298B                                                                                                                                  0.0s
 => CACHED [2/5] WORKDIR /package                                                                                                                                  0.0s
 => CACHED [3/5] COPY ./requirement.txt .                                                                                                                          0.0s
 => CACHED [4/5] RUN pip install --no-cache-dir -r requirement.txt                                                                                                 0.0s
 => [5/5] COPY ./app.py .                                                                                                                                          0.2s
 => exporting to image                                                                                                                                             0.0s
 => => exporting layers                                                                                                                                            0.0s
 => => writing image sha256:788b3a7ea47fa2acc442bb2065d93da3a6b38029e857bcc82856351a5f97253b                                                                       0.0s
 => => naming to docker.io/library/python_app 
```

```bash
docker images       

REPOSITORY           TAG       IMAGE ID       CREATED          SIZE
python_app           latest    788b3a7ea47f   45 seconds ago   1.03GB
```

```bash
docker run python_app

Cet exemple d'application est vraiment naze 👎 !
```

### Write your own Dockerfile

Here I decided to use a small project in VueJS.

First, create a `Dockerfile`

```bash
# Build VueJS app
FROM node:22-alpine AS build

WORKDIR /app

# Copy of dependecy files
COPY package*.json ./

# Dependecies installation
RUN npm install

# Full code copy
COPY . .

# Vue build
RUN npm run build

# Static serve with nginx
FROM nginx:alpine

# Build copy in nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Port exposure
EXPOSE 80

# Nginx start up
CMD ["nginx", "-g", "daemon off;"]
```

```bash
docker build . -t periicles/my_weather

[+] Building 10.9s (16/16) FINISHED                                                                                                                      docker:default
 => [internal] load build definition from Dockerfile                                                                                                               0.0s
 => => transferring dockerfile: 721B                                                                                                                               0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                                                                                    1.4s
 => [internal] load metadata for docker.io/library/node:22-alpine                                                                                                  1.4s
 => [auth] library/node:pull token for registry-1.docker.io                                                                                                        0.0s
 => [auth] library/nginx:pull token for registry-1.docker.io                                                                                                       0.0s
 => [internal] load .dockerignore                                                                                                                                  0.0s
 => => transferring context: 2B                                                                                                                                    0.0s
 => [build 1/6] FROM docker.io/library/node:22-alpine@sha256:41e4389f3d988d2ed55392df4db1420ad048ae53324a8e2b7c6d19508288107e                                      0.0s
 => [internal] load build context                                                                                                                                  0.1s
 => => transferring context: 2.30kB                                                                                                                                0.0s
 => [stage-1 1/2] FROM docker.io/library/nginx:alpine@sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10                                      0.0s
 => CACHED [build 2/6] WORKDIR /app                                                                                                                                0.0s
 => CACHED [build 3/6] COPY package*.json ./                                                                                                                       0.0s
 => CACHED [build 4/6] RUN npm install                                                                                                                             0.0s
 => [build 5/6] COPY . .                                                                                                                                           0.1s
 => [build 6/6] RUN npm run build                                                                                                                                  8.6s
 => CACHED [stage-1 2/2] COPY --from=build /app/dist /usr/share/nginx/html                                                                                         0.0s
 => exporting to image                                                                                                                                             0.0s
 => => exporting layers                                                                                                                                            0.0s
 => => writing image sha256:15670e4890a49af3d31ce204c2497596c8e6d7299f4df2843ae798888c2b5c3b                                                                       0.0s
 => => naming to docker.io/periicles/my_weather                                                                                                                    0.0s
```

```bash
docker images      

REPOSITORY             TAG       IMAGE ID       CREATED             SIZE
periicles/my_weather   latest    15670e4890a4   13 minutes ago      49MB
```

```bash
docker run -p 8080:80 periicles/my_weather

...
```

Then using a curl to verify

```bash
curl -i http://localhost:8080

HTTP/1.1 200 OK
Server: nginx/1.27.5
Date: Mon, 23 Jun 2025 13:33:50 GMT
Content-Type: text/html
Content-Length: 608
Last-Modified: Mon, 23 Jun 2025 13:30:48 GMT
Connection: keep-alive
ETag: "68595708-260"
Accept-Ranges: bytes

<!doctype html><html lang=""><head><meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="icon" href="/favicon.ico"><title>weather-app</title><script defer="defer" src="/js/chunk-vendors.fc2af384.js"></script><script defer="defer" src="/js/app.74855d7f.js"></script><link href="/css/app.6b4aa36d.css" rel="stylesheet"></head><body><noscript><strong>We're sorry but weather-app doesn't work properly without JavaScript enabled. Please enable it to continue.</strong></noscript><div id="app"></div></body></html>%
```

Now that we can see it runs properly, we can publish it to Docker Hub.

```bash
Docker login

Authenticating with existing credentials... [Username: periicles]

i Info → To login with a different account, run 'docker logout' followed by 'docker login'


Login Succeeded
```

```bash
docker tag periicles/my_weather periicles/my_weather:latest

docker push periicles/my_weather:latest
```
The image is accessible at this url now :
https://hub.docker.com/r/periicles/my_weather

## Part 3

### Getting started

#### 1 - Run it

Create a new directory `project_test`

```bash
mkdir project_test
cd project_test
```

Create the docker-compose file `docker-compose.yml`

```yaml
version: "3"

services:
  conteneur_nul:
    image: debian
    entrypoint: sleep 9999
  conteneur_flopesque:
    image: debian
    entrypoint: sleep 9999
```

Run the docker-compose file

```bash
docker compose up -d

docker compose up -d
WARN[0000] /home/periicles/Efrei/docker-efrei/project_test/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
[+] Running 3/3
 ✔ conteneur_nul Pulled                                                                                                                                            3.1s
 ✔ conteneur_flopesque Pulled                                                                                                                                      3.1s
   ✔ 0c01110621e0 Already exists                                                                                                                                   0.0s
[+] Running 3/3
 ✔ Network project_test_default                  Created                                                                                                           0.1s
 ✔ Container project_test-conteneur_nul-1        Started                                                                                                           0.4s
 ✔ Container project_test-conteneur_flopesque-1  Started                                                                                                           0.4s
```

#### List containers

```bash
docker ps

CONTAINER ID   IMAGE     COMMAND        CREATED          STATUS          PORTS     NAMES
57217ddfb0b4   debian    "sleep 9999"   17 minutes ago   Up 17 minutes             project_test-conteneur_flopesque-1
eea9bf7f20bf   debian    "sleep 9999"   17 minutes ago   Up 17 minutes             project_test-conteneur_nul-1
```

#### 2 - What about networking ?

Run a bash in the `conteneur_nul` container then ping the `conteneur_flopesque` container.

```bash
docker compose exec conteneur_nul bash

root@eea9bf7f20bf:/# ping conteneur_flopesque
bash: ping: command not found

root@eea9bf7f20bf:/# apt update
apt install iputils-ping -y

root@eea9bf7f20bf:/# ping conteneur_flopesque
PING conteneur_flopesque (172.20.0.2) 56(84) bytes of data.
64 bytes from project_test-conteneur_flopesque-1.project_test_default (172.20.0.2): icmp_seq=1 ttl=64 time=0.228 ms
```

### A working meow-api

```bash
docker compose up

WARN[0000] /home/periicles/Efrei/docker-efrei/Docker_Efrei/meow-compose/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
[+] Building 14.8s (12/12) FINISHED
 => [internal] load local bake definitions                                                                                                                         0.0s
 => => reading from stdin 434B                                                                                                                                     0.0s
 => [internal] load build definition from Dockerfile                                                                                                               0.0s
 => => transferring dockerfile: 635B                                                                                                                               0.0s
 => [internal] load metadata for docker.io/library/python:3.12-slim                                                                                                0.6s
 => [internal] load .dockerignore                                                                                                                                  0.1s
 => => transferring context: 2B                                                                                                                                    0.0s
 => [internal] load build context                                                                                                                                  0.1s
 => => transferring context: 1.74kB                                                                                                                                0.0s
 => CACHED [1/5] FROM docker.io/library/python:3.12-slim@sha256:e55523f127124e5edc03ba201e3dbbc85172a2ec40d8651ac752364b23dfd733                                   0.0s
 => [2/5] WORKDIR /meow-compose                                                                                                                                    0.2s
 => [3/5] COPY ./requirements.txt .                                                                                                                                0.1s
 => [4/5] RUN pip install --no-cache-dir -r requirements.txt                                                                                                      10.8s
 => [5/5] COPY ./app.py .                                                                                                                                          0.1s
 => exporting to image                                                                                                                                             2.2s
 => => exporting layers                                                                                                                                            2.2s
 => => writing image sha256:20f196fea7fc547abfe602056554adc5f6408b08dd42a77229ca14e0e8503921                                                                       0.0s
 => => naming to docker.io/library/meow-compose-meow-api                                                                                                           0.0s
 => resolving provenance for metadata file                                                                                                                         0.0s
[+] Running 4/4
 ✔ meow-compose-meow-api              Built                                                                                                                        0.0s 
 ✔ Network meow-compose_default       Created                                                                                                                      0.5s 
 ✔ Container meow-compose-db-1        Created                                                                                                                      0.3s 
 ✔ Container meow-compose-meow-api-1  Created                                                                                                                      0.1s 
Attaching to db-1, meow-api-1
db-1        | 2025-06-23 15:31:48+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.42-1.el9 started.
db-1        | 2025-06-23 15:31:48+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
db-1        | 2025-06-23 15:31:48+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.42-1.el9 started.
db-1        | 2025-06-23 15:31:49+00:00 [Note] [Entrypoint]: Initializing database files
db-1        | 2025-06-23T15:31:49.298347Z 0 [Warning] [MY-011068] [Server] The syntax '--skip-host-cache' is deprecated and will be removed in a future release. Please use SET GLOBAL host_cache_size=0 instead.
db-1        | 2025-06-23T15:31:49.298575Z 0 [System] [MY-013169] [Server] /usr/sbin/mysqld (mysqld 8.0.42) initializing of server in progress as process 80
db-1        | 2025-06-23T15:31:49.342697Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
meow-api-1  |  * Serving Flask app 'app'
meow-api-1  |  * Debug mode: off
meow-api-1  | WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
meow-api-1  |  * Running on all addresses (0.0.0.0)
meow-api-1  |  * Running on http://127.0.0.1:8000
meow-api-1  |  * Running on http://172.22.0.3:8000
meow-api-1  | Press CTRL+C to quit
db-1        | 2025-06-23T15:31:50.224351Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
db-1        | 2025-06-23T15:31:53.083673Z 6 [Warning] [MY-010453] [Server] root@localhost is created with an empty password ! Please consider switching off the --initialize-insecure option.
db-1        | 2025-06-23 15:31:58+00:00 [Note] [Entrypoint]: Database files initialized
db-1        | 2025-06-23 15:31:58+00:00 [Note] [Entrypoint]: Starting temporary server
db-1        | 2025-06-23T15:31:58.943527Z 0 [Warning] [MY-011068] [Server] The syntax '--skip-host-cache' is deprecated and will be removed in a future release. Please use SET GLOBAL host_cache_size=0 instead.
db-1        | 2025-06-23T15:31:58.945736Z 0 [System] [MY-010116] [Server] /usr/sbin/mysqld (mysqld 8.0.42) starting as process 124
db-1        | 2025-06-23T15:31:59.033406Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
db-1        | 2025-06-23T15:31:59.493768Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
db-1        | 2025-06-23T15:32:00.035608Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
db-1        | 2025-06-23T15:32:00.035724Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.
db-1        | 2025-06-23T15:32:00.043201Z 0 [Warning] [MY-011810] [Server] Insecure configuration for --pid-file: Location '/var/run/mysqld' in the path is accessible to all OS users. Consider choosing a different directory.
db-1        | 2025-06-23T15:32:00.126091Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Socket: /var/run/mysqld/mysqlx.sock
db-1        | 2025-06-23T15:32:00.126356Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.42'  socket: '/var/run/mysqld/mysqld.sock'  port: 0  MySQL Community Server - GPL.
db-1        | 2025-06-23 15:32:00+00:00 [Note] [Entrypoint]: Temporary server started.
db-1        | '/var/lib/mysql/mysql.sock' -> '/var/run/mysqld/mysqld.sock'
db-1        | Warning: Unable to load '/usr/share/zoneinfo/iso3166.tab' as time zone. Skipping it.
db-1        | Warning: Unable to load '/usr/share/zoneinfo/leap-seconds.list' as time zone. Skipping it.
db-1        | Warning: Unable to load '/usr/share/zoneinfo/leapseconds' as time zone. Skipping it.
db-1        | Warning: Unable to load '/usr/share/zoneinfo/tzdata.zi' as time zone. Skipping it.
db-1        | Warning: Unable to load '/usr/share/zoneinfo/zone.tab' as time zone. Skipping it.
db-1        | Warning: Unable to load '/usr/share/zoneinfo/zone1970.tab' as time zone. Skipping it.
db-1        | 2025-06-23 15:32:03+00:00 [Note] [Entrypoint]: Creating database meow
db-1        | 2025-06-23 15:32:03+00:00 [Note] [Entrypoint]: Creating user meow
db-1        | 2025-06-23 15:32:03+00:00 [Note] [Entrypoint]: Giving user meow access to schema meow
db-1        | 
db-1        | 2025-06-23 15:32:03+00:00 [Note] [Entrypoint]: /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/seed.sql
db-1        | 
db-1        | 
db-1        | 2025-06-23 15:32:03+00:00 [Note] [Entrypoint]: Stopping temporary server
db-1        | 2025-06-23T15:32:03.263379Z 14 [System] [MY-013172] [Server] Received SHUTDOWN from user root. Shutting down mysqld (Version: 8.0.42).
db-1        | 2025-06-23T15:32:05.466481Z 0 [System] [MY-010910] [Server] /usr/sbin/mysqld: Shutdown complete (mysqld 8.0.42)  MySQL Community Server - GPL.
db-1        | 2025-06-23 15:32:06+00:00 [Note] [Entrypoint]: Temporary server stopped
db-1        | 
db-1        | 2025-06-23 15:32:06+00:00 [Note] [Entrypoint]: MySQL init process done. Ready for start up.
db-1        | 
db-1        | 2025-06-23T15:32:06.593998Z 0 [Warning] [MY-011068] [Server] The syntax '--skip-host-cache' is deprecated and will be removed in a future release. Please use SET GLOBAL host_cache_size=0 instead.
db-1        | 2025-06-23T15:32:06.596073Z 0 [System] [MY-010116] [Server] /usr/sbin/mysqld (mysqld 8.0.42) starting as process 1
db-1        | 2025-06-23T15:32:06.606728Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
db-1        | 2025-06-23T15:32:06.815092Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
db-1        | 2025-06-23T15:32:07.125028Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
db-1        | 2025-06-23T15:32:07.125082Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.
db-1        | 2025-06-23T15:32:07.128964Z 0 [Warning] [MY-011810] [Server] Insecure configuration for --pid-file: Location '/var/run/mysqld' in the path is accessible to all OS users. Consider choosing a different directory.
db-1        | 2025-06-23T15:32:07.165021Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Bind-address: '::' port: 33060, socket: /var/run/mysqld/mysqlx.sock
db-1        | 2025-06-23T15:32:07.165234Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.42'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server - GPL.
meow-api-1  | 172.22.0.1 - - [23/Jun/2025 15:32:21] "GET /users HTTP/1.1" 200 -
meow-api-1  | 172.22.0.1 - - [23/Jun/2025 15:32:27] "GET /user/3 HTTP/1.1" 200 -
```

```bash
curl -i http://localhost:8000/users

HTTP/1.1 200 OK
Server: Werkzeug/3.1.3 Python/3.12.11
Date: Mon, 23 Jun 2025 15:32:21 GMT
Content-Type: application/json
Content-Length: 451
Connection: close

[{"favorite_insult":"You code like a Java dev on Monday morning","id":1,"name":"Jean-Kevin"},{"favorite_insult":"Your commit messages make Git cry","id":2,"name":"Brigitte"},{"favorite_insult":"You write CSS with inline styles\u00e2\u20ac\u00a6 in 2025","id":3,"name":"Mustafa"},{"favorite_insult":"You name variables like \"data1\" and \"stuff\"","id":4,"name":"Lucie"},{"favorite_insult":"Your SQL injections are just sad now","id":5,"name":"Bob"}]
```

```bash
curl -i http://localhost:8000/user/3

HTTP/1.1 200 OK
Server: Werkzeug/3.1.3 Python/3.12.11
Date: Mon, 23 Jun 2025 15:32:27 GMT
Content-Type: application/json
Content-Length: 105
Connection: close

{"favorite_insult":"You write CSS with inline styles\u00e2\u20ac\u00a6 in 2025","id":3,"name":"Mustafa"}
```