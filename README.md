# Essential docker commands

## Build image
```bash
docker build -t gui-img:1.0 -f Dockerfile .
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