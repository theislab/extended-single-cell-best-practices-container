[![Build Container](https://github.com/theislab/extended-single-cell-best-practices-container/actions/workflows/build_container.yml/badge.svg)](https://github.com/theislab/extended-single-cell-best-practices-container/actions/workflows/build_container.yml)
# extended-single-cell-best-practices-container

This container is used for building the [extended single-cell best-practices book](https://github.com/theislab/extended-single-cell-best-practices).

To run this container with docker, first make sure you have docker [installed](https://docs.docker.com/get-docker/) on your machine.

Start the container with this command:
```bash
sudo docker run --rm -it --publish 8888-8892:8888-8892 --volume $HOME:/root/host_home --workdir /root ghcr.io/theislab/extended-single-cell-best-practices-container:latest /bin/bash
```

To pull the latest version of the container, use this command:
```bash
sudo docker pull ghcr.io/theislab/extended-single-cell-best-practices-container:latest
```