[![Build Container](https://github.com/theislab/extended-single-cell-best-practices-container/actions/workflows/build_container.yml/badge.svg)](https://github.com/theislab/extended-single-cell-best-practices-container/actions/workflows/build_container.yml)
[![Publish Container](https://github.com/theislab/extended-single-cell-best-practices-container/actions/workflows/publish_container.yml/badge.svg)](https://github.com/theislab/extended-single-cell-best-practices-container/actions/workflows/publish_container.yml)

# extended-single-cell-best-practices-container

This container is used for building the [extended single-cell best-practices book](https://github.com/theislab/extended-single-cell-best-practices).
To run this container with docker, first make sure you have docker [installed](https://docs.docker.com/get-docker/) on your machine.

When you need to update the container, proceed as follows:

1. Push your desired changes to the Dockerfile (or any associated files) to a new branch in this repository.
2. Once you're happy with your changes, open a pullrequest against the `main` branch. This will trigger an automatic build of the updated container.
3. If (and only if) your build succeeds, you'll be able to merge your pullrequest in to the `main` branch. If the build fails, check the output of the failed GitHub actions workflow and fix any bugs in your Dockerfile. Once you have pushed your fixes to the pullrequest, the build of the container will restart.
4. After successfully merging your changes into the `main` branch, publish a new release to trigger pushing the new container to the container repository. Make sure to provide a meaningful title and description to your release, highlighting the changes you made. **Important:** when creating the release, you're asked to define a new tag. This tag is also used to version the container builds. Please make sure that you adhere to the semantic versioning schema and use the following tag format: `vX.X.X` (where X is a number).
5. Once the building and publishing of the new container is done, you can see the new version appear [here](https://github.com/theislab/extended-single-cell-best-practices-container/pkgs/container/extended-single-cell-best-practices-container/versions). This currently takes about an hour.

Start the container using the following command:
```bash
sudo docker run --rm -it --publish 8888-8892:8888-8892 --volume $HOME:/root/host_home --workdir /root ghcr.io/theislab/extended-single-cell-best-practices-container:latest /bin/bash
```
**Note:** you can also use a specific version tag of the container instead of the `latest` tag in the command above. See [here](https://github.com/theislab/extended-single-cell-best-practices-container/pkgs/container/extended-single-cell-best-practices-container/versions) for all currently available version tags.

To pull the latest version of the container, use this command:
```bash
sudo docker pull ghcr.io/theislab/extended-single-cell-best-practices-container:latest
```