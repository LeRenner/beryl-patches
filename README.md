# Beryl Patches

Local patches for the GL.iNet Beryl AX (GL-MT3000).

These patches modify vendor firmware files while keeping the original files backed up locally so that patches can be removed cleanly.

## Repository layout

```text
.
├── apply.sh
├── remove.sh
├── status.sh
└── patches/
    └── tailscale-headscale/
        ├── apply.sh
        └── remove.sh
```

## Installing

Clone the repository on the Beryl:

```sh
cd /root
git clone <REPOSITORY_URL> beryl-patches
cd beryl-patches
```

Then:

```sh
./apply.sh
```

## Removing

```sh
./remove.sh
```

Individual patches can also be operated on directly:

```sh
./patches/tailscale-headscale/apply.sh
./patches/tailscale-headscale/remove.sh
```

## Checking status

```sh
./status.sh
```

## Updating

From the router:

```sh
cd /root/beryl-patches
git pull
./status.sh
```

If a firmware update changed one of the files being patched, inspect the changes before applying the patch again.

## Important

The repository itself does not contain backups of the router's original files.

Backups are stored locally on the router in:

```text
/var/lib/beryl-patches/
```

Do not delete this directory while patches are installed.
