# Agent instructions: OpenClaw Tanzu Platform deployment

**Purpose:** Handoff for another Cursor agent. Read this to understand current state, the plan, and how to run the deployment.

---

## Where we are

- **Upstream:** [openclaw/openclaw](https://github.com/openclaw/openclaw) (original repo).
- **Fork:** [0pens0/openclaw](https://github.com/0pens0/openclaw). All deployment work lives on the fork.
- **Branch:** `tanzu-tailscale` (on the fork). Contains:
  - **GET /health** in `src/gateway/server-http.ts` (200 + `{ "ok": true }`) for CF/K8s health checks.
  - **deploy/** — CF manifest, Tailscale notes, deploy script, env example.
  - No changes to core app logic beyond the health endpoint.
- **Tanzu Platform (TAS/CF):**
  - **Org:** `tanzu-platform-demo`
  - **Space:** `openclaw` (created for this app)
  - **Target:** `cf target -o tanzu-platform-demo -s openclaw`
- **Image registry:** Harbor at `harbor.tp.penso.io`. Default image: `harbor.tp.penso.io/openclaw:latest`.
- **Remotes:** `origin` = openclaw/openclaw, `fork` = 0pens0/openclaw. Push deployment changes to `fork tanzu-tailscale`.

---

## What we plan

1. **Run OpenClaw on Tanzu Application Service (Cloud Foundry)** in a closed home lab.
2. **Expose the app via a public route** on the platform (platform is not on the public internet).
3. **Access only via Tailscale** — use a subnet router (or optional proxy) in the home lab so the tailnet can reach the app URL.
4. **Onboarding via Web UI** — no CLI wizard on the platform; use the Control UI (Config + Channels) in the browser after opening the app URL from the tailnet.

---

## How to run it

### 1. Repo and branch

```bash
git fetch fork
git checkout tanzu-tailscale
# Or clone the fork and checkout tanzu-tailscale
```

### 2. Build and push image

From repo root:

```bash
docker build -t harbor.tp.penso.io/openclaw:latest -f Dockerfile .
docker login harbor.tp.penso.io
docker push harbor.tp.penso.io/openclaw:latest
```

### 3. Deploy to TAS (org tanzu-platform-demo, space openclaw)

**Option A — script (from repo root):**

```bash
cf target -o tanzu-platform-demo -s openclaw
./deploy/cf/deploy-docker.sh
```

**Option B — manual:**

```bash
cf target -o tanzu-platform-demo -s openclaw
cf push openclaw --docker-image harbor.tp.penso.io/openclaw:latest -f deploy/cf/manifest.yml
cf set-env openclaw OPENCLAW_GATEWAY_TOKEN "$(openssl rand -hex 32)"
cf restage openclaw
```

### 4. Map route (use your platform domain)

```bash
cf map-route openclaw apps.YOUR-DOMAIN --hostname openclaw
```

### 5. Tailscale (home lab)

- Run Tailscale **subnet router** on a machine in the home lab that can reach the CF app URL.
- From a device on the tailnet, open the app URL in a browser.

### 6. Onboarding (Web UI)

- Open the app URL (via Tailscale).
- Enter the gateway token (same as `OPENCLAW_GATEWAY_TOKEN`).
- Use **Config** and **Channels** tabs to configure agents, channels (WhatsApp, Telegram, Slack, etc.), and models. Do not run `openclaw onboard` inside the platform.

---

## Key files

| Path | Purpose |
|------|--------|
| `deploy/cf/manifest.yml` | CF app manifest (Docker image, command, env, health-check `/health`). |
| `deploy/cf/deploy-docker.sh` | Build image, push to Harbor, `cf push` to current target. |
| `deploy/cf/README.md` | CF steps and options. |
| `deploy/tailscale/README.md` | Tailscale subnet router / proxy. |
| `deploy/env.example` | Example env vars for `~/.openclaw/.env`. |
| `deploy/README.md` | Overview, fork, env, order of operations. |

---

## Env and secrets

- **Local / gateway:** Put API keys and tokens in `~/.openclaw/.env` (or `$OPENCLAW_STATE_DIR/.env`). See `deploy/env.example`. Never commit secrets.
- **CF app:** Set `OPENCLAW_GATEWAY_TOKEN` via `cf set-env` (or user-provided service). Optional: mount a volume and put `.env` at `$OPENCLAW_STATE_DIR/.env` on the volume.

---

## If you change deployment assets

1. Keep changes on branch `tanzu-tailscale`.
2. Commit and push to the fork: `git push fork tanzu-tailscale`.
3. After updating the image (e.g. manifest or app code), rebuild, push to Harbor, then `cf push` (or `./deploy/cf/deploy-docker.sh`).
