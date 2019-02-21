#!/usr/bin/env python

import os, sys

EXEC_NAME = "GetOverlap.py"

# Usage info
def usage():
    """usage information"""
    print r"""
  %(EXEC)s--

  Get a dice score for each unique ROI within the reference image and finally, the mean dice score

  Usage: %(EXEC)s [OPTIONS]

  Reqd:
    [ -i ]	Input label file
    [ -r ]	Reference label file
  
  Optional:
    [ -n ]	Number of processors to use (default: 1)
    [ -o ]	Get overall dice only, instead of calculating them for all ROIs (default: calculate for all)
    [ -I ]	Calculate dice score only for the given intensity (default: calculate for all)
    [ -F ]	Full output, including Dice, Sensitivity and Specificity (default: calculate only Dice)

  """ % {'EXEC':EXEC_NAME}


### Define signal trap function
def signal_handler(signal, frame):
        print('You pressed Ctrl+C!')
        pool.terminate()
        sys.exit(0)

### Calculate all metrics
def calculateMetrics(roi):

	iC = np.count_nonzero( inp==roi )
	rC = np.count_nonzero( ref==roi )

	TP = overlap[ inp==roi ].sum()
	FP = iC - TP
	FN = rC - TP
	TN = np.count_nonzero( (inpImg!=roi) & (refImg!=roi) )
	
	if rC == 0:
		FNR = 0
	else:
		FNR = 1.0 * FN / ( FN + TP )

	if iC == 0:
		Prec = 0
	else:
		Prec = 1.0 * TP / ( TP + FP )
		
	
	Jacc = 1.0 * TP / ( TP + FP + FN )
	Dice = 2.0 * TP / ( 2.0 * TP + FP + FN )
	
	Accu = 1.0 * ( TP + TN ) / ( TP + TN + FP + FN )

	Sens = 1.0 * TP / ( TP + FN )
	Spec = 1.0 * TN / ( TN + FP )

	FPR  = 1 - Spec
	FDR  = 1 - Prec
	Reca = Sens

	Fone = 2 * (Prec * Reca) / (Prec + Reca)

	return [ Jacc, Dice, Accu, Sens, Spec, FPR, FNR, Prec, Reca, Fone ]
	
### Dice calculation function
def calculateDice(roi):
	return 2.0 * overlap[ inp==roi ].sum() / ( np.count_nonzero(inp==roi) + np.count_nonzero(ref==roi) )

### MAIN PROGRAM
#def main():
if __name__ == '__main__':

	# Check the number of arguments
	if len(sys.argv) < 2:
		usage()
		sys.exit(0)

	### Import some more modules
	import getopt
	import signal
	import nibabel as nib
	import numpy as np

	### signal handler
	signal.signal(signal.SIGINT, signal_handler)

	### Default arguments
	numproc 	= int(1)
	overallOnly 	= int(0)
	intensity 	= []
	fulloutput 	= int(0)

	### Read command line args
	try:
		opts, args = getopt.getopt(sys.argv[1:], "i:r:n:oI:Fd:")

	except getopt.GetoptError, err:
		usage()
		print "ERROR!", err

	### Parse the command line args
	for o, a in opts:
		if o in ["-i"]:
			iLabel = str(a)
		elif o in ["-r"]:
			rLabel = str(a)
		elif o in ["-n"]:
			numproc = int(a)
		elif o in ["-o"]:
			overallOnly = int(1)
		elif o in ["-I"]:
			intensity.append(a)
		elif o in ["-F"]:
			fulloutput = int(1)
		else:
			usage()
			sys.exit(0)

	### Reading image data
	refImg = nib.load(os.path.join(rLabel)).get_data().astype(int)
	inpImg = nib.load(os.path.join(iLabel)).get_data().astype(int)
	
	inp = inpImg[ (inpImg!=0) | (refImg!=0) ]
	ref = refImg[ (inpImg!=0) | (refImg!=0) ]
	
	overlap = np.where( (inp == ref), 1, 0)

	if overallOnly == 0:

		### Get the multiprocessing module that is used only if multiple ROIs are used
		import multiprocessing

		### Getting ROI list
		if intensity:
			ROIs = np.array(intensity).astype(int)
		else:
			ROIs = np.unique(ref[np.nonzero(ref)])	

		### Calculating Dice using "numproc" processors
		pool = multiprocessing.Pool(processes=numproc)
	
		if fulloutput == 0:		### If only Dice are to be calculated
			DiceScores = []
			pool.map_async(calculateDice, (ROIs), callback=DiceScores.extend).wait()
			DiceScores = np.array(DiceScores)
		
			### Print output
			print "ROI \t   Dice"
			for i in range(0,len(ROIs)):
				print "%d \t %8.4f" % (ROIs[i], DiceScores[i])
		
			print "\nMean \t %8.4f" % (DiceScores.mean())

		else:				### If all metrices are to be calculated
			Metrics = []
			pool.map_async(calculateMetrics, (ROIs), callback=Metrics.extend).wait()
			Metrics = np.array(Metrics).round(4)
			MetMean = Metrics.mean(axis=0).round(4)
			
			### Print output
			metrics = [ 'ROI', 'Jaccard', 'Dice', 'Accuracy', 'Sensitivity', 'Specificity', \
					'FPR', 'FNR', 'Precision', 'Recall', 'F1score' ]
			col_width = max( len(word) for word in ['Overall']+metrics ) + 2  # padding
			
			print( "".join( word.ljust(col_width) for word in metrics ) )
			
			for i in range( 0,len(ROIs) ):
				stats = [ ROIs[i] ] + Metrics[i].tolist()
				print "".join( str(word).ljust(col_width) for word in stats )
		
			meanstats = ["Mean"] + MetMean.tolist()
			print "".join( str(word).ljust(col_width) for word in meanstats )
			

	elif overallOnly == 1:
		### Print output
		if fulloutput == 0:
			metrics = [ 'ROI', 'Dice' ]
			col_width = max( len(word) for word in ['Overall']+metrics ) + 2  # padding
			
			print( "".join( word.ljust(col_width) for word in metrics ) )
		else:
			metrics = [ 'ROI', 'Jaccard', 'Dice', 'Accuracy', 'Sensitivity', 'Specificity', \
					'FPR', 'FNR', 'Precision', 'Recall', 'F1score' ]
			col_width = max( len(word) for word in ['Overall']+metrics ) + 2  # padding
			
			print( "".join( word.ljust(col_width) for word in metrics ) )
	


		### Overall output
		if fulloutput == 1:		### If all metrices are to be calculated

			iC = np.count_nonzero( inp!=0 )
			rC = np.count_nonzero( ref!=0 )

			TP = overlap.sum()
			FP = iC - TP
			FN = rC - TP
			TN = np.where( (inpImg == 0) & (refImg == 0) , 1, 0).sum()
	
			FPR = np.round( 1.0 * FP / ( FP + TN ), 4 )
			FNR = np.round( 1.0 * FN / ( FN + TP ), 4 )

			Jacc = np.round( 1.0 * TP / ( TP + FP + FN ), 4 )
			Dice = np.round( 2.0 * TP / ( 2.0 * TP + FP + FN ), 4 )

			Accu = np.round( 1.0 * ( TP + TN ) / ( TP + TN + FP + FN ), 4 )

			Sens = np.round( 1.0 * TP / ( TP + FN ), 4 )
			Spec = np.round( 1.0 * TN / ( TN + FP ), 4 )
			Prec = np.round( 1.0 * TP / ( TP + FP ), 4 )
			Reca = Sens
		
			Fone = np.round( 2 * (Prec * Reca) / (Prec + Reca), 4 )

			overallstats = [ "Overall", Jacc, Dice, Accu, Sens, Spec, FPR, FNR, Prec, Reca, Fone ]
			print "".join( str(word).ljust(col_width) for word in overallstats )


		elif fulloutput == 0:		### If only Dice is to be calculated

			iC = np.count_nonzero( inp!=0 )
			rC = np.count_nonzero( ref!=0 )

			TP = overlap.sum()
			FP = iC - TP
			FN = rC - TP

			Dice = np.round( 2.0 * TP / ( 2.0 * TP + FP + FN ), 4 )

			overallstats = [ "Overall", Dice ]
			print "".join( str(word).ljust(col_width) for word in overallstats )

