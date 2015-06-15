#http://elinux.org/EBC_Exercise_13_Pulse_Width_Modulation
import bone, strutils

const
  slotsFile = "/sys/devices/bone_capemgr.?/slots"
  capeName = "am33xx_pwm"
  pwmNameTamplate = "bone_pwm_$1"
  pwmPeriodFile = "/sys/devices/ocp.?/pwm_test_$1.??/period"
  pwmDutyFile = "/sys/devices/ocp.?/pwm_test_$1.??/duty"

proc startPWM* (pin: string) =
  if bone.pinHasData(pin, "pwm"):
    writeFile(slotsFile, capeName)
    writeFile(slotsFile, pwmNameTamplate % [pin])
  else:
    raise newException(ValueError, "Pin '" & pin & "' does not support PWM")
  #end
#end

proc setPWM* (pin: string, duty: int32, period: int32 = 20000000) =
  var dutyNs = period * (duty/100)
  writeFile(pwmPeriodFile % [pin], period)
  writeFile(pwmDutyFile % [pin], dutyNs)
#end

when isMainModule:
  discard
