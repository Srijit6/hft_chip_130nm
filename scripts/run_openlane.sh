#!/usr/bin/env bash
# Runs the full RTL-to-GDS OpenLane flow targeting SkyWater 130nm (sky130A).
# Performs synthesis -> floorplan -> placement -> CTS -> routing -> Magic DRC -> Netgen LVS.
#
# Usage: ./scripts/run_openlane.sh [hft_core_fast|hft_core] [run_tag]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-hft_core_fast}"
RUN_TAG="${2:-run_signoff}"

export PDK_ROOT="${PDK_ROOT:-${HOME}/.volare}"
export PATH="${HOME}/.local/bin:${HOME}/eda_env/bin:${PATH}"

CONFIG_FILE="${REPO_ROOT}/openlane/${TARGET}/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Config not found at $CONFIG_FILE"
  echo "Valid targets: hft_core_fast (N=8) or hft_core (N=64)"
  exit 1
fi

echo "========================================================"
echo " Hardening ${TARGET} on SkyWater 130nm via OpenLane"
echo " Run tag: ${RUN_TAG}"
echo "========================================================"

# 1. Ensure flattened Verilog files are up-to-date with sv2v
mkdir -p "${REPO_ROOT}/rtl/gl"
echo "--> Translating SystemVerilog RTL to synthesizable Verilog via sv2v..."
sv2v "${REPO_ROOT}/rtl/orderbook_pkg.sv" \
     "${REPO_ROOT}/rtl/orderbook_unsorted.sv" \
     "${REPO_ROOT}/rtl/orderbook_sorted.sv" \
     "${REPO_ROOT}/rtl/orderbook.sv" \
     "${REPO_ROOT}/rtl/arb_trader.sv" \
     "${REPO_ROOT}/rtl/momentum_trader.sv" \
     "${REPO_ROOT}/rtl/ema_trader.sv" \
     "${REPO_ROOT}/rtl/hft_core.sv" > "${REPO_ROOT}/rtl/gl/hft_core.v"

# Generate N=8 fast configuration
sed 's/parameter signed \[31:0\] N = 64;/parameter signed [31:0] N = 8;/g' \
    "${REPO_ROOT}/rtl/gl/hft_core.v" > "${REPO_ROOT}/rtl/gl/hft_core_n8.v"

# 2. Run OpenLane
echo "--> Launching OpenLane..."
openlane --docker-no-tty --dockerized \
         --pdk-root "${PDK_ROOT}" \
         --pdk sky130A \
         --run-tag "${RUN_TAG}" \
         --overwrite \
         "${CONFIG_FILE}"

echo "========================================================"
echo " Run complete!"
echo " Reports and GDSII located under:"
echo "   ${REPO_ROOT}/openlane/${TARGET}/runs/${RUN_TAG}/"
echo "========================================================"
