// run_lec.do -- Conformal LEC: RTL vs final post-P&R netlist
set undefined cell black_box -both
set log file reports/lec_rtl_vs_final.log -replace

read library -liberty -both -statetable \
    ../../lib/slow_vdd1v0_basicCells.lib \
    ../../lib/slow_vdd1v0_multibitsDFF.lib \
    ../../lib/fast_vdd1v0_basicCells.lib \
    ../../lib/fast_vdd1v0_multibitsDFF.lib

read design -sv -golden -replace ../../rtl/fir4.sv
read design -verilog -revised -replace ../../innovus/output/fir4_final_netlist.v

add pin constraint 0 scan_en   -golden -revised
add pin constraint 0 test_mode -golden -revised
add pin constraint 0 scan_in   -golden -revised
add ignored outputs scan_out   -golden -revised
set undriven signal 0 -golden -revised

set system mode lec
add compared points -all
compare

report verification -verbose > reports/lec_rtl_vs_final.rpt
report compare data -class nonequivalent -class abort >> reports/lec_rtl_vs_final.rpt
report unmapped points -golden -revised >> reports/lec_rtl_vs_final.rpt
report statistics >> reports/lec_rtl_vs_final.rpt
exit -f

