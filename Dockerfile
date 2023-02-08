# Always start from the latest Nyx Docker image fetched by Docker Hub
FROM mooltiverse/nyx:latest

# Store the entrypoint into the container. See comments inside the entrypoint.sh
COPY entrypoint.sh /entrypoint.sh

# Run the entrypoint, which runs Nyx and parses its output to return Action outputs to $GITHUB_OUTPUT
ENTRYPOINT ["/entrypoint.sh"]
