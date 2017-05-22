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
import boneIO, os, boneIO/cape, strutils

const
  capeName = "cape-bone-iio"
  adcPinFile = "/sys/devices/ocp.?/helper.??/AIN$1"

proc pinModeADC* (pin: string) =
  ## Enable the ADC mode for the pin
  
  if boneIO.hasADC(pin):
    cape.enable(capeName) #Make sure the pwm controller is enabled
  else:
    raise newException(ValueError, "Pin '" & pin & "' does not support ADC")
  #end
#end

proc analogRead* (pin: string): int =
  ## Read analogic data form ADC pin.
  
  let adcNo = boneIO.getPinData(pin).ain
  result = parseInt(strip(cape.readFile(adcPinFile % [$adcNo]), true, true))
#end
