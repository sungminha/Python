#!/usr/bin/env python

"""
	Calculate Image Similarity
"""

################################################ DECLARATIONS ################################################
__author__ 	= 'Jimit Doshi'
__EXEC_NAME__ 	= "CalculateImageSimilarity"

import os as _os
import sys as _sys

import pythonUtilities

################################################ FUNCTIONS ################################################


# Usage info
#DEF
def help():

	#Import some modules
	import sys as _sys

	"""usage information"""
	print r"""
%(EXEC)s--

Get similarity scores between 2 images

USAGE 	:	%(EXEC)s -a <file> -b <file>
RETURNS : 	( corr, ccc, cos )
		corr - Pearson product-moment correlation coefficient
		ccc  - Concordance correlation coefficient
		cos  - Cosine similarity score
	

OPTIONS:

Required:
	[ -a ]	   < file >	absolute path to the input file
	[ -b ]	   < file >	absolute path to the reference file

Miscellaneous:
	[ -s ]			return only the sum of all metrics
	[ -m ]	   < file >	absolute path to the mask file (optional)	
	[ -h ]     		this help page	
	[ -V ]			Version Information


Examples:
	CalculateImageSimilarity -a /Path/To/Source/Directory/Input_n3_str.nii.gz -b /Path/To/Source/Directory/Reference_n3_str.nii.gz


	""" % {'EXEC':__EXEC_NAME__}

	_sys.exit(0)
#ENDDEF


### Define signal trap function
#DEF
def signal_handler(signal, frame):
	
	#Import some modules
	import sys as _sys
	
	print('Program interrupt signal received! Aborting operations ...')
	_sys.exit(0)
#ENDDEF
    


############## MAIN ##############
#DEF
def _main( argv ):
	
#	### Import some modules
#	import time as _time
	
	### Check the number of arguments
	if len( argv ) < 2:
		help()
		_sys.exit(0)

#	### Timestamps
#	startTime 	= _time.asctime()
#	startTimeStamp 	= _time.time()

#	print "\nHostname	: " + str( _os.getenv("HOSTNAME") )
#	print "Start time	: " + str( startTime )

	### Import some more modules
	import signal as _signal
	import getopt as _getopt
	
	### Specifying the trap signal
	_signal.signal( _signal.SIGHUP, signal_handler )
	_signal.signal( _signal.SIGINT, signal_handler )
	_signal.signal( _signal.SIGTERM, signal_handler )

	### Default arguments
	inputImg 	= None
	refImg 		= None
	maskImg 	= None
	sumonly 	= int( 0 )


#	### Read command line args
#	print "\nParsing args 	: ", argv[ 1: ]

	#TRY
	try:
		opts, args = _getopt.getopt( argv[1:], \
				"a:b:shVm:" )

	except _getopt.GetoptError, err:
		help()
		print "ERROR!", err
	#ENDTRY

	### Parse the command line args
	#FOR
	for o, a in opts:
		#IF
		if o in [ "-a" ]:
			inputImg = str(a)
			pythonUtilities.checkFile( inputImg )
	
			inputdName, inputbName, inputExt = pythonUtilities.FileAtt( inputImg )
			inputImg = inputdName + '/' + inputbName + inputExt

	    	elif o in [ "-b" ]:
			refImg = str(a)
			pythonUtilities.checkFile( refImg )
	
			refdName, refbName, refExt = pythonUtilities.FileAtt( refImg )
			refImg = refdName + '/' + refbName + refExt

	    	elif o in [ "-m" ]:
			maskImg = str(a)
			pythonUtilities.checkFile( maskImg )
	
			maskdName, maskbName, maskExt = pythonUtilities.FileAtt( maskImg )
			maskImg = maskdName + '/' + maskbName + maskExt

		elif o in [ "-s" ]:
			sumonly = int( 1 )

		elif o in [ "-V" ]:
			print "FIX THIS!!!"

		elif o in [ "-h" ]:
			help()

		else:
			help()
			_sys.exit(0)
		#ENDIF
	#ENDFOR

	### Reading image data
	import nibabel as _nib
	
	inpImgData = _nib.load( _os.path.join( inputImg ) ).get_data()
	refImgData = _nib.load( _os.path.join( refImg ) ).get_data()
		

	if maskImg:
		maskImgData = _nib.load( _os.path.join( maskImg ) ).get_data()
		inp = inpImgData[ (maskImgData!=0) ].reshape(-1).astype( 'float' )
		ref = refImgData[ (maskImgData!=0) ].reshape(-1).astype( 'float' )		
	else:
		inp = inpImgData[ (inpImgData!=0) | (refImgData!=0) ].reshape(-1).astype( 'float' )
		ref = refImgData[ (inpImgData!=0) | (refImgData!=0) ].reshape(-1).astype( 'float' )

	
	### Calculate Similarity
	print( calculateStats( inp, ref, sumonly ) )
	
#	### Execution Time
#	print "\nEnd time	: " + str( _time.asctime() )
#	pythonUtilities.executionTime( startTimeStamp )
#ENDDEF


#DEF
def calculateStats( a,b,s=0 ):
	
	"""
	
	Calculate similarity measures
	
	Parameters
	----------

	a	: 1-D Numpy array
			Array one
	b	: 1-D Numpy array
			Array two
	s	: int8
			Return sum of scores only
	"""
	
	import numpy as _np

	corr 	= _np.corrcoef( a, b )[0,1]
	aVar 	= _np.var(a)
	bVar 	= _np.var(b)
	ccc	= 2 * corr * _np.sqrt( aVar ) * _np.sqrt( bVar ) / ( aVar + bVar + ( a.mean() - b.mean() )**2 )
	cos 	= _np.sum( a*b ).astype( 'float' ) / _np.sqrt( _np.sum( a*a ).astype( 'float' ) * _np.sum( b*b ).astype( 'float' ) )

	if s:
		return corr + ccc + cos
	else:
		return corr, ccc, cos
#ENDDEF

################################################ END OF FUNCTIONS ################################################

################################################ MAIN BODY ################################################

#IF
if __name__ == '__main__':	
	_main( _sys.argv )
#ENDIF
