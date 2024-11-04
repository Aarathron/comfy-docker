# Start from the PyTorch image with CUDA 11.7 support
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
    && \
    rm -rf /var/lib/apt/lists/*

# Clone the ComfyUI repository into /opt/ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI

# Set the working directory
WORKDIR /opt/ComfyUI

# Install Python packages required by ComfyUI
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Map the 'models' directory to '/workspace/models' for data persistence
RUN rm -rf /opt/ComfyUI/models && \
    mkdir -p /workspace/models && \
    ln -s /workspace/models /opt/ComfyUI/models

# Map the 'output' directory to '/workspace/output' for data persistence
RUN rm -rf /opt/ComfyUI/output && \
    mkdir -p /workspace/output && \
    ln -s /workspace/output /opt/ComfyUI/output

# Expose port 8188 to access the ComfyUI interface
EXPOSE 8188

# Run ComfyUI with the '--listen' argument to accept external connections
CMD ["python", "main.py", "--listen"]
