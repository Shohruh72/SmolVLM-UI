#!/bin/bash
set -e

# Load conda env
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate vlm

# Go to build folder
cd llama.cpp/build

# Read model from saved file (or fallback)
model=$(cat ../selected_model.txt 2>/dev/null || echo "ggml-org/SmolVLM-500M-Instruct-GGUF")

echo "🚀 Starting llama-server with model: $model"
./bin/llama-server -hf "$model"
