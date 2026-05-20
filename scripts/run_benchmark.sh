#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------
# Resolve Environment Paths
# ---------------------------------------
ROOT="$(cd "$(dirname "${BASH_SOURCE}")/.." && pwd)"
VENV="${VENV:-${ROOT}/.venv}"

echo "======================================"
echo "SGLang Benchmark Client Execution"
echo "======================================"

# ---------------------------------------
# Activate Virtual Environment
# ---------------------------------------
if [[ -f "$VENV/bin/activate" ]]; then
    source "$VENV/bin/activate"
else
    echo "ERROR: Virtual environment not found at $VENV."
    exit 1
fi

# ---------------------------------------
# Run Throughput & Latency Test
# ---------------------------------------
# Flags Updated:
# --dataset-name random: Correctly specifies the generation mode
# --max-concurrency 16: Correctly specifies the parallel user count limit
echo "Starting mock client pressure test..."
python3 -m sglang.bench_serving \
    --backend sglang \
    --host 127.0.0.1 \
    --port 30000 \
    --dataset-name random \
    --num-prompts 100 \
    --random-input-len 512 \
    --random-output-len 128 \
    --max-concurrency 16

echo "======================================"
echo "Benchmark completed successfully! ✅"
echo "======================================"
