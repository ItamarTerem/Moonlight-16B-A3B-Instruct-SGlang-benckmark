#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODEL_ID="${MODEL_ID:-moonshotai/Moonlight-16B-A3B-Instruct}"
MODEL_DIR="${MODEL_DIR:-${ROOT}/models/Moonlight-16B-A3B-Instruct}"
REVISION="${REVISION:-}"

echo "======================================"
echo "Kimi model downloader"
echo "MODEL_ID: $MODEL_ID"
echo "MODEL_DIR: $MODEL_DIR"
echo "======================================"

# ---------------------------------------
# Check HF CLI (Correct tool verification)
# ---------------------------------------
if ! command -v huggingface-cli >/dev/null 2>&1; then
    echo "ERROR: 'huggingface-cli' not found."
    echo "Please activate your venv first (source .venv/bin/activate)."
    exit 1
fi

# ---------------------------------------
# Optional: HF auth warning
# ---------------------------------------
if [[ -z "${HF_TOKEN:-}" ]]; then
    echo "WARNING: HF_TOKEN not set."
    echo "If the model is gated or your download fails, run: huggingface-cli login"
fi

# ---------------------------------------
# Prepare directory
# ---------------------------------------
mkdir -p "${MODEL_DIR}"

# ---------------------------------------
# Download (Corrected command sequence)
# ---------------------------------------
CMD=(huggingface-cli download "${MODEL_ID}" \
    --local-dir "${MODEL_DIR}")

if [[ -n "${REVISION}" ]]; then
    CMD+=(--revision "${REVISION}")
fi

echo "Running:"
echo "${CMD[*]}"

# Run the command array safely
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


