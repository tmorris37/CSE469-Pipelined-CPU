# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./adder.sv"
vlog "./alu.sv"
vlog "./and_unit.sv"
vlog "./comparator.sv"
vlog "./control_unit.sv"
vlog "./cpu.sv"
vlog "./cpu_tb.sv"
vlog "./datamem.sv"
vlog "./dff.sv"
vlog "./forwarding_unit.sv"
vlog "./hazard_detection_unit.sv"
vlog "./instructmem.sv"
vlog "./mux_multi_bits.sv"
vlog "./mux_single_bit.sv"
vlog "./or64_1.sv"
vlog "./or_unit.sv"
vlog "./pipeline_registers.sv"
vlog "./regfile.sv"
vlog "./reg_decoder.sv"
vlog "./ripple_carry_adder_64.sv"
vlog "./sign_extender.sv"
vlog "./xor_unit.sv"
vlog "./zero_extender.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpu_tb

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do cpu_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
