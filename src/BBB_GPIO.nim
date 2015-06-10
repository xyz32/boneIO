import BBB_Pins, json

let
  path = ""

proc initGPIO*(): bool =
  discard
#end

when isMainModule:
  assert(BBB_Pins.getPinData("P8_3")["key"].str == "P8_3")
#end
