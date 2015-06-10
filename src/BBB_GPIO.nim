import BBB_Pins, json, os

# BBB filesystem mapping
let
  sys_gpio_path = "/sys/class/gpio/"
  exp_file = "export"
  direction_file = "direction"
  edge_file = "edge"
  value_file = "value"

proc pinMode(pin: string): bool =
  var file = open(sys_gpio_path & exp_file, fmWrite)
  file.close()
#end

proc initGPIO*(): bool =
  discard
#end

when isMainModule:
  assert(BBB_Pins.getPinData("P8_3")["key"].str == "P8_3")
  try:
    assert(BBB_Pins.getPinData("bla")["key"].str == "bla")
  except ValueError:
    assert (true)
  #end
#end