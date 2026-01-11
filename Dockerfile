FROM nvidia/cuda:13.0.0-cudnn-runtime-ubuntu22.04

WORKDIR /ComfyUI

RUN apt-get update
RUN apt-get install python3.11 -y
RUN apt-get install python-is-python3 -y
RUN apt-get install pip -y
RUN apt-get install git -y
RUN apt-get install curl -y
RUN apt-get install cmake -y
RUN apt-get install ffmpeg -y

# 复制依赖文件并安装（利用Docker缓存层）
COPY requirements.txt .

RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .
