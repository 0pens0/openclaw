# OpenClaw on Tanzu Platform (Cloud Foundry / TAS)

Deploy OpenClaw as an app in a Space on Tanzu Application Service (TAS). The platform runs in your closed home lab; use a **public route** and **Tailscale** for access (see [deploy/tailscale/](../tailscale/)).

## Prerequisites

- Tanzu Platform (TAS) with at least one org and Space
- `cf` CLI (or `tanzu` CLI with Spaces) logged in and targeting that org/space
- Container registry reachable from the platform (Docker Hub, GHCR, Harbor)
- Optional: volume services (NFS/SMB) for persistent state

## Steps

**Option: run the deploy script** (build, push image, cf push) from repo root:

```bash
./deploy/cf/deploy-docker.sh
```

Or do it step by step:

1. **Build and push the Docker image** from this repo (e.g. from your fork):

   ```bash
   docker build -t YOUR_REGISTRY/openclaw:latest -f Dockerfile .
   docker push YOUR_REGISTRY/openclaw:latest
   ```

2. **Edit `manifest.yml`**: set `docker.image` to your image URL (e.g. `ghcr.io/0pens0/openclaw:latest`).

3. **Set the gateway token** (do not commit):

   ```bash
   cf set-env openclaw OPENCLAW_GATEWAY_TOKEN "$(openssl rand -hex 32)"
   ```

   Or use a user-provided service that exposes credentials.

4. **Create a volume service** (if your platform has NFS/SMB volume services) and note the mount path (e.g. `/home/vcap/data`). Bind it to the app after push. If no volume service, state will be ephemeral (not recommended for production).

5. **Deploy**:

   ```bash
   cf push -f manifest.yml
   ```

   Or use `tanzu deploy` if your Tanzu Platform uses that for Spaces.

6. **Map a public route** (app is still only reachable from within the home lab):

   ```bash
   cf map-route openclaw apps.YOUR-DOMAIN --hostname openclaw
   ```

7. **Set up Tailscale** in the home lab so devices on your tailnet can reach the app URL. See [deploy/tailscale/README.md](../tailscale/README.md).

## Env and secrets

- Put API keys and tokens in `$OPENCLAW_STATE_DIR/.env` on the mounted volume (see [deploy/README.md](../README.md)), or set them via `cf set-env` / app env in the manifest (do not commit secrets).
- The gateway listens on `PORT` (often 8080). The manifest overrides the start command so it uses `--port 8080 --bind 0.0.0.0`.

## Onboarding

Use the **Control UI** in your browser (open the app URL via Tailscale). Enter the gateway token when prompted. Then use the Config and Channels tabs to configure agents, channels (WhatsApp, Telegram, Slack, etc.), and models. No CLI wizard inside the platform.
