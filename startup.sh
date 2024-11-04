#!/bin/bash

# Function to start ComfyUI
start_comfyui() {
    echo "Starting ComfyUI..."
    cd /opt/ComfyUI
    python main.py --listen --port 8188
}

# Function to start ComfyUI-Manager
start_manager() {
    echo "Starting ComfyUI-Manager..."
    cd /opt/ComfyUI-Manager
    python manager.py --port 8080
}

# Start both services in the background
start_comfyui &
start_manager &

# Wait for all background processes to finish
wait
