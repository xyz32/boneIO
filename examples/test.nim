import bone, bone/gpio, os, bone/pwm

# Testing
when isMainModule:
  assert(bone.getPinData("P8_3").key == "P8_3")
  try:
    discard bone.getPinData("bla").key
  except ValueError:
    assert (true)
  #end

  assert ($bone.getPinData("P9_42").eeprom == "4")

  try:
    discard bone.getPinData("P9_46").gpio
  except ValueError:
    assert (true)
  #end

  #pinMode("P8_6", Direction.Out)
  pinMode("P9_14", Direction.Out)
  pinModeReset("P9_14")

  pinMode("USR0", Direction.Out)
  for i in 0..100:
    digitalWrite("USR0", i mod 2)
    sleep(100)

  pinModeReset("USR0")
  #end
#end