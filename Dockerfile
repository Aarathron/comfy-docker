# Use the PyTorch base image with CUDA support
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for directories
ENV COMFYUI_HOME=/opt/ComfyUI
ENV MANAGER_HOME=/opt/ComfyUI-Manager

# Clone the ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git $COMFYUI_HOME

# Set working directory to ComfyUI and install Python dependencies
WORKDIR $COMFYUI_HOME
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Clone the ComfyUI-Manager repository
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git $MANAGER_HOME

# Set working directory to ComfyUI-Manager and install Python dependencies
WORKDIR $MANAGER_HOME
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Set the working directory back to ComfyUI
WORKDIR $COMFYUI_HOME

# Set up persistent data directories by linking to /workspace
RUN rm -rf $COMFYUI_HOME/models && \
    mkdir -p /workspace/models && \
    ln -s /workspace/models $COMFYUI_HOME/models

RUN rm -rf $COMFYUI_HOME/output && \
    mkdir -p /workspace/output && \
    ln -s /workspace/output $COMfyUI_HOME/output

# Expose necessary ports
EXPOSE 8188 8080

# Copy the startup script into the container
COPY startup.sh /startup.sh

# Make the startup script executable
RUN chmod +x /startup.sh

# Define the entrypoint to run the startup script
ENTRYPOINT ["/startup.sh"]
