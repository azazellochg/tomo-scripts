#!/usr/bin/env python
# this script collects output from logs/*drift.txt and makes a nice global drift table!

import glob

fnList=sorted(glob.glob('logs/*_drift.txt'))
if not fnList:
        raise Exception("Error: logs/*_drift.txt file not found!")
filelist, drift, driftMax, deceler, jitter = [], [], [], [], []

for fn in fnList:
        with open(fn, "r") as fname:
                content = fname.readlines()
                filelist.append(str(fn))
                drift.append(float(content[0].split()[-1]))
                driftMax.append(float(content[1].split()[-1]))
                deceler.append(float(content[2].split()[-1]))
                jitter.append(float(content[3].split()[-1]))
                #frc.append(float(content[4].split()[-1]))

with open("logs/drift_table.txt", "w") as outFn:
        header="#Filename | Drift(A) | Max.drift(A) | Deceleration(A/fr) | Jitter\n"
        header+="#Columns: 1 - Filename, 2 - Diameter of total drift range in movie (A), "
        header+="3 - Maximal drift between two consecutive frames (A), 4 - Deceleration of drift - positive if drift slows down during movie in Angst/frame, 5 - Jitter of drift profile\n"
        outFn.write(header)
        for (a, b, c, d, e) in zip(filelist, drift, driftMax, deceler, jitter):
                line="%s %0.6f %0.6f %0.6f %0.6f\n" % (a, b, c, d, e)
                outFn.write(line)
print "Written out file: logs/drift_table.txt"
