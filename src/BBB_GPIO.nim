import BBB_Pins, json, os

type
  Direction = enum
    In, Out

# BBB filesystem mapping
let
  sys_gpio_path = r"/sys/class/gpio/"
  exp_file = r"export"
  direction_file = r"direction"
  edge_file = r"edge"
  value_file = r"value"

proc exportPin (pin: string) =
  ## Helper method to export the pins
  var file = open(sys_gpio_path & exp_file, fmWrite)
  file.writeln(pinGpio)
  file.close()
#end

proc setPinDirection(pin: string, direction: Direction) =
  ## Helper method to set the pin direction
  var file = open(sys_gpio_path & "gpio" & pinGpio & "/" & direction_file, fmWrite)
  file.writeln(direction)
  file.close()
#end

proc pinMode*(pin: string, direction: Direction) =
  ## Set the pin mod
  var pinGpio = BBB_Pins.getPinData(pin, "gpio").str;

  exportPin(pin)
  setPinDirection(pin, direction)
#end

# Testing
when isMainModule:
  assert(BBB_Pins.getPinData("P8_3")["key"].str == "P8_3")
  try:
    discard BBB_Pins.getPinData("bla")["key"].str
  except ValueError:
    assert (true)
  #end

  assert ($BBB_Pins.getPinData("P9_42", "eeprom") == "4")

  try:
    discard BBB_Pins.getPinData("P9_46", "gpio")
  except ValueError:
    assert (true)

  discard pinMode("P9_46", Direction.Out)
  #end
#end