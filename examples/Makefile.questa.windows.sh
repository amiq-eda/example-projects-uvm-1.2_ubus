#!/bin/sh

rm -rf $DVT_PROJECT_LOC/work

vlib $DVT_PROJECT_LOC/work

vlog -timescale "1ns/1ns" -suppress 2181 +acc=rmb -writetoplevels questa.tops -mfcu -incr -f $DVT_PROJECT_LOC/.dvt/default.build -work $DVT_PROJECT_LOC/work -O0 -novopt

# compiling uvm_dpi.dll
# You must set C_COMPILER system variable to point to a c/c++ compiler location (e.g. c:\questa_sim_10.0a\gcc-4.2.1-mingw32vc9\bin\g++.exe)
# and set QUESTA_HOME to point to questa directory (e.g. c:\questa_sim_10.0a\)

mkdir -p $DVT_PREDEFINED_PROJECTS/libs/uvm-1.2/lib

$C_COMPILER -g -DQUESTA -W -shared -Bsymbolic -I${QUESTA_HOME}/include  $DVT_PREDEFINED_PROJECTS/libs/uvm-1.2/src/dpi/uvm_dpi.cc -o $DVT_PREDEFINED_PROJECTS/libs/uvm-1.2/lib/uvm_dpi.dll $QUESTA_HOME/win64/mtipli.dll -lregex

cp $DVT_PREDEFINED_PROJECTS/libs/uvm-1.2/lib/uvm_dpi.dll .

if [ "$DVT_LAUNCH_MODE" = "generic_debug" ]; then
	QUESTA_DO="do $DVT_HOME/libs/dvt_debug_tcl/dvt_debug.tcl"
else
	QUESTA_DO="onerror resume;onbreak resume;onElabError resume;run -all;exit"
fi

vsim +UVM_VERBOSITY=UVM_MEDIUM  -sv_lib uvm_dpi -c -l questa.log -f questa.tops +UVM_TESTNAME=test_2m_4s -novopt -do "$QUESTA_DO"
