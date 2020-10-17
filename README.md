# Storage Server

A server that is used for file sharing and hosting of files.

Spring Boot Rest (Kotlin) + Flutter

Supported platforms: Android, iOS, Web

## Build

- Install MySQL and setup the right user that is configured in the `run.sh`
- Run the scripts in the folders

There are scripts (`run.sh`) for you to run the frontend without the backend and vice versa:
    
To build everything:
From `storage-server/frontend` run `build.sh`:

    flutter build web
    rm -rf ../backend/src/main/resources/static/*
    cp -r build/web/* ../backend/src/main/resources/static/
    
From `storage-server/backend` run `build.sh` and then `run.sh`:

    bash mvnw clean install
    java -jar -Dport=8080 -Ddbhost=localhost:3306 -Ddbuser=denis -Dpassword=password -Dschema=storage_db target/*.jar


## Showcase

### Home page:

<img src="https://i.imgur.com/D7o7Nw3.png" />

### Move functionality: 

<img src="https://i.imgur.com/lQZKeCI.gif" />

### Home expanded:
<img src="https://i.imgur.com/ipCNaZU.png" />

### Mobile:
<img src="https://i.imgur.com/jgO5cZE.png" />

### Create new file:
<img src="https://i.imgur.com/KqCwaQV.png" />

### Share File:
<img src="https://i.imgur.com/BdnjK2V.png" />

### Log in:

<img src="https://i.imgur.com/29DQhEj.gif" />
