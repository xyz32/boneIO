import BBBpinlayout, json, os

type
  Direction* = enum
    In, Out

  Digital* = enum
    High = "1", Low = "0"

  Pullup* = enum
    pullup, pulldown, disabled

# BBB filesystem mapping
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

proc pinMode*(pin: string, direction: Direction) =
  ## Set the pin mod
  var pinGpio = $BBBpinlayout.getPinData(pin, "gpio");

  exportPin(pinGpio)
  setPinDirection(pinGpio, direction)
#end

proc digitalWrite(pin: string, value: Digital) =
  discard

# Testing
when isMainModule:
  assert(BBBpinlayout.getPinData("P8_3")["key"].str == "P8_3")
  try:
    discard BBBpinlayout.getPinData("bla")["key"].str
  except ValueError:
    assert (true)
  #end

  assert ($BBBpinlayout.getPinData("P9_42", "eeprom") == "4")

  try:
    discard BBBpinlayout.getPinData("P9_46", "gpio")
  except ValueError:
    assert (true)

  pinMode("P8_6", Direction.Out)
  #end
#end