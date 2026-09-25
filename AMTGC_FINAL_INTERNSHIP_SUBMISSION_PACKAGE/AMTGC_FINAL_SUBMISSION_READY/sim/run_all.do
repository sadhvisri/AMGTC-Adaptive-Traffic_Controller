transcript on
if {[file exists work]} { vdel -lib work -all }
vlib work

vlog rtl/generic_timer.v
vlog rtl/junction_controller.v
vlog rtl/ped_arbiter.v
vlog rtl/amtgc_top.v

vlog tb/tb_generic_timer.v
vlog tb/tb_junction_controller.v
vlog tb/tb_green_wave.v
vlog tb/tb_amtgc_top.v
vlog tb/tb_task4_adaptive.v
vlog tb/tb_task5_full.v

echo "=== TIMER TEST ==="
vsim work.tb_generic_timer
run -all
quit -sim

echo "=== JUNCTION TEST ==="
vsim work.tb_junction_controller
run -all
quit -sim

echo "=== GREEN WAVE TEST ==="
vsim work.tb_green_wave
run -all
quit -sim

echo "=== INTEGRATION TEST ==="
vsim work.tb_amtgc_top
run -all
quit -sim

echo "=== TASK 4 ADAPTIVE TIMING TEST ==="
vsim work.tb_task4_adaptive
run -all
quit -sim

echo "=== TASK 5 FULL VERIFICATION ==="
vsim work.tb_task5_full
run -all
quit -sim

echo "=== ALL TESTS FINISHED ==="
