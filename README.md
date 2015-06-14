# BeagleboneBlack_GPIO_nim
GPIO implementation for the BeagleBone black for the [Nim](http://nim-lang.org/) language.

# Cross compiling
For arm cross compiling download the [linaro](https://www.linaro.org/) tool chain. Edit the nim.cfg file and point all the compiles specific paths to the arm toolchain.
For example:

```
arm.linux.gcc.path = "/home/xyz/apps/gcc-linaro/bin"
arm.linux.gcc.exe = "arm-linux-gnueabihf-gcc"
arm.linux.gcc.linkerexe = "arm-linux-gnueabihf-gcc"
```
