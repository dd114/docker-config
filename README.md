# Essential docker commands

## Build image
```bash
docker build -t dev-image:1.0 .
```

## Run container
```bash
docker run -it \
  --name dev-container:1.0 \
  -p 2222:22 \
  -p 3389:3389 \
  -p 1234:1234 \
  -p 1235:1235 \
  dev-image:1.0
```

## Exec to container
```bash
docker exec -it dev-container:1.0
```