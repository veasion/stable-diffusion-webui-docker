# build image
```sh
docker build -t veasion/stable-diffusion-webui .
```

# run image
```sh
# docker image
docker pull veasion/stable-diffusion-webui

# run docker
docker run -d --gpus all --name stable-diffusion-webui -p 9999:9999 -v /stable-diffusion-webui/models:/sd/models -v /stable-diffusion-webui/outputs:/sd/outputs -v /stable-diffusion-webui/extensions:/sd/extensions veasion/stable-diffusion-webui

# bash
docker exec -it stable-diffusion-webui bash
python launch.py --skip-torch-cuda-test --precision full --port 9999 --no-half --listen --api --xformers --enable-insecure-extension-access

```
