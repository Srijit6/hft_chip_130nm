#!/usr/bin/env bash
# Runs the full Verilator testbench suite for all order books and trading strategies.
# Co-simulates cycle-by-cycle against the C golden models in sw/.
#
# Usage: ./scripts/run_all_tests.sh [NOPS] [SEED]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NOPS="${1:-10000}"
SEED="${2:-0}"

echo "========================================================"
echo " Running hft-chip-sky130 Verilator Testbench Suite"
echo " Cycles per test: ${NOPS}, Random seed: ${SEED}"
echo "========================================================"

cd "${REPO_ROOT}/tb"

echo "--> Testing sorted & unsorted order books against golden C model..."
make sim SEED="${SEED}" NOPS="${NOPS}"

echo "--> Testing cross-market arbitrage trader (markets 0 & 1)..."
make arb SEED="${SEED}" NOPS="${NOPS}"

echo "--> Testing order-flow imbalance momentum trader (market 2)..."
make momentum SEED="${SEED}" NOPS="${NOPS}"

echo "--> Testing EMA mean-reversion trader (market 3)..."
make ema SEED="${SEED}" NOPS="${NOPS}"

echo "--> Testing full chip / core (4 books + 3 traders + priority arbiter)..."
make chip SEED="${SEED}" NOPS="${NOPS}"

echo "========================================================"
echo " All testbenches passed successfully! (0 errors)"
echo "========================================================"
