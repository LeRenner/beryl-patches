# Beryl Patches

Patches for the GL.iNet Beryl AX (GL-MT3000).

These patches modify vendor firmware files while keeping backups of the
original files on the router.

## Current patches

### tailscale-headscale

Keeps GL.iNet's Tailscale integration pointed at the self-hosted Headscale
control server instead of resetting to the public Tailscale control plane.

Modified file:

```text
/usr/bin/gl_tailscale
```

The patch changes:

```text
tailscale up --reset --accept-routes ...
```

to:

```text
tailscale up --reset --login-server=https://headscale.pudim.xyz --accept-routes ...
```

## Usage

Apply all patches:

```sh
./apply.sh
```

Remove all patches:

```sh
./remove.sh
```

Check patch status:

```sh
./status.sh
```

## Backups

Original files are backed up on the router under:

```text
/var/lib/beryl-patches/
```

The Git repository contains patch logic, not the router's original files.

## Updating

After updating the repository:

```sh
git pull
./status.sh
```

Patches refuse to apply if the expected vendor firmware code is not found.
This prevents accidentally modifying an incompatible firmware version.
