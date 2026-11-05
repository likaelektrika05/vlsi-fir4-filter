# syn.tcl -- Genus synthesis + DFT scan insertion for fir4
set _here [file dirname [file normalize [info script]]]
if {![file exists ${_here}/setup.tcl]} { set _here [file normalize scripts] }
source ${_here}/setup.tcl
source ${_here}/read_rtl.tcl

read_sdc ${PROJECT_DIR}/constraints/fir4.sdc

set_db syn_generic_effort high
set_db syn_map_effort     high
set_db syn_opt_effort     high

# CRITICAL: no retiming -- keep pipeline truncation exactly as in RTL
catch { set_db retime false }
catch { set_db syn_opt_retime false }
catch { set_db auto_ungroup none }

# ---- DFT setup: muxed scan ----
set_db dft_scan_style muxed_scan
define_dft shift_enable -name scan_en   -active high [get_ports scan_en]
define_dft test_mode    -name test_mode -active high [get_ports test_mode]
define_dft test_clock   -name clk [get_ports clk]

# ---- Synthesis ----
syn_generic
syn_map
syn_opt

# ---- Scan insertion + stitching ----
check_dft_rules
convert_to_scan
define_dft scan_chain -name fir4_chain1 \
    -sdi scan_in -sdo scan_out -non_shared_output -shift_enable scan_en
connect_scan_chains
write_scandef > ${OUT_DIR}/${DESIGN_NAME}_scan.def

# ---- Remove assign statements (replace with buffers) ----
set_db / .remove_assigns true
remove_assigns_without_optimization
catch { foreach c [get_db insts *rm_assigns*]  { set_db $c .dont_touch true } }
catch { foreach c [get_db hinsts *rm_assigns*] { set_db $c .dont_touch true } }

# ---- Reports ----
report_timing      > ${OUT_DIR}/${DESIGN_NAME}_timing.rpt
report_area        > ${OUT_DIR}/${DESIGN_NAME}_area.rpt
report_gates       > ${OUT_DIR}/${DESIGN_NAME}_gates.rpt
report_power       > ${OUT_DIR}/${DESIGN_NAME}_power.rpt
report_scan_chains > ${OUT_DIR}/${DESIGN_NAME}_scan.rpt
report_qor         > ${OUT_DIR}/${DESIGN_NAME}_qor.rpt

# ---- Outputs for Innovus, LEC and GLS ----
write_hdl > ${OUT_DIR}/${DESIGN_NAME}_netlist.v
write_sdc > ${OUT_DIR}/${DESIGN_NAME}_out.sdc
write_sdf -timescale ns -nonegchecks > ${OUT_DIR}/${DESIGN_NAME}.sdf
puts "SYNTHESIS COMPLETE"
