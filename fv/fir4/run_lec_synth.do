// run_lec_synth.do -- Conformal LEC: RTL vs Genus synthesis netlist
set undefined cell black_box -both
set log file reports/lec_synth.log -replace

read library -liberty -both -statetable \
    ../../lib/slow_vdd1v0_basicCells.lib \
    ../../lib/slow_vdd1v0_multibitsDFF.lib \
    ../../lib/fast_vdd1v0_basicCells.lib \
    ../../lib/fast_vdd1v0_multibitsDFF.lib

// GOLDEN: RTL
read design -sv -golden -replace ../../rtl/fir4.sv

// REVISED: Genus synthesis netlist
read design -verilog -revised -replace ../../output/fir4_netlist.v

// DFT handling: functional mode only
add pin constraint 0 scan_en   -golden -revised
add pin constraint 0 test_mode -golden -revised
add pin constraint 0 scan_in   -golden -revised
add ignored outputs scan_out   -golden -revised
set undriven signal 0 -golden -revised

set system mode lec
add compared points -all
compare

report verification -verbose > reports/lec_synth.rpt
report compare data -class nonequivalent -class abort >> reports/lec_synth.rpt
report unmapped points -golden -revised >> reports/lec_synth.rpt
exit -f

