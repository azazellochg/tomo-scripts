#!/public/EM/Scipion/scipion/software/bin/python
# this script reads logs/*_shifts.txt file from alignframes and invokes two other scripts (motioncor2_plotter.py and plot_drift_table.py) to make nice plots and global drift table!

import os, sys
import glob

try:
        import matplotlib.pyplot as plt
except:
        raise Exception('Matplotlib module was not found! Do this: export LD_LIBRARY_PATH="/public/EM/Scipion/scipion/software/lib:${LD_LIBRARY_PATH}"')

if len(sys.argv) != 2:
        sys.exit("Usage: alignframes_plotter.py <pixelsize_in_Angstroms>")
angperpix = float(sys.argv[1])

fnSh=sorted(glob.glob("logs/*_shifts.txt"))

# create drift profile files
print "Gathering drift statistics..."
count=1
total=len(fnSh)
for f in fnSh:
        print "%d/%d\r" % (count, total)
        outpng=f.replace('shifts.txt', 'drift.png')
        outtxt=f.replace('shifts.txt', 'drift.txt')
        if not os.path.exists(outpng) or not os.path.exists(outtxt):
                os.system("python ~/scripts/motioncor2_plotter.py %s %s %s %s" % (f, outpng, outtxt, angperpix))
        count+=1

# create drift total table
import plot_drift_table
