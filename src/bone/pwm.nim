#http://elinux.org/EBC_Exercise_13_Pulse_Width_Modulation
import bone, bone/gpio, strutils

const
  slotsFile = "/sys/devices/bone_capemgr.?/slots"
  capeName = "am33xx_pwm"
  pwmNameTamplate = "bone_pwm_$1"
  pwmPeriodFile = "/sys/devices/ocp.?/pwm_test_$1.??/period"
  pwmDutyFile = "/sys/devices/ocp.?/pwm_test_$1.??/duty"

proc isCapeEnabled (): bool =
  result = contains(readFile(slotsFile), capeName)
#end

proc isPWMEnabled (pin: string): bool =
  result = contains(readFile(slotsFile), capeName)
#end

proc pinModePWM (pin: string) =
  if bone.hasPWM(pin):
    if not isCapeEnabled():
      writeFile(slotsFile, capeName)
    #end

    if not isPWMEnabled(pin):
      writeFile(slotsFile, pwmNameTamplate % [pin])
    #end

  else:
    raise newException(ValueError, "Pin '" & pin & "' does not support PWM")
  #end
#end

proc checkDuty (duty: float) =
  if duty < 0 or duty > 1:
    raise newException(ValueError, "Duty is a percentage [0..1]")
  #end
#end

proc getDutyInNs(duty, period: float): float =
  result = period * duty
#end

proc analogWrite* (pin: string, duty: float) =
  ## Use pwm to write an analogic output.

  checkDuty(duty)
  pinModePWM(pin)

  var period = parseFloat(readFile(pwmPeriodFile % [pin]))

  writeFile(pwmDutyFile % [pin], $getDutyInNs(duty, period))
#end

proc analogWrite* (pin: string, duty: float, freqHz: int32 = 2_000) =
  ## Use pwm to write an analogic output.

  checkDuty(duty)
  pinModePWM(pin)

  var period = float((1/float(freqHz)) * 1_000_000_000) #to nanoseconds

  writeFile(pwmDutyFile % [pin], "0") #reset duty cycle
  writeFile(pwmPeriodFile % [pin], $period)
  writeFile(pwmDutyFile % [pin], $getDutyInNs(duty, period))
#end

# Testing
when isMainModule:
  discard
