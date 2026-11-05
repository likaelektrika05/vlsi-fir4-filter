# read_rtl.tcl -- read + elaborate fir4 RTL
set RTL_DIR ${PROJECT_DIR}/rtl
catch { set_db auto_ungroup none }

read_hdl -language sv -define DFT_INSERTION [list ${RTL_DIR}/fir4.sv]

elaborate ${TOP_MODULE}
check_design -unresolved
check_design -multiple_driver

foreach inst {u_stage1 u_stage2 u_stage3} {
    catch {
        set cell [get_cells $inst]
        if {$cell ne ""} { set_dont_touch $cell true }
    }
}
foreach mod {fir4_stage1 fir4_stage2 fir4_stage3} {
    catch {
        set d [get_designs $mod]
        if {$d ne ""} { set_dont_touch $d true }
    }
}

