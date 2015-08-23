#
# Copyright (c) 2015, Radu Oana <oanaradu32 at gmail dot com>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
#

import bone, os, strutils

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
  expFile = "/sys/class/gpio/export"
  unexpFile = "/sys/class/gpio/unexport"
  directionFile = "/sys/class/gpio/gpio$1/direction"
  gpioValueFile = "/sys/class/gpio/gpio$1/value"
  ledTriggerFile = "/sys/class/leds/beaglebone:green:$1/trigger"
  ledBrightnessFile = "/sys/class/leds/beaglebone:green:$1/brightness"

proc exportPin (pinGpio: string, enable: bool = true) =
  ## Helper method to export the pins
  if enable:
    if not existsFile(gpioValueFile % [pinGpio]):
      writeFile(expFile, pinGpio)
    #end
  else:
    if existsFile(gpioValueFile % [pinGpio]):
      writeFile(unexpFile, pinGpio)
    #end
  #end
#end

proc setPinDirection(pinGpio: string, direction: Direction) =
  ## Helper method to set the pin direction
  let fileName = directionFile % [pinGpio]
  writeFile(fileName, $direction)
#end

proc pinMode* (pin: string, direction: Direction, pullup: PullUpDown = PullUpDown.Pullup, slew: Slew = Slew.Fast) =
  ## Set the pin mod

  # LEDs need to be treated differently
  if bone.hasLED(pin):
    let pinLed = $bone.getPinData(pin).led
    writeFile(ledTriggerFile % [pinLed], "gpio")
  else:
    let pinGpio = $bone.getPinData(pin).gpio;
    exportPin(pinGpio)
    setPinDirection(pinGpio, direction)
  #end
#end

proc pinModeReset* (pin: string) =
  ## Reset the pin mode

  exportPin($bone.getPinData(pin).gpio, false)
#end

proc digitalWrite* (pin: string, value: int8) =
  if bone.hasLED(pin):
    let pinLed = $bone.getPinData(pin).led
    writeFile(ledBrightnessFile % [pinLed], $value)
  else:
    let pinGpio = $bone.getPinData(pin).gpio
    writeFile(gpioValueFile % [pinGpio], $value)
  #end
#end

proc digitalRead* (pin: string): int8 =
  if bone.hasLED(pin):
    let pinLed = $bone.getPinData(pin).led
    result = int8(parseInt(readFile(ledBrightnessFile % [pinLed])))
  else:
    let pinGpio = $bone.getPinData(pin).gpio
    result = int8(parseInt(readFile(gpioValueFile % [pinGpio])))
  #end
#end

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