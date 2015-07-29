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

#http://elinux.org/EBC_Exercise_13_Pulse_Width_Modulation
import bone, strutils, os

const
  capeName = "am33xx_pwm"
  pwmNameTamplate = "bone_pwm_$1"
  slotsFile = "/sys/devices/bone_capemgr.?/slots"
  pwmPeriodFile = "/sys/devices/ocp.?/pwm_test_$1.??/period"
  pwmDutyFile = "/sys/devices/ocp.?/pwm_test_$1.??/duty"

proc buildFileName (nameTemplate: string): string =
  for file in walkFiles nameTemplate:
    result = file
    break
  #end
#end

proc readFile (fileName: string): string =
  #Workaround for the ftell limitations.
  var tFile = open(buildFileName(fileName), fmRead)
  result = ""
  try:
    while true:
      result = result & tFile.readLine() & "\n"
    #end
  except IOError: discard
  finally:
    tFile.close()
  #end
#end

proc writeFile (fileName: string, data: string) =
  #wrap the system function so we can scan for regex filenames.
  system.writeFile(buildFileName(fileName), data)
#end

proc isCapeEnabled (): bool =
  result = contains(readFile(slotsFile), capeName)
#end

proc isPWMEnabled (pin: string): bool =
  result = contains(readFile(slotsFile), pwmNameTamplate)
#end

proc pinModePWM* (pin: string, freqHz: int32) =
  if bone.hasPWM(pin):
    if not isCapeEnabled():
      writeFile(slotsFile, capeName)
    #end

    if not isPWMEnabled(pin):
      writeFile(slotsFile, pwmNameTamplate % [pin])

      #Give the device time to settle
      var timeout = 10
      var sleepInterval = 10
      while (not existsFile(pwmPeriodFile % [pin])) and timeout > 0 :
        sleep (sleepInterval)
        timeout = timeout - 1;
      #end
    #end

    var period = int64((1/float(freqHz)) * 1_000_000_000) #to nanoseconds
    writeFile(pwmPeriodFile % [pin], $period)
  else:
    raise newException(ValueError, "Pin '" & pin & "' does not support PWM")
  #end
#end

proc checkDuty (duty: float) =
  if duty < 0 or duty > 1:
    raise newException(ValueError, "Duty is a percentage value between [0..1]. Got " & $duty)
  #end
#end

proc getDutyInNs(duty: float, period: int64): int64 =
  result = int64(float(period) * duty)
#end

proc analogWrite* (pin: string, duty: float) =
  ## Use pwm to write an analogic output.

  checkDuty(duty)

  var period = int64(parseInt(strip(readFile(pwmPeriodFile % [pin]), true, true)))

  writeFile(pwmDutyFile % [pin], $getDutyInNs(duty, period))
#end

# Testing
when isMainModule:
  discard
