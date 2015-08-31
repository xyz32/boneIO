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
  ## Searches for the first file on the disk that matches the file name template or throws an exception otherwise.
  result = ""
  for file in walkFiles nameTemplate:
    result = file
    return
  #end
  # Did not find any file.
  # raise newException(IOError, "No file matching the template '" & nameTemplate & "' was found.")
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

proc waitForFile* (fileName: string) =
  ## Wait untill a file is created
  ## TODO: Maybe use fsmonitor for this? http://nim-lang.org/docs/fsmonitor.html
  let sleepInterval = 10
  var timeout = 100
  
  while timeout > 0 :
    let fileToCheck = buildFileName(fileName)
    if existsFile(fileToCheck):
      return
    #end

    sleep (sleepInterval)
    timeout = timeout - 1;
  #end

  raise newException(IOError, "File creation timeout. File: " & fileName)
#end

proc enable* (capeName: string) =
  if not isEnabled(capeName):
    writeFile(slotsFile, capeName)
  #end
#end
