#!/public/EM/Scipion/scipion/software/bin/python
# This script analyses full-frame drift files from motioncor2 and makes nice plots!
# This is a slightly modified version of https://github.com/C-CINA/focus/blob/master/scripts/proc/motioncor2_plotter.py


import os,sys
import math

try:
        import matplotlib.pyplot as plt
except:
        raise Exception('Matplotlib module was not found! Do this: export LD_LIBRARY_PATH="/public/EM/Scipion/scipion/software/lib:${LD_LIBRARY_PATH}"')

DEBUG = 0

def basic_linear_regression(x, y):
        # taken from http://jmduke.com/posts/basic-linear-regressions-in-python/
        length = len(x)
        sum_x = sum(x)
        sum_y = sum(y)
        sum_x_squared = sum(map(lambda a: a * a, x))
        sum_of_products = sum([x[i] * y[i] for i in range(length)])
        a = (sum_of_products - (sum_x * sum_y) / length) / (sum_x_squared - ((sum_x ** 2) / length))
        b = (sum_y - a * sum_x) / length
        return a, b

if __name__ == "__main__":

        if len(sys.argv) != 5:
                sys.exit("Usage: motioncor2_plotter.py <Data-File> <Output-File> <Output text file> <pixelsize_in_Angstroems>")

        infile = sys.argv[1]
        outfile = sys.argv[2]
        txtfile = sys.argv[3]
        angperpix = float(sys.argv[4])

        imodFlag = False  # in development
        #frcfile = infile.replace('_shifts.txt', '_aligned.frc')
        #logfile = "_".join(infile.split('_')[0:2]) + '_aligned.log'
        #fname = infile.replace('_shifts.txt', '').replace('logs/', '')
        #if os.path.exists(frcfile) and os.path.exists(logfile):
        #       imodFlag = True

        #with open(logfile) as log_file:
        #       lines = (line.rstrip() for line in log_file) # All lines including the blank ones
        #       lines = list(line for line in lines if line) # Non-blank lines

        #for l in lines:
        #       print l
        #       if "--- FRC crossings at 0.5" in l:
        #               break
        #       else:
        #               continue
        #       if fname in l:
        #               #print "FOUND FRC in ", log_file, fname
        #               frc = l.strip().split()[1]
        #               print l, frc
        #               break


        x=[]; y=[];

        with open(infile) as data_file:
                lines = (line.rstrip() for line in data_file) # All lines including the blank ones
                lines = list(line for line in lines if line) # Non-blank lines

        for l in lines:
                if not l.startswith('#'):
                        data_split = l.split()
                        x.append(float(data_split[-2])*angperpix)
                        y.append(float(data_split[-1])*angperpix)

        if DEBUG:
                for i in range(0,len(x)):
                        print i," of ",len(x)," = ",x[i],",",y[i]

        xwidth=max(x)-min(x)
        ywidth=max(y)-min(y)
        rlen = math.sqrt(xwidth*xwidth + ywidth*ywidth)

        if xwidth<ywidth:
                xwidth=ywidth

        if DEBUG:
                print "xmin,xmax = ",min(x),max(x),", ymin,ymax = ",min(y),max(y)
                print "::drift length = ",rlen / 10.0," nm"

        xstart=(max(x)+min(x))/2-0.6*xwidth
        xend  =(max(x)+min(x))/2+0.6*xwidth
        ystart=(max(y)+min(y))/2-0.6*xwidth
        yend  =(max(y)+min(y))/2+0.6*xwidth

        if DEBUG:
                print "xstart,end = ",xstart,xend,xwidth," ,   ystart,end = ",ystart,yend,ywidth

        xdiff=[]; ydiff=[];
        rlongest = 0.0
        for i in range(0,len(x)-1):
                xdiff.append(x[i]-x[i+1])
                ydiff.append(y[i]-y[i+1])

        rlength=[];
        for i in range(0,len(x)-1):
                rcurrent = math.sqrt(xdiff[i]*xdiff[i]+ydiff[i]*ydiff[i])
                rlength.append(rcurrent)
                if rcurrent > rlongest:
                        rlongest = rcurrent
            
        rlongest = rlongest / 10.0
        if DEBUG:
                print "::longest drift step = ",rlongest," nm"

        rdist_sum = 0.0
        for i in range(0,len(x)-2):
                rmid_x = (x[i] + x[i+2]) / 2.0
                rmid_y = (y[i] + y[i+2]) / 2.0
                rdist_x = x[i+1] - rmid_x
                rdist_y = y[i+1] - rmid_y
                rdist = math.sqrt(rdist_x ** 2 + rdist_y ** 2)
                rdist_sum = rdist_sum + rdist
        if sum(rlength) == 0:
                rjitter = 0
        else:
                rjitter = 1000.0 * rdist_sum / sum(rlength)

        if DEBUG:
                print "::jitter of drift = ",rjitter

        sum_x = 0.0
        sum_y = 0.0
        sum_x2 = 0.0
        sum_xy = 0.0
        for i in range(0,len(rlength)):
                if DEBUG:
                        print i," of ",len(rlength)," = ",rlength[i]
                sum_x = sum_x + i
                sum_y = sum_y + rlength[i]
                sum_x2 = sum_x2 + i*i
                sum_xy = sum_xy + i*rlength[i]
        if DEBUG:
                print "len(rlength) = ",len(rlength)
                print "sum_x = ",sum_x,",  sum_y = ",sum_y,",  sum_x2 = ",sum_x2,",  sum_xy = ",sum_xy
        if (rlength == 0 or sum_x == 0):
                slope = 0
        else:
                slope = (sum_xy - (sum_x * sum_y) / len(rlength)) / (sum_x2 - ((sum_x ** 2) / len(rlength)))

        if len(rlength) == 0:
                offset = 0
        else:
                offset = (sum_y - slope * sum_x) / len(rlength)
        if DEBUG:
                print "::offset of drift = ",offset
                print "::slope  of drift = ",slope

        plt.figure(figsize=(8,8))
        plt.subplot(111,autoscale_on=False,aspect='equal',xlim=[xstart,xend],ylim=[ystart,yend])
        plt.plot(x,y,'bo',markersize=3,linewidth=0.5)
        plt.plot(x,y,markersize=1,linewidth=0.5)
        plt.plot(x[0],y[0],'bo',markersize=10,linewidth=0.5)
        plt.title('Drift profile')
        plt.xlabel('X-Shift [A]')
        plt.ylabel('Y-Shift [A]')
        plt.grid(True)

        plt.savefig(outfile)

        if DEBUG:
                print "Opening ", txtfile
        data_file_out = open(txtfile,'w')
        line = "Diameter of total drift range in movie (A) = " + str(rlen) + "\n"
        data_file_out.write(line)
        line = "Maximal drift between two consecutive frames (A) = " + str(rlongest) + "\n"
        data_file_out.write(line)
        line = "Deceleration of drift - positive if drift slows down during movie in Angst/frame = " + str(-10.0*slope) + "\n"
        data_file_out.write(line)
        line = "Jitter of drift profile = " + str(rjitter) + "\n"
        data_file_out.write(line)
        #line = "FRC crosses 0.5 at = " + str(frc) + "\n"
        #data_file_out.write(line)

        # stuff below is not implemented yet!
        if imodFlag:
                line = "Weighted residual mean (px) = " + float(wres) + "\n"
                data_file_out.write(line)
                line = "Max unweighted resid mean (px) = " + float(uwres) + "\n"
                data_file_out.write(line)
                line = "Raw sum of distances from one frame position to the next (px) = " + float(rawdist) + "\n"
                data_file_out.write(line)
                line = "Sum of smoothed distances (px) = " + float(smdist) + "\n"
                data_file_out.write(line)

        data_file_out.close()
        #os.system('cat %s' % txtfile)
