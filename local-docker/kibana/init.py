#!/usr/bin/env python
import subprocess
with open("output.txt", "w+") as output:
    subprocess.call(["python", "./script.py"], stdout=output)