

Portable ANTsR docker app based on minimal ubuntu:18.04 image.

https://hub.docker.com/r/rocker/r-ubuntu

```
docker build  -t  uantsr .
```

to push an update

```
 docker tag antsr:latest stnava/antsr:latest
 docker push  stnava/antsr:latest
```


Users should run


```
docker run -p 8888:8888 antsr:latest
```

and then open the listed weblink.

or just run into bash directly

```
docker run -it --rm antsr:latest /bin/bash
```

