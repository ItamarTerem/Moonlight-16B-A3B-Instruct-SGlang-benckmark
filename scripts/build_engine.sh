#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------
# Resolve environment paths
# ---------------------------------------
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${VENV:-${ROOT}/.venv}"

# Default to your downloaded model directory
MODEL_PATH="${MODEL_PATH:-${ROOT}/models/Moonlight-16B-A3B-Instruct}"

echo "======================================"
echo "Launching SGLang Server for Moonlight MoE"
echo "MODEL_PATH: $MODEL_PATH"
echo "======================================"

# ---------------------------------------
# Activate Virtual Environment
# ---------------------------------------
if [[ -f "$VENV/bin/activate" ]]; then
    source "$VENV/bin/activate"
else
    echo "ERROR: Virtual environment not found at $VENV."
    echo "Please run your setup.env script first."
    exit 1
fi

# ---------------------------------------
# Configure GPU Multi-Card Orchestration
# ---------------------------------------
# Count how many NVIDIA GPUs are visible on this system
NUM_GPUS=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)
echo "Detected $NUM_GPUS available GPU(s)."

# Calculate Tensor Parallelism degree based on your setup:
# For Moonlight-16B: 1 GPU is enough if it has >= 40GB VRAM (A100/H100/A30/RTX6000).
# If you are using multiple smaller consumer cards (like 2x or 4x RTX 3090/4090), TP will shard the weights.
TP_DEGREE=$NUM_GPUS

# ---------------------------------------
# Launch SGLang Engine
# ---------------------------------------
# Flags breakdown:
# --tp: Splittable Tensor Parallel processing across all active cards.
# --trust-remote-code: Required for customized structural layers (like MLA/Muon configs).
# --mem-fraction-static: Reserves 80% VRAM for weights/KV cache, preventing random OOM.
exec python3 -m sglang.launch_server \
    --model-path "$MODEL_PATH" \
    --host 0.0.0.0 \
    --port 30000 \
    --tp "$TP_DEGREE" \
    --trust-remote-code \
    --mem-fraction-static 0.8
