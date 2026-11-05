# setup.tcl -- library + path setup for Genus
set DESIGN_NAME "fir4"
set TOP_MODULE  "fir4"
set SCRIPT_DIR  [file dirname [file normalize [info script]]]
set PROJECT_DIR [file dirname $SCRIPT_DIR]
set LIB_DIR     ${PROJECT_DIR}/lib
set LEF_DIR     ${PROJECT_DIR}/lef
set OUT_DIR     ${PROJECT_DIR}/output
file mkdir $OUT_DIR

set_db library [list \
    ${LIB_DIR}/slow_vdd1v0_basicCells.lib \
    ${LIB_DIR}/slow_vdd1v0_multibitsDFF.lib \
]

set_db lef_library [list \
    ${LEF_DIR}/gsclib045_tech.lef \
    ${LEF_DIR}/gsclib045_macro.lef \
]

foreach pattern {*/*X0 */*_X0 */*_0 */*D0BWP*} {
    set _du [get_lib_cells -quiet ${pattern}]
    if {[llength ${_du}] > 0} {
        set_dont_use ${_du}
        break
    }
}

foreach pattern {FILL* ISO*LX1* ISO*HX1* HSW*X1 FSW*X1 LS*X* BHD*} {
    set _du [get_lib_cells -quiet ${pattern}]
    if {[llength ${_du}] > 0} { set_dont_use ${_du} }
}
