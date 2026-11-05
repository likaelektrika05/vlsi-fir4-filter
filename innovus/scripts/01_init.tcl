# 01_init.tcl -- import netlist, LEF and MMMC
set PROJECT_DIR [file normalize [file join [file dirname [info script]] ../..]]
set SYN_OUT     ${PROJECT_DIR}/output
set LEF_DIR     ${PROJECT_DIR}/lef
set INV_OUT     ${PROJECT_DIR}/innovus/output
set DESIGN_NAME "fir4"
file mkdir $INV_OUT

set init_lef_file  [list ${LEF_DIR}/gsclib045_tech.lef ${LEF_DIR}/gsclib045_macro.lef]
set init_mmmc_file ${PROJECT_DIR}/innovus/scripts/mmmc.tcl
set init_verilog   ${SYN_OUT}/${DESIGN_NAME}_netlist.v
set init_top_cell  ${DESIGN_NAME}
set init_pwr_net   VDD
set init_gnd_net   VSS

catch { setDesignMode -process 45 }
init_design

# Connect every cell's power pins to VDD/VSS
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VDD -type tiehi -inst *
globalNetConnect VSS -type tielo -inst *

# Scan chain order from Genus
set SCAN_DEF ${SYN_OUT}/${DESIGN_NAME}_scan.def
if {[file exists $SCAN_DEF]} { catch { defIn $SCAN_DEF } }

checkTimingLibrary
saveDesign ${INV_OUT}/${DESIGN_NAME}_init.enc

