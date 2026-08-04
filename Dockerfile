FROM pytorch/pytorch:2.13.0-cuda13.0-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        ffmpeg \
        git \
        libgl1 \
        libglib2.0-0 \
        libgomp1 \
        libsndfile1 \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/opt/venv
RUN python -m venv --system-site-packages "${VIRTUAL_ENV}"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

WORKDIR /opt/ComfyUI

COPY requirements.txt ./
RUN python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install -r requirements.txt

COPY . .

ARG KJNODES_REF=827fe6ee0ed7348d8daa988ed852bedf1272380c
ARG GGUF_REF=6ea2651e7df66d7585f6ffee804b20e92fb38b8a
ARG WAN_VIDEO_WRAPPER_REF=088128b224242e110d3906c6750e9a3a348a659b
ARG VIDEO_HELPER_SUITE_REF=4ee72c065db22c9d96c2427954dc69e7b908444b
ARG INDEX_TTS2_REF=5b33e02bc0112b8aaf1fc823d5e5a609ca07fc27
ARG LAYER_STYLE_REF=02acdc50affb84cd24f341d1fc2d3a9134b2ad3d
ARG LLM_REF=8136a55c94766ae40357c0781344431af7e95e96

RUN set -eux; \
    install_node() { \
        repository="$1"; \
        destination="$2"; \
        revision="$3"; \
        git init "${destination}"; \
        git -C "${destination}" remote add origin "${repository}"; \
        git -C "${destination}" fetch --depth 1 origin "${revision}"; \
        git -C "${destination}" checkout -B main FETCH_HEAD; \
    }; \
    install_node https://github.com/kijai/ComfyUI-KJNodes.git custom_nodes/ComfyUI-KJNodes "${KJNODES_REF}"; \
    install_node https://github.com/city96/ComfyUI-GGUF.git custom_nodes/ComfyUI-GGUF "${GGUF_REF}"; \
    install_node https://github.com/kijai/ComfyUI-WanVideoWrapper.git custom_nodes/ComfyUI-WanVideoWrapper "${WAN_VIDEO_WRAPPER_REF}"; \
    install_node https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git custom_nodes/ComfyUI-VideoHelperSuite "${VIDEO_HELPER_SUITE_REF}"; \
    install_node https://github.com/snicolast/ComfyUI-IndexTTS2.git custom_nodes/ComfyUI-IndexTTS2 "${INDEX_TTS2_REF}"; \
    install_node https://github.com/chflame163/ComfyUI_LayerStyle.git custom_nodes/ComfyUI_LayerStyle "${LAYER_STYLE_REF}"; \
    install_node https://github.com/10e9928a/ComfyUI-LLM.git custom_nodes/ComfyUI-LLM "${LLM_REF}"

RUN set -eux; \
    combined_requirements=/tmp/custom-node-requirements.txt; \
    : > "${combined_requirements}"; \
    for requirements in \
        custom_nodes/ComfyUI-KJNodes/requirements.txt \
        custom_nodes/ComfyUI-GGUF/requirements.txt \
        custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt \
        custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt \
        custom_nodes/ComfyUI-IndexTTS2/requirements.txt \
        custom_nodes/ComfyUI_LayerStyle/requirements.txt \
        custom_nodes/ComfyUI-LLM/requirements.txt; \
    do \
        sed '/^[[:space:]]*opencv-/d' "${requirements}" >> "${combined_requirements}"; \
        printf '\n' >> "${combined_requirements}"; \
    done; \
    python -m pip install -r "${combined_requirements}" opencv-contrib-python-headless click==8.2.1 onnx==1.19.1 sageattention==1.0.6; \
    python -m pip check; \
    python -c 'import cv2, gguf, onnx, sageattention, soundfile; assert hasattr(cv2, "ximgproc")'; \
    rm -f "${combined_requirements}"

EXPOSE 8188

CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
