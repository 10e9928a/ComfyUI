FROM nvidia/cuda:13.0.0-cudnn-runtime-ubuntu22.04

WORKDIR /ComfyUI

# 设置环境变量以避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 合并APT命令：添加PPA、安装Python和pip
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    curl \
    cmake \
    ffmpeg \
    wget \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
        python3.12 \
        python3.12-dev \
        python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建指向python3.12的符号链接
RUN ln -sf /usr/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.12 /usr/bin/python

# 确保pip指向正确版本（可选）
RUN pip3 install --upgrade pip

# 复制依赖文件并安装
COPY requirements.txt .
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 && \
    pip3 install --no-cache-dir -r requirements.txt

# 安装其他依赖
RUN pip3 install gguf && \
    pip3 install https://github.com/nunchaku-ai/nunchaku/releases/download/v1.1.0/nunchaku-1.1.0+torch2.9-cp312-cp312-linux_x86_64.whl

# 复制项目文件
COPY . .