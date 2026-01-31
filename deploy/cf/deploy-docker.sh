#!/usr/bin/env bash
# Build OpenClaw image, push to registry, and deploy to TAS/CF in tanzu-platform-demo / openclaw.
# Run from repo root. Requires: docker, cf CLI logged in, image registry (e.g. GHCR or Docker Hub).
set -euo pipefail

ORG="${CF_ORG:-tanzu-platform-demo}"
SPACE="${CF_SPACE:-openclaw}"
APP_NAME="${CF_APP_NAME:-openclaw}"
IMAGE="${IMAGE:-ghcr.io/0pens0/openclaw:latest}"

echo "Target: org=$ORG space=$SPACE app=$APP_NAME"
echo "Image: $IMAGE"
echo "Ensure you are logged in: cf target -o $ORG -s $SPACE"
read -r -p "Continue? [y/N] " reply
if [[ ! "${reply,,}" =~ ^y ]]; then
  exit 0
fi

cd "$(dirname "$0")/../.."
echo "Building Docker image..."
docker build -t "$IMAGE" -f Dockerfile .

echo "Pushing image to registry (docker login may be required)..."
docker push "$IMAGE"

echo "Deploying to CF..."
cf target -o "$ORG" -s "$SPACE"
cf push "$APP_NAME" --docker-image "$IMAGE" -f deploy/cf/manifest.yml

echo "Set gateway token: cf set-env $APP_NAME OPENCLAW_GATEWAY_TOKEN \$(openssl rand -hex 32)"
echo "Restage if you set env: cf restage $APP_NAME"
