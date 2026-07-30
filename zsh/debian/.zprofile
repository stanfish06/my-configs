# Make sway render on the NVIDIA dGPU (card wired to the HDMI port) and treat
# the Intel iGPU as secondary. Fixes tearing on the external monitor caused by
# the unsynchronized Intel->NVIDIA cross-GPU copy (NVIDIA proprietary driver
# lacks implicit sync). by-path names are stable across boots, unlike cardN.
export WLR_DRM_DEVICES=/dev/dri/by-path/pci-0000:01:00.0-card:/dev/dri/by-path/pci-0000:00:02.0-card
