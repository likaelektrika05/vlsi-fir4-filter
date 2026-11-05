
# 05_route.tcl -- routing, post-route opt, filler, verification
set PROJECT_DIR [file normalize [file join [file dirname [info script]] ../..]]
set INV_OUT     ${PROJECT_DIR}/innovus/output
set DESIGN_NAME "fir4"
if {[catch {dbGet top.name} top] || $top ne ${DESIGN_NAME}} {
    restoreDesign ${INV_OUT}/${DESIGN_NAME}_cts.enc.dat ${DESIGN_NAME}
}

# Timing- and SI-driven routing, Metal1..Metal10
catch { setNanoRouteMode -routeWithTimingDriven true -routeWithSiDriven true \
        -routeTopRoutingLayer 10 -routeBottomRoutingLayer 1 }
catch { set_db route_design_with_timing_driven true }
catch { set_db route_design_with_si_driven true }
catch { set_db route_design_top_routing_layer 10 }
catch { set_db route_design_bottom_routing_layer 1 }

routeDesign

# Post-route optimization with on-chip variation
setAnalysisMode -analysisType onChipVariation
setOptMode -holdTargetSlack 0.0 -setupTargetSlack 0.0 -effortLevel high
optDesign -postRoute
optDesign -postRoute -hold

addFiller -cell {FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1} -prefix FILLER

verifyGeometry -error 1000 -report ${INV_OUT}/${DESIGN_NAME}_drc.rpt
verifyConnectivity -type all -error 1000 -report ${INV_OUT}/${DESIGN_NAME}_connectivity.rpt
if {[catch { verifyProcessAntenna -report ${INV_OUT}/${DESIGN_NAME}_antenna.rpt -error 1000 }]} {
    catch { verify_process_antenna -report ${INV_OUT}/${DESIGN_NAME}_antenna.rpt -error 1000 }
}

saveDesign ${INV_OUT}/${DESIGN_NAME}_route.enc

