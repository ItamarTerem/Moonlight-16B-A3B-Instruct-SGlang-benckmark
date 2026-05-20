#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------
# Resolve project root
# ---------------------------------------
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VENV="${VENV:-${ROOT}/.venv}"
REQ="${ROOT}/requirements-runtime.txt"

echo "======================================"
echo "[0/8] Project root detected:"
echo "$ROOT"
echo "======================================"

# ---------------------------------------
# Check NVIDIA environment
# ---------------------------------------
echo "[1/8] Checking NVIDIA environment..."

# Run the live tool directly; it guarantees the driver works and the file exists
if ! nvidia-smi >/dev/null 2>&1; then
    echo "ERROR: NVIDIA driver is not installed, broken, or unresponsive."
    exit 1
fi

nvcc --version || echo "WARNING: nvcc not found (CUDA toolkit may be missing)"

echo "✔ GPU environment OK"

# ---------------------------------------
# System dependencies
# ---------------------------------------
echo "[2/8] Installing system dependencies..."

# Automatically prepend sudo if running as a non-root user
SUDO=""
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
fi

$SUDO apt-get update && $SUDO apt-get install -y \
    libopenmpi-dev \
    openmpi-bin \
    git \
    git-lfs \
    cmake \
    build-essential \
    ninja-build

git lfs install

echo "✔ System dependencies installed"

# ---------------------------------------
# Check requirements file exists
# ---------------------------------------
echo "[3/8] Checking requirements file..."

if [[ ! -f "$REQ" ]]; then
    echo "ERROR: requirements-runtime.txt not found at $REQ"
    exit 1
fi

echo "✔ Requirements file found"

# ---------------------------------------
# Create virtual environment
# ---------------------------------------
echo "[4/8] Creating virtual environment at: $VENV"

python3 -m venv "$VENV"
echo "✔ Virtual environment created"

source "$VENV/bin/activate"
echo "✔ Virtual environment activated"
echo "Python destination: $(which python)"

# ---------------------------------------
# Python dependencies
# ---------------------------------------
echo "[5/8] Installing Python dependencies..."

pip install --upgrade pip
pip install -r "$REQ"

echo "✔ Python requirements installed"


# ---------------------------------------
# SGLang Engine & Benchmark Dependencies
# ---------------------------------------
echo "[6/8] Installing SGLang and your benchmark runtime..."

# 1. Install SGLang along with flashinfer wheels tailored for your ecosystem
pip install "sglang[all]" --find-links https://flashinfer.ai

# 2. Immediately install your specialized client benchmark file
pip install -r "$REQ"

echo "✔ SGLang server and benchmark requirements installed"


# ---------------------------------------
# SGLang Examples & Benchmark Setup
# ---------------------------------------
echo "[7/8] Cloning SGLang repository for production examples..."

SGLANG_REPO="${ROOT}/sglang"

if [[ -d "$SGLANG_REPO" ]]; then
    echo "✔ SGLang repository already exists at $SGLANG_REPO"
else
    # Clone the target repo cleanly without running editable source compilation
    git clone https://github.com/sgl-project/sglang.git "$SGLANG_REPO"
    echo "✔ SGLang repository cloned"
fi

# ---------------------------------------
# Environment variables
# ---------------------------------------
echo "[8/8] Finalizing environment..."

export HF_HUB_ENABLE_HF_TRANSFER=1

if ! grep -q "HF_HUB_ENABLE_HF_TRANSFER" "$VENV/bin/activate"; then
    echo 'export HF_HUB_ENABLE_HF_TRANSFER=1' >> "$VENV/bin/activate"
fi

echo "✔ Environment variables set"

echo "======================================"
echo "Setup complete ✅"
echo ""
echo "To start your production server, run:"
echo "  source $VENV/bin/activate"
echo "  python3 -m sglang.launch_server --model-path <HF_MODEL_ID> --port 30000"
echo "======================================"
