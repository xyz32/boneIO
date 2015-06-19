#http://elinux.org/EBC_Exercise_13_Pulse_Width_Modulation
import bone, strutils

const
  slotsFile = "/sys/devices/bone_capemgr.?/slots"
  capeName = "am33xx_pwm"
  pwmNameTamplate = "bone_pwm_$1"
  pwmPeriodFile = "/sys/devices/ocp.?/pwm_test_$1.??/period"
  pwmDutyFile = "/sys/devices/ocp.?/pwm_test_$1.??/duty"

proc pinModePWM (pin: string) =
  if bone.hasPWM(pin):
    writeFile(slotsFile, capeName)
    writeFile(slotsFile, pwmNameTamplate % [pin])
  else:
    raise newException(ValueError, "Pin '" & pin & "' does not support PWM")
  #end
#end

proc setPWM* (pin: string, duty: int32, period: int32 = 20000000) =
  pinModePWM(pin)
  if duty < 0 or duty > 100:
    raise newException(ValueError, "Duty is a percentage [0..100]")
  #end

  var dutyNs = float(period) * (duty/100)
  writeFile(pwmPeriodFile % [pin], $period)
  writeFile(pwmDutyFile % [pin], $dutyNs)
#end

# Testing
when isMainModule:
  discard
