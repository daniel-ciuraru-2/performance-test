echo "Start test"
echo $(date +%s)

# disable for run with cache
trivy clean --all
# trivy server params to add: --use-trivy-server --trivy-server-url https://us-east-1.staging.edge.cloud.aquasec.com 
CONTAINER_ID=$( \
export TRIVY_RUN_AS_PLUGIN=aqua
export CSPM_URL=https://stage.api.cloudsploit.com
export AQUA_URL=https://api.dev.supply-chain.cloud.aquasec.com
export WORKSPACE=$PWD
export SKIP_CODE_METADATA=true
docker run -d -p 8082:80 -v /Users/danielciuraru/Library/Caches/trivy:/tmp/.cache/trivy -it \
-e AQUA_KEY \
-e AQUA_SECRET \
-e TRIVY_RUN_AS_PLUGIN \
-e CSPM_URL \
-e AQUA_URL \
-e INPUT_WORKING_DIRECTORY=/scanning \
-v "$WORKSPACE":"/scanning" \
aquasec/aqua-scanner:latest \
trivy fs --scanners vuln,misconfig,secret --sast --output res.json --format json .)

# Monitor the container's network I/O every 0.5 second while it's running
while [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_ID")" == "true" ]; do
    # Extract only the Network I/O information and print it
    NETWORK_IO=$(docker stats "$CONTAINER_ID" --no-stream --format "{{.NetIO}}")
    echo "Network I/O: $NETWORK_IO"
    sleep 0.5
done

# Wait for the container to exit completely
docker wait "$CONTAINER_ID"

echo "End test"
echo $(date +%s)