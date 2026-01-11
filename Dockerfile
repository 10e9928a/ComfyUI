FROM nvidia/cuda:13.0.0-cudnn-runtime-ubuntu22.04

WORKDIR /ComfyUI

# 合并APT命令以减少镜像层数
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git \
    curl \
    cmake \
    ffmpeg \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 添加deadsnakes PPA（提供Python 3.12）
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update

# 安装Python 3.12及相关组件
RUN apt-get install -y \
    python3.12 \
    python3.12-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建指向python3.12的符号链接（替代python-is-python3）
RUN ln -sf /usr/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.12 /usr/bin/python

# 复制依赖文件并安装（利用Docker缓存层）
COPY requirements.txt .
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 && \
    pip3 install --no-cache-dir -r requirements.txt

# 安装其他依赖
RUN pip3 install gguf && \
    pip3 install https://github.com/nunchaku-ai/nunchaku/releases/download/v1.1.0/nunchaku-1.1.0+torch2.9-cp312-cp312-linux_x86_64.whl

# 复制项目文件
COPY . .
