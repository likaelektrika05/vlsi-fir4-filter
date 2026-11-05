# write_cdl.tcl -- export flat physical netlist for LVS
set PROJECT_DIR [file normalize [file join [file dirname [info script]] ../..]]
set INV_OUT     ${PROJECT_DIR}/innovus/output
set CDL_DIR     ${PROJECT_DIR}/cdl
set DESIGN_NAME "fir4"
file mkdir $CDL_DIR

restoreDesign ${INV_OUT}/${DESIGN_NAME}_signoff.enc.dat ${DESIGN_NAME}

# NOTE: Innovus 25.1 has no "saveNetlist -format cdl" (error IMPTCM-48),
# so write a flat physical Verilog netlist (fillers + VDD/VSS) for LVS instead.
if {[catch { saveNetlist -flat -phys -includePowerGround ${CDL_DIR}/${DESIGN_NAME}_lvs.v } msg]} {
    puts "saveNetlist -phys failed: $msg -- writing plain flat netlist"
    saveNetlist -flat ${CDL_DIR}/${DESIGN_NAME}_lvs.v
}
puts "LVS netlist written: ${CDL_DIR}/${DESIGN_NAME}_lvs.v"

