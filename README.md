# containerized-ambari
Run Ambari within Docker containers!

# Building and starting the cluster
The database container must be started before running the build script, otherwise ambari-setup will fail when attempting to validate the connection to the database container.

## The run.sh script
    usage: docker/scripts/run.sh -d -c [-n #] [-h]
           -h or --help                    print this message and exit
           -d or --database                starts the database container
           -c or --cluster                 starts the cluster containers
           -n or --agent-node-count        specifies the number of ambari-agent containers

### From the scripts directory:
1. ./run.sh -d
1. ./build.sh
1. ./run.sh -c [-n *n*]

# Containers started by the run.sh script
Several containers are started by the run.sh script:

- run.sh -d
  - postgres
- run.sh -c -n *n*
  - traefik
  - ambari-server
  - ambari-node-1
  - ...
  - ambari-node-*n*

# Using Traefik
The Traefik dashboard is hosted at http://localhost:8080

Ambari's Admin UI is hosted at http://ambari.traefik.localhost

# Creating a cluster in Ambari's Admin UI
When adding hosts, use the following expression:

`ambari-node-[1-n].ambari-bridge`

where *n* is the number of containers running ambari-agent.

Select "Perform manual registration" since the ambari-agent is already installed as part of the ambari-agent containers' image. The warning dialogs can be dismissed, and the host registration process should be successful, allowing the cluster install to continue.

# Logging
You can tail the logs in any container:
- docker logs -f traefik
- docker logs -f ambari-server
- docker logs -f ambari-node-*n*
- docker logs -f postgres
