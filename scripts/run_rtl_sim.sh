#!/bin/bash
# run_rtl_sim.sh -- RTL simulation of fir4 against MATLAB vectors
set -e
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"                      # tb reads tb/*.hex relative to here
RTL="${PROJECT_DIR}/rtl/fir4.sv"
TB="${PROJECT_DIR}/tb/tb_fir4.sv"
mkdir -p "${PROJECT_DIR}/output"
LOG="${PROJECT_DIR}/output/rtl_sim.log"

# cadence_run() loads the cadence_ece module and runs the command
. "${PROJECT_DIR}/scripts/with_cadence.sh"

cadence_run "xrun -sv -access +rwc -timescale 1ns/1ps -top tb_fir4 \
    '${RTL}' '${TB}' -log '${LOG}'"

if grep -q "TEST PASSED" "${LOG}"; then
    echo "  RESULT: PASS"
else
    echo "  RESULT: FAIL -- review ${LOG}"
    exit 1
fi

