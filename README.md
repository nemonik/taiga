# Dockerfile file for Taiga

Taiga is an Open Source project management platform for agile development.

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

Taiga doesn't directly offer a Docker container image for, but I've authored a container image that collapses both taiga-front-dist and -back behind an NGINX reverse proxy onto single container.

## How to use

This project contains a `docker-compose.yml` file to bring up the Taiga application and it dependent services:

```yml

```

##  Username and password

The default admin account username and password are

admin
123123

## License

3-Clause BSD License

## Author Information

Michael Joseph Walsh <mjwalsh@nemonik.com>
