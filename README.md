# containerized-ambari
Run Ambari within Docker containers!

# Building and starting the cluster
From the scripts directory:
1. ./run.sh -d
1. ./build.sh
1. ./run.sh -c

# Logging
You can tail the ambari-server logs in the ambari-server container:
- docker logs -f ambari-server

or any of the agent containers:
- docker logs -f ambari-node-_n_

or the database container:
- docker logs -f postgres
