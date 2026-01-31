# Tailscale access for OpenClaw on Tanzu Platform (CF)

The platform runs in your **closed home lab**. OpenClaw has a **public route** on the platform, but that route is only reachable from within the home lab. **Tailscale** is how you reach the home lab from your devices (e.g. laptop).

## Recommended: Tailscale subnet router

1. Run **Tailscale** on a machine in your home lab that can reach the CF router and the app public URL (e.g. `openclaw.apps.YOUR-DOMAIN` or your platform app URL).

2. Enable **subnet router** (advertise the home lab subnet or the CF router subnet) so devices on your tailnet can route to the lab. See [Tailscale subnet router docs](https://tailscale.com/kb/1019/subnets/).

3. From a device on the tailnet, open the app public URL in a browser (e.g. `https://openclaw.apps.YOUR-DOMAIN`). Traffic goes: device → Tailscale → subnet router → home lab → gorouter → app. No reverse proxy required.

## Optional: reverse proxy on a Tailscale node

If you prefer a single Tailscale hostname (e.g. `openclaw.your-tailnet.ts.net`) instead of the platform app URL:

1. Run a **reverse proxy** (nginx, Caddy, or Tailscale serve) on a VM in the lab that is on the tailnet.
2. Proxy HTTPS from the tailnet to the app public URL (e.g. `http://openclaw.apps.internal:8080` or your internal app URL).
3. Use Tailscale ACLs so only your tailnet users/machines can reach this proxy.

See `proxy-example.conf` for an nginx example.
