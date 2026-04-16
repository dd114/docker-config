# Essential docker commands

## Build image
```bash
docker build -t gui-img:1.0 -f Dockerfile .
```

---

Or if you want to use NVIDIA preliminary find out your host Vulkan API version and then specify in build argument:
```bash
vulkaninfo | grep -E "apiVersion|deviceName|driverID"
```
```bash
docker build --build-arg VULKAN_API_VERSION=$HOST_VULKAN_VERSION -t gui-img:1.0 -f Dockerfile .
```

## Run container (w/ GPU support)
```bash
docker run -itd --name gui-cnt_1.0 -p 2222:22 -p 3389:3389 -p 1234:1234 -p 1235:1235 gui-img:1.0
```

## Run container with AMD GPU support (takes double-check)
```bash
docker run -itd --name gui-cnt_1.0 --device=/dev/dri --device=/dev/kfd --shm-size=2g -p 2222:22 -p 3389:3389 -p 1234:1234 -p 1235:1235 gui-img:1.0 zsh
```

## Run container with NVIDIA GPU support
```bash
docker run -itd --name gui-cnt_1.0 --env="NVIDIA_DRIVER_CAPABILITIES=all" --env="NVIDIA_VISIBLE_DEVICES=all" --gpus '"device=1"' --shm-size=2g -p 2222:22 -p 3389:3389 -p 1234:1234 -p 1235:1235 gui-img:1.0 zsh
```

## Exec to container 
```bash
docker exec -it dev-container_1.0 zsh
```

## Check Vulkan and OpenGL support:
```bash
vulkaninfo | grep -E "apiVersion|deviceName|driverID"
```
In XFCE terminal 
```bash
# export __GLX_VENDOR_LIBRARY_NAME=nvidia # Uncomment and put it to ~/.zshrc if you use NVIDIA
glxinfo | grep "OpenGL renderer"
```

## Notes:
* If you don't use NVIDIA to avoid annoying messages delete redundant configurations `rm /usr/share/glvnd/egl_vendor.d/10_nvidia.json /usr/share/vulkan/icd.d/nvidia_icd.json /etc/vulkan/implicit_layer.d/nvidia_layers.json`