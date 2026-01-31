# OpenClaw deployment (Tanzu Platform + Tailscale)

This folder contains assets to run OpenClaw on **Tanzu Application Service (TAS)** / Cloud Foundry in a **closed home lab**, with access only via **Tailscale**.

- **[deploy/cf/](cf/)** — CF app manifest and steps (build image, push, map public route, volume service).
- **[deploy/tailscale/](tailscale/)** — Tailscale subnet router (or optional proxy) so your tailnet can reach the app.

## Fork and branch

This deployment is maintained on the **tanzu-tailscale** branch. To keep changes on your fork (e.g. 0pens0/openclaw):

1. Fork the repo on GitHub (if not already): https://github.com/openclaw/openclaw → Fork to your user/org.
2. Add your fork as a remote and push the branch:
   ```bash
   git remote add fork https://github.com/0pens0/openclaw.git
   git push fork tanzu-tailscale
   ```
3. Open a PR from `tanzu-tailscale` to `main` in the upstream repo if you want to contribute back, or keep the branch only on your fork.

## Env and API keys

Put integration keys (OpenAI, Anthropic, Telegram, Slack, gateway token, etc.) in **`~/.openclaw/.env`** (or `$OPENCLAW_STATE_DIR/.env`). That path is never in the repo. The gateway loads it at startup. See repo root `.env.example` and `deploy/env.example` for a list of env vars. Full config docs: https://docs.openclaw.ai/gateway/configuration.

For CF: set `OPENCLAW_STATE_DIR` to the mounted volume path (e.g. `/home/vcap/data`); then the same `.env` file lives on the volume. Or set individual vars via `cf set-env` / manifest (do not commit secrets).

## Order of operations

1. Fork, checkout `tanzu-tailscale`, push to your fork.
2. Build Docker image from the fork and push to your registry.
3. Deploy to TAS (see [cf/README.md](cf/README.md)); set gateway token and optional volume service; map public route.
4. Set up Tailscale in the home lab (see [tailscale/README.md](tailscale/README.md)).
5. Open the app URL from a device on the tailnet; use the Control UI to configure (Config + Channels). No CLI onboarding on the platform.
