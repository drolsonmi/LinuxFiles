#!/usr/bin/env python
import sys

lines = open("/home/meo/.cache/weather.xml", 'r').read()
print(lines.split(sys.argv[1])[1][1:-2])
