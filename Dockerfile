# Use the PyTorch base image with CUDA support
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
    && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for directories
ENV COMFYUI_HOME=/opt/ComfyUI

# Clone the ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git $COMFYUI_HOME

# Set working directory to ComfyUI and install Python dependencies
WORKDIR $COMFYUI_HOME
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Install ComfyUI-Manager as a custom node
RUN mkdir -p $COMFYUI_HOME/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git $COMFYUI_HOME/custom_nodes/ComfyUI-Manager

# Install additional dependencies for ComfyUI-Manager (if any)
RUN pip install -r $COMFYUI_HOME/custom_nodes/ComfyUI-Manager/requirements.txt || echo "No additional requirements"

# Set up persistent data directories by linking to /workspace
RUN rm -rf $COMFYUI_HOME/models && \
    mkdir -p /workspace/models && \
    ln -s /workspace/models $COMFYUI_HOME/models

RUN rm -rf $COMFYUI_HOME/output && \
    mkdir -p /workspace/output && \
    ln -s /workspace/output $COMFYUI_HOME/output

# Expose the necessary port
EXPOSE 8188

# Define the command to start ComfyUI
CMD ["python", "main.py", "--listen", "--port", "8188"]
