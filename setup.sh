#!/bin/bash

# Exit on error
set -e

# --------------------
# MODEL SELECTION
# --------------------
echo "📦 Available Models:"
models=(
    "ggml-org/SmolVLM-Instruct-GGUF"
    "ggml-org/SmolVLM-256M-Instruct-GGUF"
    "ggml-org/SmolVLM-500M-Instruct-GGUF"
    "ggml-org/SmolVLM2-2.2B-Instruct-GGUF"
    "ggml-org/SmolVLM2-256M-Video-Instruct-GGUF"
    "ggml-org/SmolVLM2-500M-Video-Instruct-GGUF"
)

for i in "${!models[@]}"; do
    echo "$((i+1))) ${models[$i]}"
done

echo -n "➡️  Select model [1-${#models[@]}] (default 3): "
read -r selection
model="${models[${selection:-3}-1]}"

echo "✅ Selected model: $model"

# --------------------
# SYSTEM SETUP
# --------------------
echo "🔁 Updating system..."
sudo apt update
sudo apt install -y build-essential cmake git

# --------------------
# CONDA SETUP
# --------------------
echo "🐍 Creating Conda environment 'vlm'..."
conda create -n vlm python=3.9 -y

echo "🔁 Activating environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate vlm

# --------------------
# CLONE & BUILD
# --------------------
if [ -d "llama.cpp" ]; then
    echo "🗑️  Removing existing llama.cpp directory..."
    rm -rf llama.cpp
fi

echo "📦 Cloning llama.cpp..."
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

echo "🛠️ Building llama.cpp with llama-server..."
mkdir build
cd build
cmake .. -DLLAMA_SERVER=ON -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release

# --------------------
# START SERVER
# --------------------
echo "🚀 Starting llama-server with model: $model"
./bin/llama-server -hf "$model"
