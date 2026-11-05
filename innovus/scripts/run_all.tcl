# run_all.tcl -- full Innovus P&R flow
set SCRIPT_DIR [file dirname [file normalize [info script]]]

puts "========== STAGE 1 / 6 : INIT =========="
source ${SCRIPT_DIR}/01_init.tcl
puts "========== STAGE 2 / 6 : FLOORPLAN =========="
source ${SCRIPT_DIR}/02_floorplan.tcl
puts "========== STAGE 3 / 6 : PLACEMENT =========="
source ${SCRIPT_DIR}/03_place.tcl
puts "========== STAGE 4 / 6 : CTS =========="
source ${SCRIPT_DIR}/04_cts.tcl
puts "========== STAGE 5 / 6 : ROUTING =========="
source ${SCRIPT_DIR}/05_route.tcl
puts "========== STAGE 6 / 6 : SIGNOFF =========="
source ${SCRIPT_DIR}/06_signoff.tcl

puts "P&R FLOW COMPLETE"

