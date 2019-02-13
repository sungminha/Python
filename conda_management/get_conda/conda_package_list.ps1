#note that this is for windows
$package_list_default = @(
	#"anaconda" #includes many of the packages below noted as #default on anaconda
	"biopython"
	"boost"  #Free peer-reviewed portable C++ source libraries.
	"bz2file" #library for reading and writing bzip2-compressed files
	"bzip2" #default on anaconda #high-quality data compressor
	"cython" #default on anaconda
	"icu"
	"ipython" #default on anaconda
	"jpeg" #default on anaconda #read/write jpeg COM, EXIF, IPTC medata
	"libpng" #default on anaconda #PNG reference library
	"libtiff" #default on anaconda #Support for the Tag Image File Format (TIFF)
	"line_profiler"
	"memory_profiler"
	"mkl"
	"mkl-devel"
	"mkl-include"
	"mkl-service"
	"mkl_fft"
	"mkl_random"
	"mpld3" #D3 Viewer for Matplotlib
	#"mpi4py" #no longer available for windows x64 and x86 as of 2018-03-23
	"openpyxl" #default on anaconda
	"opencv"
	"openssl"
  "pandas"
	"pillow" #default on anaconda
	"plotly"
	"pyopengl"
	"pyopengl-accelerate"
	"pywin32" #default on anaconda #Python extensions for Windows
	"qt"
	"scikit-image" #default on anaconda
	"scikit-learn" #default on anaconda
	"scipy" #default on anaconda
	"tk" #default on anaconda #A dynamic programming language with GUI support. Bundles Tcl and Tk
	#"tensorflow" #only available on x64
	#"tensorflow-gpu" #requires NVidia GPU and CUDA, and only available on x64
	"unicodecsv" #default on anaconda
	"unxutils" 	#Ports of common GNU utilities to native Win32 / GPL3
	"vispy" #High performance interactive 2D/3D data visualization
	"zlib"
)

$package_list_conda_forge = @(
  "bottle" #Bottle is a fast, simple and lightweight WSGI micro web-framework for Python.
	#"brewer2mpl" #upgraded to palettable
	"dcm2niix"
  "glances" #A cross-platform curses-based monitoring tool - similar to htop on bash terminal
	"nibabel"
	"palettable"
	"pigz" #parallel implementation of gzip, is a fully functional replacement for gzip that exploits multiple processors and multiple cores to the hilt when compressing data.
	"pydicom"
	"pyopencl"
	#"mpi4py=2.0"	#disabled for Windows on conda-forge as of 20180707
)

$package_list_tensorflow = @(
	"tensorflow"
  "tensorflow-base"
	"tensorflow-gpu"
)

$package_list_intel = @(
	"mpi4py" #https://anaconda.org/intel/mpi4py
)

#remove windows x64 only modules if windows x86
Write-Host "Verified CPU architecture as $env:PROCESSOR_ARCHITECTURE";
if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64"){
	Write-Host "No package to remove for Windows ${env:PROCESSOR_ARCHITECTURE}";
}
elseif ($env:PROCESSOR_ARCHITECTURE -eq "x86"){
	#find index of package to remove
	for(${i} = 0; ${i} -lt ${package_list_conda_forge}.Count; ${i}++){
		if (${package_list_conda_forge}[$i] -eq "dcm2niix"){
			$package_to_remove=${package_list_conda_forge}[$i];
			Write-Host "Removing package (${package_to_remove}) (${package_list_conda_forge}[${i}]) for Windows ${env:PROCESSOR_ARCHITECTURE}";
			${index} = ${i};
			${index_b} = $index-1;
			${index_a} = $index+1;
			if ( ${index} -eq 0 ) {
				${package_list_conda_forge} = ${package_list_conda_forge}[$index_a..(${package_list_conda_forge}.length - 1)];
			}
			elseif ( ${index} -eq (${package_list_conda_forge}.Length -and 1) ){
				${package_list_conda_forge} = ${package_list_conda_forge}[0..$index_b];
			}
			else {
				${package_list_conda_forge} = ${package_list_conda_forge}[0..$index_b + $index_a..(${package_list_conda_forge}.length - 1)];
			}
			Remove-Variable index_a;
			Remove-Variable index_b;
			Remove-Variable index;
			Write-Host "package_list_conda_forge: ${package_list_conda_forge}";
			continue;
		}
	}
}



#########################################################
#####Old Code
#########################################################
#$package_list = @(
##"audioread"
##"biopandas"
##"biopython"
##"brewer2mpl" #- updated to palettable, retained for backward compatibility
##"bzip2"	#default on anaconda
##"chemfiles-lib"
##"cryptography"
##"cryptography-vectors"
##"csvkit"
##"cymem"
##"cython"	#default on anaconda
##"docx2txt" #- not available for python3.6 yet
##"ebooklib"
##"glew"
##"glue-core"
##"httplib2"
##"ipyparallel"
##"ipython"	#default on anaconda
##"joblib"
##"latexcodec"
##"libcxx" #- not available for windows
##"libflac"
##"libgpuarray" #- not available for python3.5
##"libogg"
##"libpng"
##"libvorbis"
##"line_profiler"
##"mako"
##"mdanalysis" #- not available for windows
##"mdp"
##"mdsynthesis" #- not available for windows
#"memory_profiler" #-memory consumption monitoring
##"mkl" #-intel math kernel library : default on anaconda
##"mkl-service"	#default on anaconda
#"mpi4py" #mpi client for computers with MPI already installed
##"mpld3" #-not available for windows 32 bit for python3.6
##"nibabel" #-read nifti
##"numba"
##"opencv"
##"openpyxl"	#default on anaconda
#"palettable"
##"pandas"	#default on anaconda
##"paramiko"	#-Python (2.7, 3.4+) implementation of the SSHv2 protocol
##"paraview" #- not available for windows
##"path.py"	#default on anaconda
##"pathlib2"	#default on anaconda
##"pillow"	#default on anaconda
#"plotly" #-An interactive, browser-based graphing library for Python
##"pyglet" #- not available for python3.6 yet
##"py-cpuinfo"
##"pycurl"	#-fetch objects identified by a URL from a Python program
##"pygpu"
##"pymc"	#-Bayesian Stochastic Modelling in Python
##"pyopencl"
#"pyopengl"
#"pyopengl-accelerate"
##"pypdf2"	#-A utility to read and write PDFs with Python
##"pyqt" #-do not have qt installed on windows machines
##"python-docx"
##"python-pptx"
##"pyvtk"
##"pywget"	#pure python download utility 
##"pywin32"	#-Python for Windows Extensions : default on anaconda
##"reikna"	#-pure python gpgpu library
##"requests"	#-http for humans
##"requests-file"
##"scp" #- not available for python3.6 yet
##"scrapy"	#-A Fast and Powerful Scraping and Web Crawling Framework
##"scikit-image"	#default on anaconda
##"scikit-learn"	#default on anaconda
##"scipy"	#default on anaconda
##"sshtunnel"
#"tensorflow"
##"theano" #-requires mingw
##"unicodecsv"	#-drop-in replacement for Python 2.7's csv module which supports unicode strings without a hassle
##"urllib3"	#-powerful, sanity-friendly HTTP client for Python
##"vtk" #-causes custom anaconda install version
##"workerpool"
#)

#$python_major_version = $args[0]
#$python_minor_version = $args[1]
#$python_major_version = [int]$python_major_version
#$python_minor_version = [int]$python_minor_version
#$python_version = 1.0 * $python_major_version + 0.1 * $python_minor_version

#if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64"){
#	echo "Verified CPU architecture as $env:PROCESSOR_ARCHITECTURE and Current Python Version being updated is $python_version"
#	if ( ($python_major_version -eq 3) -and ($python_major_version -eq 5) ){
#		#$package_list.add("pyglet")
#		#$package_list.add("scp")
#	}
#}
#elseif ($env:PROCESSOR_ARCHITECTURE -eq "x86"){
#	echo "Verified CPU architecture as $env:PROCESSOR_ARCHITECTURE and Current Python Version being updated is $python_version"
#	$index = -1
#	for($i = 0; $i -lt $package_list.Count; $i++){
#		if ($package_list[$i] -eq "mpld3"){
#			$index = $i
#		}
#	}
#	if ($index -ge 0){
#		$index_b = $index-1
#		$index_a = $index+1
#		$package_list = $package_list[0..$index_b + $index_a..($package_list.length - 1)]
#		Remove-Variable index_a;
#		Remove-Variable index_b;
#	}
#	Remove-Variable index;
#	#Remove-Variable index_b
#	#Remove-Variable index_a
#}