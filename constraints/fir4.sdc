# fir4.sdc -- timing constraints for 300 MHz
set_max_fanout     20   [current_design]
set_max_transition 0.20 [current_design]

create_clock -name clk -period 3.333 -waveform {0 1.667} [get_ports clk]

set_clock_uncertainty -setup 0.05 [get_clocks clk]
set_clock_uncertainty -hold  0.03 [get_clocks clk]
set_clock_transition 0.05 [get_clocks clk]

set_dont_touch_network [get_clocks clk]

set_input_delay -max 0.70 -clock clk [get_ports rst_b]
set_input_delay -min 0.05 -clock clk [get_ports rst_b]
set_input_delay -max 0.67 -clock clk [get_ports valid_in]
set_input_delay -min 0.05 -clock clk [get_ports valid_in]
set_input_delay -max 0.67 -clock clk [get_ports {x[*]}]
set_input_delay -min 0.05 -clock clk [get_ports {x[*]}]

set_output_delay -max 0.67 -clock clk [get_ports {y[*]}]
set_output_delay -min 0.05 -clock clk [get_ports {y[*]}]
set_output_delay -max 0.67 -clock clk [get_ports valid_out]
set_output_delay -min 0.05 -clock clk [get_ports valid_out]

set_load 0.005 [all_outputs]

set_false_path -from [get_ports rst_b]
set_case_analysis 0 [get_ports scan_en]
set_case_analysis 0 [get_ports test_mode]
set_false_path -from [get_ports scan_en]
set_false_path -from [get_ports test_mode]
set_false_path -from [get_ports scan_in]
set_false_path -to   [get_ports scan_out]

