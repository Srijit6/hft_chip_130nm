#!/usr/bin/env bash
# Sets up the environment for simulation and OpenLane hardening for SkyWater 130nm.
#
# Prerequisites (Ubuntu / Debian / WSL2):
#   - Docker (with user added to docker group)
#   - Python 3.10+
#   - GCC / G++ / make
#   - Verilator (5.0+)
#   - Volare PDK manager & SkyWater 130A PDK

set -euo pipefail

echo "========================================================"
echo " Setting up hft-chip-sky130 Environment"
echo "========================================================"

# 1. Check system packages
echo "--> Checking system tools (gcc, g++, make, verilator, docker)..."
for cmd in gcc g++ make verilator docker; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd not found. Please install it (e.g., sudo apt install $cmd)."
    exit 1
  fi
done

# 2. Setup Python environment
VENV_DIR="${HOME}/eda_env"
if [ ! -d "$VENV_DIR" ]; then
  echo "--> Creating Python virtual environment at $VENV_DIR..."
  python3 -m venv "$VENV_DIR"
fi

echo "--> Installing Python dependencies (matplotlib, openlane, volare, click<8.2)..."
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install "click<8.2" openlane volare matplotlib

# 3. Setup sv2v (SystemVerilog-to-Verilog converter for Yosys)
mkdir -p "${HOME}/.local/bin"
if ! command -v sv2v >/dev/null 2>&1 && [ ! -f "${HOME}/.local/bin/sv2v" ]; then
  echo "--> Installing sv2v binary..."
  curl -sSL https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip -o /tmp/sv2v.zip
  unzip -o /tmp/sv2v.zip -d /tmp/sv2v
  cp /tmp/sv2v/sv2v-Linux/sv2v "${HOME}/.local/bin/"
  chmod +x "${HOME}/.local/bin/sv2v"
  rm -rf /tmp/sv2v /tmp/sv2v.zip
fi

# 4. Setup SkyWater 130A PDK via Volare
export PDK_ROOT="${HOME}/.volare"
mkdir -p "$PDK_ROOT"
echo "--> Enabling sky130A PDK in Volare..."
"$VENV_DIR/bin/volare" enable --pdk sky130 0fe599b2afb6708d281543108caf8310912f54af || true

# 5. Pull OpenLane Docker Image
echo "--> Checking OpenLane Docker image (ghcr.io/efabless/openlane2:2.3.10)..."
docker pull ghcr.io/efabless/openlane2:2.3.10

echo "========================================================"
echo " Environment setup complete!"
echo " Export the following in your shell if running manually:"
echo "   export PATH=\"\${HOME}/.local/bin:\${HOME}/eda_env/bin:\$PATH\""
echo "   export PDK_ROOT=\"\${HOME}/.volare\""
echo "========================================================"
