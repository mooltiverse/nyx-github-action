FROM alpine:3.17.1

# Put the latest Nyx binary into the image
ADD https://github.com/mooltiverse/nyx/releases/latest/download/nyx-linux-amd64 /usr/bin/nyx
RUN chmod 755 /usr/bin/nyx

# Also install Git, as it's required by the libraries used in Go
RUN apk update && \
    apk add git

# Store the entrypoint into the container. See comments inside the entrypoint.sh
COPY entrypoint.sh /entrypoint.sh

# Run the entrypoint, which runs Nyx and parses its output to return Action outputs to $GITHUB_OUTPUT
ENTRYPOINT ["/entrypoint.sh"]
