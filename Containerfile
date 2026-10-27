# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Base Image: Bazzite Deck NVIDIA (Steam Gaming Mode / Gamescope + Nvidia drivers + KDE Plasma)
FROM ghcr.io/ublue-os/bazzite-deck-nvidia:stable

### MODIFICATIONS
## Modifications and custom packages executed via build.sh with BuildKit mounts
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/build.sh

### LINTING
## Verify final image and contents comply with bootc standards
RUN bootc container lint
