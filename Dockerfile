# docker build -t veasion/stable-diffusion-webui .
# docker run --gpus all -p 9999:9999 -v /stable-diffusion-webui/models:/sd/models/ --rm -it veasion/stable-diffusion-webui bash
# python launch.py --listen --port 9999

# docker run -d --gpus all --name stable-diffusion-webui --network host -v /stable-diffusion-webui/models:/sd/models -v /stable-diffusion-webui/outputs:/sd/outputs -v /stable-diffusion-webui/extensions:/sd/extensions --rm veasion/stable-diffusion-webui bash webui.sh --skip-torch-cuda-test --precision full --port 9999 --listen --api --xformers --enable-insecure-extension-access

FROM nvidia/cuda:11.4.1-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt update && \
    apt install -yqq --no-install-recommends git libgl1-mesa-glx libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# install miniconda
ENV MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    MINICONDA_DIR=/opt/miniconda
ADD $MINICONDA_URL /tmp/miniconda-install.sh
WORKDIR /tmp
RUN chmod +x miniconda-install.sh && \
    ./miniconda-install.sh -bfp $MINICONDA_DIR && \
    rm -rf /tmp/* /var/lib/apt/lists/*

# setup conda env
RUN source $MINICONDA_DIR/bin/activate && \
    conda create -y --name sd python=3.10 && \
    conda activate sd && \
    echo "source $MINICONDA_DIR/bin/activate && conda activate sd" >> ~/.bashrc

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /sd && \
    cd /sd && \
    git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && \
    git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers && \
    git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer && \
    git clone https://github.com/salesforce/BLIP.git repositories/BLIP && \
    git clone https://github.com/crowsonkb/k-diffusion repositories/k-diffusion && \
    git clone https://github.com/TencentARC/GFPGAN repositories/GFPGAN && \
    git clone https://github.com/Hafiidz/latent-diffusion repositories/latent-diffusion

WORKDIR /sd
RUN source $MINICONDA_DIR/bin/activate && \
    conda activate sd && \
    pip install --prefer-binary torch transformers==4.19.2 diffusers invisible-watermark numpy

RUN source $MINICONDA_DIR/bin/activate && \
    conda activate sd && \
    pip install -r repositories/CodeFormer/requirements.txt --prefer-binary && \
    pip install -r repositories/k-diffusion/requirements.txt --prefer-binary && \
    pip install -r repositories/GFPGAN/requirements.txt --prefer-binary && \
    pip install -r requirements.txt  --prefer-binary
