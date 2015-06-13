import bone, json, os, strutils

type
  ## Pin direction, in or out
  Direction* = enum
    In = "in", Out = "out"

  ## Logic level output
  Digital* = enum
    High = "1", Low = "0"

  ## Pullup resistor
  PullUpDown* = enum
    Pullup = "pullup", Pulldown = "pulldown", Disabled = "disabled"

  ## The rate of change of output voltage per unit of time
  Slew* = enum
    Fast = "fast", Slow = "slow"

# BBB filesystem mapping based on the dafault device tree
const
  exp_file = "/sys/class/gpio/export"
  unexp_file = "/sys/class/gpio/unexport"
  direction_file = "/sys/class/gpio/gpio$1/direction"
  value_file = "/sys/class/gpio/gpio$1/value"
  
proc writeFile(file, pinGpio, value: string) =
  var tFile = open(file, fmWrite)
  tFile.writeln(value)
  tFile.close()
#end
  
proc exportPin (pinGpio: string, enable: bool = true) =
  ## Helper method to export the pins
  if enable:
    writeFile(exp_file, pinGpio, pinGpio)
  else:
    writeFile(unexp_file, pinGpio, pinGpio)
  #end
#end

proc setPinDirection(pinGpio: string, direction: Direction) =
  ## Helper method to set the pin direction
  let fileName = direction_file % [pinGpio]
  writeFile(fileName, pinGpio, $direction)
#end

proc pinMode* (pin: string, direction: Direction, pullup: PullUpDown = PullUpDown.Pullup, slew: Slew = Slew.Fast) =
  ## Set the pin mod
  let pinGpio = $bone.getPinData(pin, "gpio");
  
  exportPin(pinGpio)
  setPinDirection(pinGpio, direction)
#end

proc pinModeReset* (pin: string) =
  ## Reset the pin mode
  let pinGpio = $bone.getPinData(pin, "gpio");
  
  exportPin(pinGpio, false)
#end

proc digitalWrite* (pin: string, value: Digital) =
  let pinGpio = $bone.getPinData(pin, "gpio");
  let fileName = value_file % [pinGpio]
  writeFile(fileName, $value)
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

  pinMode("P8_6", Direction.Out)
  #end
#end