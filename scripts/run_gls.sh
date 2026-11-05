#!/bin/bash
# run_gls.sh -- gate-level simulation of the post-P&R netlist
#   TIMING=0 (default): functional GLS, no delays
#   TIMING=1          : timing GLS with SDF back-annotation
set -e
TIMING=${TIMING:-0}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"
mkdir -p "${PROJECT_DIR}/output"

NETLIST="${PROJECT_DIR}/innovus/output/fir4_final_netlist.v"
CELL_MODELS="${PROJECT_DIR}/lib/slow_vdd1v0_basicCells.v"
TB="${PROJECT_DIR}/tb/tb_fir4.sv"

. "${PROJECT_DIR}/scripts/with_cadence.sh"

if [ "$TIMING" -eq 1 ]; then
    LOG="${PROJECT_DIR}/output/gls_timing.log"
    cadence_run "xrun -sv -access +rwc -timescale 1ns/1ps -top tb_fir4 \
        -nowarn SDFINF -nowarn SDFNSB -nowarn SDFNET \
        -define TIMING \
        -v '${CELL_MODELS}' '${NETLIST}' '${TB}' -log '${LOG}'"
else
    LOG="${PROJECT_DIR}/output/gls_functional.log"
    cadence_run "xrun -sv -access +rwc -timescale 1ns/1ps -top tb_fir4 \
        -define FUNCTIONAL \
        -v '${CELL_MODELS}' '${NETLIST}' '${TB}' -log '${LOG}'"
fi

if grep -q "TEST PASSED" "${LOG}"; then
    echo "  RESULT: PASS"
else
    echo "  RESULT: FAIL -- review ${LOG}"
    exit 1
fi

