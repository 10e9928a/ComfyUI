FROM nvidia/cuda:13.0.0-cudnn-runtime-ubuntu22.04

WORKDIR /ComfyUI

# 设置环境变量以避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 合并APT命令：添加PPA、安装Python和pip
RUN apt-get update && apt-get install -y \
    software-properties-common \
    pip \
    git \
    curl \
    cmake \
    ffmpeg \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件并安装
COPY requirements.txt .
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 && \
    pip3 install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 安装其他依赖
RUN pip3 install gguf && \
    pip3 install ftfy && \
    pip3 install onnx && \
    pip3 install diffusers && \
    pip3 install matplotlib && \
    pip3 install accelerate && \
    pip3 install sageattention && \
    pip3 install opencv-python && \
    pip3 install opencv-contrib-python && \
    pip3 install https://github.com/nunchaku-ai/nunchaku/releases/download/v1.1.0/nunchaku-1.1.0+torch2.9-cp310-cp310-linux_x86_64.whl

