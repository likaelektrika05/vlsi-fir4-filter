# 04_cts.tcl -- clock tree synthesis + post-CTS optimization
set PROJECT_DIR [file normalize [file join [file dirname [info script]] ../..]]
set INV_OUT     ${PROJECT_DIR}/innovus/output
set DESIGN_NAME "fir4"
if {[catch {dbGet top.name} top] || $top ne ${DESIGN_NAME}} {
    restoreDesign ${INV_OUT}/${DESIGN_NAME}_place.enc.dat ${DESIGN_NAME}
}

create_ccopt_clock_tree_spec

set_ccopt_property buffer_cells   {CLKBUFX2 CLKBUFX4 CLKBUFX8}
set_ccopt_property inverter_cells {CLKINVX2 CLKINVX4}
set_ccopt_property target_skew      0.050
set_ccopt_property target_max_trans 0.100

clock_opt_design

setOptMode -holdTargetSlack 0.0 -setupTargetSlack 0.0 -effortLevel medium
optDesign -postCTS
optDesign -postCTS -hold

report_timing -max_paths 10 > ${INV_OUT}/${DESIGN_NAME}_cts_timing.rpt
report_clock_timing -type summary > ${INV_OUT}/${DESIGN_NAME}_cts_skew.rpt
saveDesign ${INV_OUT}/${DESIGN_NAME}_cts.enc

