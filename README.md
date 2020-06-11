# Dockerfile file for Taiga

![](https://github.com/nemonik/taiga/workflows/Building%20and%20Pushed/badge.svg)

Taiga is an Open Source project management platform for Agile Development.

There are many project management platforms for Agile.

Typically, Agile teams work using a visual task management tool such as a project board, task board or Kanban or Scrum visual management board. These boards can be implemented using a whiteboard or open space on a wall or in software. The board is at a minimum segmented into a few columns To do, In process, and Done, but the board can be tailored. I've personally seen boards for very large projects consume every bit of wall space of a very large cavernous room, but as Lean-Agile has matured, teams have grown larger and more disparate, tools have emerged to provide a clear view into a project's management to all levels of concern (e.g., developers, managers, product owner, and the customer) answering:

- Are deadlines being achieved?
- Are team members overloaded?
- How much is complete?
- What's next?

Further, the Lean-Agile Software tools should provide the following capabilities:

- Dividing integration and development effort into multiple projects.
- Defining, allocating, and viewing resources and their workload across each product.
- Defining, maintaining, and prioritizing the accumulation of an individual product's requirements, features or technical tasks which, at a given moment, are known to be necessary and sufficient to complete a project's release.
- Facilitating the selection and assignment of individual requirements to resources, and the tracking of progress for a release.
- Permit collaboration with external third parties.
- The 800 pound Gorilla in this market segment is JIRA Software. Some of my co-workers hate it. It is part of the Atlassian suite providing provides collaboration software for teams with products including JIRA Software, Confluence, Bitbucket, and Stash. Back when Atlassian (Stocker ticker: TEAM) was trading at 50-dollars it was a good investment.

NOTE:

Lean-Agile Project Management software's primary purpose is to integrate people and really not much else.

## Documentation, source, container image

Taiga's documentation can be found at

https://taigaio.github.io/taiga-doc/dist/

It's canonical source can be found at

https://github.com/taigaio/taiga-front-dist/

dedicated to the front-end, and

https://github.com/taigaio/taiga-back/

dedicated to the back-end.

Taiga is not directly offer as Docker container, but I've authored a container image that collapses both taiga-front-dist and taiga-back behind an NGINX reverse proxy in a single container.

## How to pull the [nemonik/taiga:latest](https://hub.docker.com/r/nemonik/taiga) container image

Provided you have [Docker](https://www.docker.com/get-started) installed, enter the following into your command-line:

```bash
docker pull nemonik/taiga
```

## How to use

An example [docker-compose.yml](docker-compose.yml) is provided to demonstrate bringing up the Taiga container and it dependent PostgreSQL database service:

```yml
# Copyright (C) 2020 Michael Joseph Walsh - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the the license.
#
# You should have received a copy of the license with
# this file. If not, please email <github.com@nemonik.com>

version: "2"

services:
  postgresql:
    image:
      sameersbn/postgresql:10-2
    restart: always
    environment:
      - DB_NAME=taigadb
      - DB_USER=taiga
      - DB_PASS=password
    volumes:
      - ./volumes/postgresql/var/lib/postgresql:/var/lib/postgresql:Z
    ports:
      - "5432"

  taiga:
    image:
       nemonik/taiga:latest
    restart: always
    environment:
      - DEBUG=True
      - HOST=127.0.0.1
      - PORT=80
      - SCHEME=http
      - DB_HOST=postgresql
      - DB_PORT=5432
      - DB_NAME=taigadb
      - DB_USER=taiga
      - DB_PASSWORD=password
#      - LDAP_SERVER=ldap://FDQN
#      - LDAP_PORT=389
#      - LDAP_BIND_DN=uid=SERVICE ACCOUNT DN
#      - LDAP_BIND_PASSWORD=PASSWORD
#      - LDAP_SEARCH_BASE=BASE DN FOR USERS
#      - LDAP_SEARCH_FILTER_ADDITIONAL=(uid=*)
#      - LDAP_EMAIL_ATTRIBUTE=mail
#      - LDAP_FULL_NAME_ATTRIBUTE=cn
#      - LDAP_USERNAME_ATTRIBUTE=uid
    volumes:
      - ./volumes/media:/taiga/media:Z
      - ./volumes/static:/taiga/static:Z
    ports:
      - "80:8080"
    depends_on:
      - postgresql
```

Alternatively, you can orchestrate your deployment of Taiga via Kubernetes.  I use a templated version of the kubernetes resource file ([taiga.yml](taiga.yml)) in my [Hands-on DevOps class](https://github.com/nemonik/hands-on-DevOps) to sping up  Taiga on the private 192.168.0.204 IP address:

```yml
# Copyright (C) 2020 Michael Joseph Walsh - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the the license.
#
# You should have received a copy of the license with
# this file. If not, please email <github.com@nemonik.com>

---

apiVersion: v1
kind: Namespace
metadata:
  name: taiga

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-local-path-pvc
  namespace: taiga
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 2Gi

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
  namespace: taiga
  labels:
    app: postgresql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
      - name: postgresql
        image: sameersbn/postgresql:10-2
        imagePullPolicy: IfNotPresent
        env:
        - name: DB_NAME
          value: taigadb
        - name: DB_USER
          value: taiga
        - name: DB_PASS
          value: password
        ports:
        - name: postgres
          containerPort: 5432
        volumeMounts:
        - mountPath: /var/lib/postgresql
          name: data
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -h
            - localhost
            - -U
            - postgres
          initialDelaySeconds: 30
          timeoutSeconds: 5
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -h
            - localhost
            - -U
            - postgres
          initialDelaySeconds: 5
          timeoutSeconds: 1
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: postgresql-local-path-pvc

---

apiVersion: v1
kind: Service
metadata:
  name: postgresql
  namespace: taiga
spec:
  ports:
    - name: postgres
      port: 5432
      targetPort: postgres
  selector:
    app: postgresql

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: taiga-static-local-path-pvc
  namespace: taiga
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 2Gi

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: taiga-media-local-path-pvc
  namespace: taiga
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 2Gi

---

apiVersion: apps/v1
kind: Deployment  
metadata:
  name: taiga
  namespace: taiga
  labels:
    app: taiga
spec:
  replicas: 1
  selector:
    matchLabels:
      app: taiga
  template:
    metadata:
      labels:
        app: taiga
    spec:
      containers:
      - name: taiga
        image: nemonik/taiga:latest
        imagePullPolicy: IfNotPresent
        env:
        - name: DEBUG
          value: "true"
        - name: HOST
          value: 192.168.0.204
        - name: PORT
          value: "80"
        - name: SCHEME
          value: http
        - name: DB_HOST
          value: postgresql
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: taigadb
        - name: DB_USER
          value: taiga
        - name: DB_PASSWORD
          value: password
        ports:
        - name: http
          containerPort: 8080
        volumeMounts:
        - mountPath: /taiga/static
          name: static
        - mountPath: /taiga/media
          name: media
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 300
          periodSeconds: 10
          timeoutSeconds: 15
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 300
          periodSeconds: 10
          timeoutSeconds: 15
          failureThreshold: 3
      volumes:
      - name: static
        persistentVolumeClaim:
          claimName: taiga-static-local-path-pvc
      - name: media
        persistentVolumeClaim:
          claimName: taiga-media-local-path-pvc

---

apiVersion: v1
kind: Service
metadata:
  name: taiga
  namespace: taiga
spec:
  ports:
    - name: http
      targetPort: http
      port: 80
  selector:
    app: taiga
  type: LoadBalancer
  loadBalancerIP: 192.168.0.204
```

##  Username and password

The default admin account username and password are

admin
 
123123

## Additional content

If you're interested in learning more about Taiga and DevOps consider my [Hands-on DevOps Class](https://github.com/nemonik/hands-on-DevOps). 

## License

3-Clause BSD License

## Author Information

Michael Joseph Walsh <mjwalsh@nemonik.com>
