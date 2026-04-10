# Essential docker commands

## Build image
```bash
docker build -t dev-image:1.0 .
```

## Run container (w\ GPU support)
```bash
docker run -itd --name dev-container_1.0 -p 2222:22 -p 3389:3389 -p 1234:1234 -p 1235:1235 dev-image:1.0
```

## Run container (with GPU support)
```bash
docker run -itd --name dev-container_1.0 --device /dev/dri --gpus all -p 2222:22 -p 3389:3389 -p 1234:1234 -p 1235:1235 dev-image:1.0
```

## Exec to container 
```bash
docker exec -it dev-container_1.0
```