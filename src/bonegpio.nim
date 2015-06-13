import bone, json, os, strutils

type
  ## Pin direction, in or out
  Direction* = enum
    In = "in", Out = "out"

  ## Logic level output
  Digital* = enum
    High = "1", Low = "0"

  ## Pullup resistor
  PullupMode* = enum
    Pullup = "pullup", Pulldown = "pulldown", Disabled = "disabled"

  ## The rate of change of output voltage per unit of time
  Slew* = enum
    Fast = "fast", Slow = "slow"

# BBB filesystem mapping based on the dafault device tree
const
  exp_file = "/sys/class/gpio/export"
  direction_file = "/sys/class/gpio/gpio$1/direction"
  edge_file = "edge"
  value_file = "value"
  
proc writeFile(file, pinGpio, value: string) =
  var tFile = open(file, fmWrite)
  tFile.writeln(value)
  tFile.close()
#end
  
proc exportPin (pinGpio: string) =
  ## Helper method to export the pins
  writeFile(exp_file, pinGpio, pinGpio)
#end

proc setPinDirection(pinGpio: string, direction: Direction) =
  ## Helper method to set the pin direction
  let fileName = direction_file % [pinGpio]
  writeFile(fileName, pinGpio, $direction)
#end

proc pinMode* (pin: string, direction: Direction, pullup: PullupMode = PullupMode.Pullup) =
  ## Set the pin mod
  let pinGpio = $bone.getPinData(pin, "gpio");
  
  exportPin(pinGpio)
  setPinDirection(pinGpio, direction)
#end

proc digitalWrite* (pin: string, value: Digital) =
  discard
#end

# Testing
when isMainModule:
  assert(bone.getPinData("P8_3")["key"].str == "P8_3")
  try:
    discard bone.getPinData("bla")["key"].str
  except ValueError:
    assert (true)
  #end

  assert ($bone.getPinData("P9_42", "eeprom") == "4")

  try:
    discard bone.getPinData("P9_46", "gpio")
  except ValueError:
    assert (true)

  # pinMode("P8_6", Direction.Out)
  #end
#end