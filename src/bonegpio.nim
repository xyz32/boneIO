import bone, json, os

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
let
  sys_gpio_path = r"/sys/class/gpio/"
  exp_file = r"export"
  direction_file = r"direction"
  edge_file = r"edge"
  value_file = r"value"

proc exportPin (pinGpio: string) =
  ## Helper method to export the pins
  var file = open(sys_gpio_path & exp_file, fmWrite)
  file.writeln(pinGpio)
  file.close()
#end

proc setPinDirection(pinGpio: string, direction: Direction) =
  ## Helper method to set the pin direction
  var file = open(sys_gpio_path & "gpio" & pinGpio & "/" & direction_file, fmWrite)
  file.writeln(direction)
  file.close()
#end

proc pinMode* (pin: string, direction: Direction, pullup: PullupMode = PullupMode.Pullup) =
  ## Set the pin mod
  var pinGpio = $bone.getPinData(pin, "gpio");

  exportPin(pinGpio)
  setPinDirection(pinGpio, direction)
#end

proc digitalWrite* (pin: string, value: Digital) =
  discard

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