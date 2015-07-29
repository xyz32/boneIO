#
# Copyright (c) 2015 Radu Oana <oanaradu32@gmail.com>
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

import bone/pwm

type
  Servo = object
    minDuty: float
    maxDuty: float
    freqHz: int32
    pinName: string
  #end

proc positionToDuty(servo: Servo, position: float): float =
  result = (servo.maxDuty - servo.minDuty) * position
#end

proc build* (pin: string, minDuty: float = 0.0375, maxDuty: float = 0.1125, freqHz: int32 = 50): Servo =
  ## Creates a new servo object with most common values.
  ##
  ## All "Duty" related parameters are in percentage
  result.minDuty = minDuty
  result.maxDuty = maxDuty
  result.freqHz = freqHz
  result.pinName = pin
  pwm.pinModePWM(result.pinName, result.freqHz)
  pwm.analogWrite(result.pinName, (result.minDuty + result.maxDuty)/2)
#end

proc move* (servo: Servo, position: float) =
  ## Command the servo to move.
  ##
  ## Position is a percentage relative to the maximum range of muvment (maxDuty - minDuty).
  if position < 0 or position > 1:
    raise newException(ValueError, "Duty is a percentage value between [0..1]. Got " & $position)
  #end

  pwm.analogWrite(servo.pinName, positionToDuty(servo, position))
#end
