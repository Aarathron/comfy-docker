# Stage 1: Builder
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime AS builder

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        unzip \
    && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV COMFYUI_HOME=/opt/ComfyUI

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git $COMFYUI_HOME

# Set working directory to ComfyUI and install Python dependencies
WORKDIR $COMFYUI_HOME
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Clone ComfyUI-Manager as a custom node
RUN mkdir -p $COMFYUI_HOME/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git $COMFYUI_HOME/custom_nodes/ComfyUI-Manager

# Install ComfyUI-Manager dependencies
RUN pip install -r $COMFYUI_HOME/custom_nodes/ComfyUI-Manager/requirements.txt || echo "No additional requirements for ComfyUI-Manager"

# Clone Pinokio as a custom node
RUN git clone https://github.com/pinokiocomputer/pinokio.git $COMFYUI_HOME/custom_nodes/pinokio

# Install Pinokio dependencies
RUN pip install -r $COMFYUI_HOME/custom_nodes/pinokio/requirements.txt || echo "No additional requirements for Pinokio"

# Stage 2: Final Image
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        unzip \
    && \
    rm -rf /var/lib/apt/lists/*

# Copy ComfyUI setup from builder
COPY --from=builder /opt/ComfyUI /opt/ComfyUI

# Set working directory
WORKDIR /opt/ComfyUI

# Set up persistent data directories by linking to /workspace
RUN rm -rf /opt/ComfyUI/models && \
    mkdir -p /workspace/models && \
    ln -s /workspace/models /opt/ComfyUI/models

RUN rm -rf /opt/ComfyUI/output && \
    mkdir -p /workspace/output && \
    ln -s /workspace/output /opt/ComfyUI/output

# Expose the necessary port
EXPOSE 8188

# Define the command to start ComfyUI
CMD ["python", "main.py", "--listen", "--port", "8188"]
