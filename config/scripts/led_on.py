#!/usr/bin/env python2
#
# Turns on the LED array (GPIO18, Pin 12)
#

import gpio

gpio.setup(18, gpio.OUT)
gpio.output(18, True)
