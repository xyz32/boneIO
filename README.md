# BeagleboneBlack_GPIO_nim
GPIO implementation for the BeagleBone black for the [Nim](http://nim-lang.org/) language.
The implementation is using the sysfs to "talk" to the hardware.

# Build
Cd into the root of the project and run:
```
nimble build
```

# Cross compiling
For arm cross compiling download the [linaro](https://www.linaro.org/) tool chain. Edit the nim.cfg file and point all the compiles specific paths to the arm toolchain.
For example:

```
arm.linux.gcc.path = "/home/xyz/apps/gcc-linaro/bin"
arm.linux.gcc.exe = "arm-linux-gnueabihf-gcc"
arm.linux.gcc.linkerexe = "arm-linux-gnueabihf-gcc"
```

Run the ```nimble build``` command.

# TODO
Left to be done:
- [X] GPIO
- [X] PWM
- [ ] Servos
- [ ] ADC
- [ ] I2P
- [ ] UART
