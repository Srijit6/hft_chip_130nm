#!/usr/bin/env bash
# Runs the directed market simulation scenarios and generates visualization plots.
# Markets are driven by synthetic Ornstein-Uhlenbeck processes.
#
# Usage: ./scripts/run_scenarios.sh [CYCLES]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CYCLES="${1:-2000}"
PYTHON="${PYTHON:-python3}"

# Prefer virtualenv python if available
if [ -f "${HOME}/eda_env/bin/python3" ]; then
  PYTHON="${HOME}/eda_env/bin/python3"
fi

mkdir -p "${REPO_ROOT}/report/results" "${REPO_ROOT}/report/figures"
cd "${REPO_ROOT}/tb"

echo "========================================================"
echo " Generating Directed Market Scenarios (${CYCLES} cycles)"
echo "========================================================"

echo "--> Running EMA mean-reversion scenario..."
make ema_scenario SCEN_NOPS="${CYCLES}"
mv ema_scenario.csv "${REPO_ROOT}/report/results/"
"${PYTHON}" "${REPO_ROOT}/scripts/plot_scenario.py" \
  "${REPO_ROOT}/report/results/ema_scenario.csv" \
  --title "EMA Mean-Reversion Strategy (Market 3)" \
  --out "${REPO_ROOT}/report/figures/ema_scenario.png"

echo "--> Running cross-market arbitrage scenario..."
make arb_scenario SCEN_NOPS="${CYCLES}"
mv arb_scenario.csv "${REPO_ROOT}/report/results/"
"${PYTHON}" "${REPO_ROOT}/scripts/plot_scenario.py" \
  "${REPO_ROOT}/report/results/arb_scenario.csv" \
  --title "Cross-Market Arbitrage Strategy (Markets 0 & 1)" \
  --two-mids \
  --out "${REPO_ROOT}/report/figures/arb_scenario.png"

echo "--> Running order-flow imbalance momentum scenario..."
make momentum_scenario SCEN_NOPS="${CYCLES}"
mv momentum_scenario.csv "${REPO_ROOT}/report/results/"
"${PYTHON}" "${REPO_ROOT}/scripts/plot_scenario.py" \
  "${REPO_ROOT}/report/results/momentum_scenario.csv" \
  --title "Momentum Imbalance Strategy (Market 2)" \
  --imbalance \
  --out "${REPO_ROOT}/report/figures/momentum_scenario.png"

echo "========================================================"
echo " Scenarios complete! Generated plots in report/figures/:"
echo "   - report/figures/ema_scenario.png"
echo "   - report/figures/arb_scenario.png"
echo "   - report/figures/momentum_scenario.png"
echo "========================================================"
