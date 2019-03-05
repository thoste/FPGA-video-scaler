# Detect simulator
#------------------------------------------------------
if {[catch {eval "vsim -version"} message] == 0} {
  quietly set simulator_version [eval "vsim -version"]
  puts "Version is: $simulator_version"
  if {[regexp -nocase {modelsim} $simulator_version]} {
    quietly set simulator "modelsim"
  } elseif {[regexp -nocase {aldec} $simulator_version]} {
    quietly set simulator "rivierapro"
  } else {
    puts "Unknown simulator. Attempting to use Modelsim commands."
    quietly set simulator "modelsim"
  }
} else {
    puts "vsim -version failed with the following message:\n $message"
    abort all
}


#------------------------------------------------------
vsim  scaler.tb_with_source

add log -r /*
source ../script/wave_modelsim.do

run -all
