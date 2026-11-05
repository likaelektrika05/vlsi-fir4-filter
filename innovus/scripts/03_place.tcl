
# 03_place.tcl -- timing-driven placement + pre-CTS optimization
set PROJECT_DIR [file normalize [file join [file dirname [info script]] ../..]]
set INV_OUT     ${PROJECT_DIR}/innovus/output
set DESIGN_NAME "fir4"
if {[catch {dbGet top.name} top] || $top ne ${DESIGN_NAME}} {
    restoreDesign ${INV_OUT}/${DESIGN_NAME}_floorplan.enc.dat ${DESIGN_NAME}
}

setPlaceMode -timingDriven true -congEffort medium
catch { setPlaceMode -checkCutSpacing true }

place_design

setOptMode -effortLevel medium
optDesign -preCTS

report_timing -max_paths 5 > ${INV_OUT}/${DESIGN_NAME}_place_timing.rpt
checkPlace ${INV_OUT}/${DESIGN_NAME}_place_check.rpt
saveDesign ${INV_OUT}/${DESIGN_NAME}_place.enc

