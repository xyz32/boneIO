#
# Copyright 2015 Radu Oana <oanaradu32 at gmail dot com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# http://elinux.org/Interfacing_with_I2C_Devices#Beagleboard_I2C2_Enable

import bone, bone/cape, strutils, os

const
  i2cDevFile = "/dev/i2c-$1"
  i2cCape = "I2C$1"

proc ioctl(f: File, device: uint): int {.importc: "ioctl", 
  header: "<sys/ioctl.h>", varargs, tags: [WriteIOEffect].}

proc closeBus* (busHandle: File) =
  ## Close the i2c bus and return a handle
  
  close(busHandle)
#end

proc openBus* (busID: int): File =
  ## Open the i2c bus and return a handle
  
  cape.enable(i2cCape % [$busID])
  result = open(i2cDevFile % [$busID], fmReadWrite)
  defer: closeBus(result)
#end

proc setSlaveAddress* (busHandle: File, slaveAddr: int) =
  ## Set up the i2c bus to connect to a specific client
  
  if ioctl(busHandle, uint(slaveAddr), 0x0) != 0:
    raise newException(IOError, "Failed to set slave address: '" & $slaveAddr & "'")
  #end
#end

proc readRaw* (busID: int, deviceID: int, data: var openArray[int8|uint8], nBytes: int): int =
  ## Reads the nBytes of the device at address deviceID
  var
    bus: File
  
  bus = openBus(busID)
  setSlaveAddress(bus, deviceID)
  result = readBytes(bus, data, 0, nBytes)
#end

proc i2cWrite* (busID: int, deviceID: int, regAddr: int, data: int): int =
  ## Writes data to the registry at address ``regAddr`` on device ``deviceID`` on I2Cbus ``adapterID``
  
  discard
#end

proc i2cDump* (busID: int, deviceID: int): seq[int] =
  ## Reads the entire memory space of the device ``deviceID`` on I2Cbus ``adapterID``
  
  discard
#end

proc i2cScan* (busID: int): seq[int] =
  ## Scans the entire I2CBus for available devices.
  ## WARNING: It may interfeer with other drivers.
  
  discard
#end