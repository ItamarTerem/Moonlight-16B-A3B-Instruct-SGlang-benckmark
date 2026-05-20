#!/usr/bin/env bash
set -euo pipefail

# Step out of the scripts directory to find the true project root
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODEL_ID="${MODEL_ID:-moonshotai/Moonlight-16B-A3B-Instruct}"
MODEL_DIR="${MODEL_DIR:-${ROOT}/models/Moonlight-16B-A3B-Instruct}"
REVISION="${REVISION:-}"

echo "======================================"
echo "Kimi model downloader"
echo "MODEL_ID: $MODEL_ID"
echo "MODEL_DIR: $MODEL_DIR"
echo "======================================"

# ---------------------------------------
# Check HF CLI (modern hf tool)
# ---------------------------------------
if ! command -v hf >/dev/null 2>&1; then
    echo "ERROR: 'hf' CLI not found."
    echo "Please install it and activate your environment:"
    echo "  pip install -U huggingface_hub"
    echo "Then login:"
    echo "  hf auth login"
    exit 1
fi

# ---------------------------------------
# Optional: HF auth warning
# ---------------------------------------
if [[ -z "${HF_TOKEN:-}" ]]; then
    echo "WARNING: HF_TOKEN not set."
    echo "If the model is gated or your download fails, run: hf auth login"
fi

# ---------------------------------------
# Prepare directory
# ---------------------------------------
mkdir -p "${MODEL_DIR}"

# ---------------------------------------
# Download command (updated CLI)
# ---------------------------------------
CMD=(hf download "${MODEL_ID}" \
    --local-dir "${MODEL_DIR}")

if [[ -n "${REVISION}" ]]; then
    CMD+=(--revision "${REVISION}")
fi

echo "Running:"
echo "${CMD[*]}"

# Execute safely
"${CMD[@]}"

echo ""
echo "======================================"
echo "Done ✔"
echo "Model downloaded to:"
echo "${MODEL_DIR}"
echo ""
echo "Run with:"
echo "MODEL_PATH=${MODEL_DIR} bash scripts/launch_sglang_kimi.sh"
echo "======================================"
