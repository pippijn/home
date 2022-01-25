from datetime import datetime
import os
import glob

for fn in glob.glob("????-??-??_??-??-??-???.*"):
    t = datetime.strptime(fn[:fn.rindex(".") - 4], "%Y-%m-%d_%H-%M-%S").timestamp()
    os.utime(fn, (t, t))
