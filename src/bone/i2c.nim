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

import bone, bone/cape, strutils, os, posix

const
  i2cDevFile = "/dev/i2c-$1"
  i2cCape = "I2C$1"

  #i2c controller bus flags
  I2C_RETRIES     = 0x0701 ## number of times a device address should be polled when not acknowledging
  I2C_TIMEOUT     = 0x0702 ## set timeout in units of 10 ms

  # NOTE: Slave address is 7 or 10 bits, but 10-bit addresses
  # are NOT supported! (due to code brokenness)

  I2C_SLAVE       = 0x0703 ## Use this slave address
  I2C_SLAVE_FORCE = 0x0706 ## Use this slave address, even if it is already in use by a driver!
  I2C_TENBIT      = 0x0704 ## 0 for 7 bit addrs, != 0 for 10 bit

  I2C_FUNCS       = 0x0705 ## Get the adapter functionality mask

  I2C_RDWR        = 0x0707 ## Combined R/W transfer (one STOP only)

  I2C_PEC         = 0x0708 ## != 0 to use PEC with SMBus
  I2C_SMBUS       = 0x0720 ## SMBus transfer

proc closeBus* (busHandle: File) =
  ## Close the i2c bus and return a handle

  close(busHandle)
#end

proc openBus* (busID: int): File =
  ## Open the i2c bus and return a handle

  cape.enable(i2cCape % [$busID])
  result = open(i2cDevFile % [$busID], fmReadWrite)
#end

proc setSlaveAddress (busHandle: File, slaveAddr: int) =
  ## Set up the i2c bus to connect to a specific client

  if ioctl(getFileHandle(busHandle), I2C_SLAVE, uint(slaveAddr)) != 0:
    raiseOSError(osLastError(), "Failed to set slave address '" & $slaveAddr & "':")
  #end
#end

proc setMemoryAddress (deviceHandle: File, memoryAddress: byte) =
  var addrObj: array [0..0, byte]
  
  addrObj[0] = memoryAddress
  if posix.write(getFileHandle(deviceHandle), addr(addrObj[0]), 1) != 1:
    raise newException(IOError, "Failed to set memory address '" & $memoryAddress & "'")
  #end
#end

proc putBytes* (deviceHandle: File, slaveAddr: int, memoryAddress: byte, data: openArray[byte]): int =
  ## Set the memory location to be read from, and read the data.

  var dataPlusAddress: seq [byte]

  newSeq(dataPlusAddress, data.len + 1)
  dataPlusAddress[0] = memoryAddress
  for i in low(data)..high(data):
      dataPlusAddress[i+1] = data[i]
  #end
  
  setSlaveAddress(deviceHandle, slaveAddr)

  result = posix.write(getFileHandle(deviceHandle), addr(dataPlusAddress[0]), dataPlusAddress.len)
  if result != dataPlusAddress.len:
    raise newException(IOError, "Failed to write '" & $data.len & "' bytes at address '" & $memoryAddress & "'")
  #end
#end

proc getBytes* (deviceHandle: File, slaveAddr: int, memoryAddress: byte, data: var openArray[byte], length: int): int =
  ## Read bytes from the device at the specified address.

  setSlaveAddress(deviceHandle, slaveAddr)
  setMemoryAddress(deviceHandle, memoryAddress)

  #result = readBytes(deviceHandle, data, 0, length)
  result = posix.read(getFileHandle(deviceHandle), addr(data[0]), length)
  if result != length:
    raise newException(IOError, "Failed to read bytes from address '" & $memoryAddress & "'")
  #end
#end
