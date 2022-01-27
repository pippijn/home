from datetime import datetime
import os
import glob

for path in glob.glob("????/??/????-??-??_??-??-??-???.*"):
    fn = os.path.basename(path)
    t = datetime.strptime(fn[:fn.rindex(".") - 4], "%Y-%m-%d_%H-%M-%S").timestamp()
    os.utime(path, (t, t))
