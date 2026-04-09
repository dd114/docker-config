# Essential docker commands

## Build image
```bash
docker build -t basic:1.0 .
```

## Run container
```bash
docker run -it \
  --name test1.1 \
  -p 2222:22 \
  -p 3389:3389 \
  -p 1234:1234 \
  -p 1235:1235 \
  basic:1.0
```