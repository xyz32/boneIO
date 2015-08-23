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
import strutils, os

const
  slotsFile = "/sys/devices/bone_capemgr.?/slots"
  
proc buildFileName* (nameTemplate: string): string =
  for file in walkFiles nameTemplate:
    result = file
    break
  #end
#end

proc readFile* (fileName: string): string =
  #wrap the system function so we can scan for regex filenames.
  result = system.readFile(buildFileName(fileName))
#end

proc writeFile* (fileName: string, data: string) =
  #wrap the system function so we can scan for regex filenames.
  system.writeFile(buildFileName(fileName), data)
#end
  
proc isEnabled* (capeName: string): bool =
  result = contains(readFile(slotsFile), capeName)
#end

proc enable* (capeName: string) =
  writeFile(slotsFile, capeName)
  #Give the device time to settle
  var timeout = 100
  var sleepInterval = 10
  while (not existsFile(capeName)) and timeout > 0 :
    sleep (sleepInterval)
    timeout = timeout - 1;
  #end
#end
