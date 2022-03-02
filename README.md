# extended-single-cell-best-practices-container

This container is used for building the [extended single-cell best-practices book](https://github.com/theislab/extended-single-cell-best-practices).

To run this container with docker, first make sure you have docker [installed](https://docs.docker.com/get-docker/) on your machine.

Next, authenticate as a member of the theislab organisation with the command below, followed by providing your personal GitHub token as a password when prompted.
If you do not have a toke yet, you can create one in your GitHub settings (Settings / Developer settings).
Note that the token needs to have the `read:packages` scope activated.
```bash
sudo docker login ghcr.io -u theislab
```

Next, pull the latest version of the container.
```bash
sudo docker pull ghcr.io/theislab/extended-single-cell-best-practices-container:latest
```

Finally, start the container.
```bash
sudo docker run --rm -it --publish 8888-8892:8888-8892 --volume $HOME:/root/host_home --workdir /root ghcr.io/theislab/extended-single-cell-best-practices-container:latest /bin/bash
```