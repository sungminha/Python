Param(
	[ Parameter(Position=0) ]
	[switch]$silentOutputScript,
	[ Parameter(Position=1) ]
	[switch]$silentOutputScriptAll
)
#silentOutputScript: don't ouptut start and end statistics
#silentOutputScriptAll: don't even output informative instructions for user

$version="20180218.0";

#Changelog
#20180218.1 - added silentOutputScriptAll switch
#20180218.0 - removed verboseOutputScript
#20180217.0 - added silentOutput and verboseOutput
#20180215.0 - updated start and end stirng outs
#20180211.0 - added safety check to see if conda.exe is available in path
#20180129.0 - separated codes for conda from Powershell profile and wrapped as powershell functions and automatic load scripts

###########################################
#####Start Statistics
###########################################

if ( ${silentOutputScriptAll} ){
	$silentOutputScript = $true;
}

$start_time = $(Get-Date);
$start_time_string = "{0:HH:mm:ss.fffffff}" -f ([datetime]$start_time.Ticks);
$current_script = ${PSCommandPath};
$current_script_dir = (Split-Path -Path ${current_script} -Parent);
$current_script_name = (Split-Path -Path ${current_script} -Leaf);
$current_pid = $script:PID;
$current_pwd = $script:PWD;
$version=[string]$version;

if ( -not ${silentOutputScript} ){
	Write-Host "`n";
	Write-Host "-----------------------------------------------------------------------";
	Write-Host "-------------------------------Start-----------------------------------";
	Write-Host "-----------------------------------------------------------------------";
	Write-Host "Script Dir:`t${current_script_dir}";
	Write-Host "Script Name:`t${current_script_name}";
	Write-Host "Version:`t${version}";
	Write-Host "Script PID:`t${current_pid}";
	Write-Host "Script PWD:`t${current_pwd}";
	Write-Host "Script Start Time:`t${start_time_string}";
	Write-Host "-----------------------------------------------------------------------";
	Write-Host "`n";
}


###########################################
#####Importing outside modules and conda
###########################################

#common locations - computer_name, user_name, 
$home_dir = ($env:HOMEDRIVE + $env:HomePath);
if ( $silentOutputScript ){
	. "${home_dir}\My_Programming\Code_Powershell\Location_common_folders.ps1" -silentOutput_location_common_folders;
}
else{
	. "${home_dir}\My_Programming\Code_Powershell\Location_common_folders.ps1";

}

if ( [string]::IsNullOrEmpty( ${user_profile} ) ) {
	Write-Host "Cannot locate user profile path (usually C:\Users\%username%\). Exiting module get_conda.";
	exit 1;
}

$test_value = "test";
$anaconda3_path = "${user_profile}\Anaconda3\";
$miniconda3_path  = "${user_profile}\Miniconda3\";
$anaconda2_path = "${user_profile}\Anaconda\";
$miniconda2_path  = "${user_profile}\Miniconda\";

$scripts_path = "Scripts\";
$conda_exe = "conda.exe";
$env_path = "envs\";
$python_exe = "python.exe";
$ipython_exe = "ipython.exe";

#find conda.exe
$conda_exe_path = "";
if (Test-Path ${miniconda3_path} ) {
	$conda_exe_path = "${miniconda3_path}${scripts_path}";
	$conda_env_path = "${miniconda3_path}${env_path}";
	$conda_script_path = "${miniconda3_path}${scripts_path}";
}
elseif ( Test-Path ${miniconda2_path} ) {
	$conda_exe_path = "${miniconda2_path}${scripts_path}";
	$conda_env_path = "${miniconda2_path}${env_path}";
	$conda_script_path = "${miniconda2_path}${scripts_path}";
}
elseif (Test-Path ${anaconda3_path} ) {
	$conda_exe_path = "${anaconda3_path}${scripts_path}";
	$conda_env_path = "${anaconda3_path}${env_path}";
	$conda_script_path = "${anaconda3_path}${scripts_path}";
}
elseif ( Test-Path ${anaconda2_path} ) {
	$conda_exe_path = "${anaconda2_path}${scripts_path}";
	$conda_env_path = "${anaconda2_path}${env_path}";
	$conda_script_path = "${anaconda2_path}${scripts_path}";
}

if ( [string]::IsNullOrEmpty(${conda_exe_path}) ){
	Write-Host "No path is found for Anaconda/Miniconda installation. The following paths have been checked: ";
	Write-Host "${miniconda3_path}`n${miniconda2_path}`n${anaconda3_path}`n${anaconda2_path}";
	Write-Host "It is recommended you install miniconda/anaconda from the following link: ";
	Write-Host "Miniconda: https://conda.io/miniconda.html";
	Write-Host "Anaconda: https://www.anaconda.com/download/";
	return;
}
#Remove-Variable miniconda3_path;
#Remove-Variable miniconda2_path;
#Remove-Variable anaconda3_path;
#Remove-Variable anaconda2_path;

if ( -not ${silentOutputScriptAll} ){
	Write-Host "`n";
	Write-Host "-----------------------------------------------------------------------";
	Write-Host "Adding conda paths to the powershell environment: ${conda_exe_path}";
	Write-Host "-----------------------------------------------------------------------";
	Write-Host "`n";
}
$env:Path += ";"+$conda_exe_path; #add conda to the path so conda.exe is recongized


if ((Get-Command -Name "conda.exe" -ErrorAction SilentlyContinue) -eq $null) { 
	Write-Host "${current_script_name} - Error: conda.exe is not available in path.  Exiting module.";
	return;
}

###########################################
#####Importing common environments
###########################################


#py3_7
$py3_7_python_path = ${conda_env_path}+"py3_7\"+$python_exe;
$py3_7_ipython_path = ${conda_env_path}+"py3_7\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_7_python_path ){
	function python3_7 {
		& $py3_7_python_path $args;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_7 python as python3_7 paths to the powershell environment: ${py3_7_python_path}";
	}
	Export-ModuleMember -Function python3_7;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_7_ipython_path} ){
	function ipython3_7 {
		& $py3_7_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_7 ipython as ipython3_7 paths to the powershell environment: ${py3_7_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_7;
	#create an alias for activating the ipython (no need for arguments)
}






#py3_6
$py3_6_python_path = ${conda_env_path}+"py3_6\"+$python_exe;
$py3_6_ipython_path = ${conda_env_path}+"py3_6\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_6_python_path ){
	function python3_6 {
		& $py3_6_python_path $args;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_6 python as python3_6 paths to the powershell environment: ${py3_6_python_path}";
	}
	Export-ModuleMember -Function python3_6;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_6_ipython_path} ){
	function ipython3_6 {
		& $py3_6_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_6 ipython as ipython3_6 paths to the powershell environment: ${py3_6_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_6;
	#create an alias for activating the ipython (no need for arguments)
}




#py3_5
$py3_5_python_path = ${conda_env_path}+"py3_5\"+$python_exe;
$py3_5_ipython_path = ${conda_env_path}+"py3_5\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_5_python_path ){
	function python3_5 {
		& $py3_5_python_path $args;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_5 python as python3_5 paths to the powershell environment ${py3_5_python_path}";
	}
	Export-ModuleMember -Function python3_5;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_5_ipython_path} ){
	function ipython3_5 {
		& $py3_5_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_5 ipython as ipython3_5 paths to the powershell environment: ${py3_5_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_5;
	#create an alias for activating the ipython (no need for arguments)
}


#py2_7
$py2_7_python_path = ${conda_env_path}+"py2_7\"+$python_exe;
$py2_7_ipython_path = ${conda_env_path}+"py2_7\"+$scripts_path+$ipython_exe;
if ( Test-Path $py2_7_python_path ){
	function python2_7 {
		& $py2_7_python_path $args;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py2_7 python as python2_7 paths to the powershell environment: ${py2_7_python_path}";
	}
	Export-ModuleMember -Function python2_7;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py2_7_ipython_path} ){
	function ipython2_7 {
		& $py2_7_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py2_7 python as ipython2_7 paths to the powershell environment: ${py2_7_ipython_path}";
	}
	Export-ModuleMember -Function ipython2_7;
	#create an alias for activating the ipython (no need for arguments)
}




#py3_7_conda_forge
$py3_7_conda_forge_python_path = ${conda_env_path}+"py3_7_conda_forge\"+$python_exe;
$py3_7_conda_forge_ipython_path = ${conda_env_path}+"py3_7_conda_forge\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_7_conda_forge_python_path ){
	function python3_7_conda_forge {
		& $py3_7_conda_forge_python_path $args;
	}
if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_7_conda_forge python as python3_7_conda_forge paths to the powershell environment: ${py3_7_conda_forge_python_path}";
	}
	Export-ModuleMember -Function python3_7_conda_forge;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_7_conda_forge_ipython_path} ){
	function ipython3_7_conda_forge {
		& $py3_7_conda_forge_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_7_conda_forge ipython as ipython3_7_conda_forge paths to the powershell environment: ${py3_7_conda_forge_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_7_conda_forge;
	#create an alias for activating the ipython (no need for arguments)
}





#py3_6_conda_forge
$py3_6_conda_forge_python_path = ${conda_env_path}+"py3_6_conda_forge\"+$python_exe;
$py3_6_conda_forge_ipython_path = ${conda_env_path}+"py3_6_conda_forge\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_6_conda_forge_python_path ){
	function python3_6_conda_forge {
		& $py3_6_conda_forge_python_path $args;
	}
if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_6_conda_forge python as python3_6_conda_forge paths to the powershell environment: ${py3_6_conda_forge_python_path}";
	}
	Export-ModuleMember -Function python3_6_conda_forge;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_6_conda_forge_ipython_path} ){
	function ipython3_6_conda_forge {
		& $py3_6_conda_forge_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_6_conda_forge ipython as ipython3_6_conda_forge paths to the powershell environment: ${py3_6_conda_forge_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_6_conda_forge;
	#create an alias for activating the ipython (no need for arguments)
}





#py2_7_conda_forge
$py2_7_conda_forge_python_path = ${conda_env_path}+"py2_7_conda_forge\"+$python_exe;
$py2_7_conda_forge_ipython_path = ${conda_env_path}+"py2_7_conda_forge\"+$scripts_path+$ipython_exe;
if ( Test-Path $py2_7_conda_forge_python_path ){
	function python2_7_conda_forge {
		& $py2_7_conda_forge_python_path $args;
	}
if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py2_7_conda_forge python as python2_7_conda_forge paths to the powershell environment: ${py2_7_conda_forge_python_path}";
	}
	Export-ModuleMember -Function python2_7_conda_forge;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py2_7_conda_forge_ipython_path} ){
	function ipython2_7_conda_forge {
		& $py2_7_conda_forge_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py2_7_conda_forge ipython as ipython2_7_conda_forge paths to the powershell environment: ${py2_7_conda_forge_ipython_path}";
	}
	Export-ModuleMember -Function ipython2_7_conda_forge;
	#create an alias for activating the ipython (no need for arguments)
}




#py3_7_tensorflow
$py3_7_tensorflow_python_path = ${conda_env_path}+"py3_7_tensorflow\"+$python_exe;
$py3_7_tensorflow_ipython_path = ${conda_env_path}+"py3_7_tensorflow\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_7_tensorflow_python_path ){
	function python3_7_tensorflow {
		& $py3_7_tensorflow_python_path $args;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_7_tensorflow python as python3_7_tensorflow paths to the powershell environment: ${py3_7_tensorflow_python_path}";
	}
	Export-ModuleMember -Function python3_7_tensorflow;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_7_tensorflow_ipython_path} ){
	function ipython3_7_tensorflow {
		& $py3_7_tensorflow_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_7_tensorflow ipython as ipython3_7_tensorflow paths to the powershell environment: ${py3_7_tensorflow_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_7_tensorflow;
	#create an alias for activating the ipython (no need for arguments)
}







#py3_6_tensorflow
$py3_6_tensorflow_python_path = ${conda_env_path}+"py3_6_tensorflow\"+$python_exe;
$py3_6_tensorflow_ipython_path = ${conda_env_path}+"py3_6_tensorflow\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_6_tensorflow_python_path ){
	function python3_6_tensorflow {
		& $py3_6_tensorflow_python_path $args;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_6_tensorflow python as python3_6_tensorflow paths to the powershell environment: ${py3_6_tensorflow_python_path}";
	}
	Export-ModuleMember -Function python3_6_tensorflow;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_6_tensorflow_ipython_path} ){
	function ipython3_6_tensorflow {
		& $py3_6_tensorflow_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_6_tensorflow ipython as ipython3_6_tensorflow paths to the powershell environment: ${py3_6_tensorflow_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_6_tensorflow;
	#create an alias for activating the ipython (no need for arguments)
}





#py2_7_tensorflow
$py2_7_tensorflow_python_path = ${conda_env_path}+"py2_7_tensorflow\"+$python_exe;
$py2_7_tensorflow_ipython_path = ${conda_env_path}+"py2_7_tensorflow\"+$scripts_path+$ipython_exe;
if ( Test-Path $py2_7_tensorflow_python_path ){
	function python2_7_tensorflow {
		& $py2_7_tensorflow_python_path $args;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py2_7_tensorflow python as python2_7_tensorflow paths to the powershell environment: ${py2_7_tensorflow_python_path}";
	}
	Export-ModuleMember -Function python2_7_tensorflow;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py2_7_tensorflow_ipython_path} ){
	function ipython2_7_tensorflow {
		& $py2_7_tensorflow_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py2_7_tensorflow ipython as ipython2_7_tensorflow paths to the powershell environment: ${py2_7_tensorflow_ipython_path}";
	}
	Export-ModuleMember -Function ipython2_7_tensorflow;
	#create an alias for activating the ipython (no need for arguments)
}




#py3_7_conda_forge_tensorflow
$py3_7_conda_forge_tensorflow_python_path = ${conda_env_path}+"py3_7_conda_forge_tensorflow\"+$python_exe;
$py3_7_conda_forge_tensorflow_ipython_path = ${conda_env_path}+"py3_7_conda_forge_tensorflow\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_7_conda_forge_tensorflow_python_path ){
	function python3_7_conda_forge_tensorflow {
		& $py3_7_conda_forge_tensorflow_python_path $args;
	}
if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_7_conda_forge_tensorflow python as python3_7_conda_forge_tensorflow paths to the powershell environment: ${py3_7_conda_forge_tensorflow_python_path}";
	}
	Export-ModuleMember -Function python3_7_conda_forge_tensorflow;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_7_conda_forge_tensorflow_ipython_path} ){
	function ipython3_7_conda_forge_tensorflow {
		& $py3_7_conda_forge_tensorflow_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_7_conda_forge_tensorflow ipython as ipython3_7_conda_forge_tensorflow paths to the powershell environment: ${py3_7_conda_forge_tensorflow_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_7_conda_forge_tensorflow;
	#create an alias for activating the ipython (no need for arguments)
}







#py3_6_conda_forge_tensorflow
$py3_6_conda_forge_tensorflow_python_path = ${conda_env_path}+"py3_6_conda_forge_tensorflow\"+$python_exe;
$py3_6_conda_forge_tensorflow_ipython_path = ${conda_env_path}+"py3_6_conda_forge_tensorflow\"+$scripts_path+$ipython_exe;
if ( Test-Path $py3_6_conda_forge_tensorflow_python_path ){
	function python3_6_conda_forge_tensorflow {
		& $py3_6_conda_forge_tensorflow_python_path $args;
	}
if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py3_6_conda_forge_tensorflow python as python3_6_conda_forge_tensorflow paths to the powershell environment: ${py3_6_conda_forge_tensorflow_python_path}";
	}
	Export-ModuleMember -Function python3_6_conda_forge_tensorflow;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py3_6_conda_forge_tensorflow_ipython_path} ){
	function ipython3_6_conda_forge_tensorflow {
		& $py3_6_conda_forge_tensorflow_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py3_6_conda_forge_tensorflow ipython as ipython3_6_conda_forge_tensorflow paths to the powershell environment: ${py3_6_conda_forge_tensorflow_ipython_path}";
	}
	Export-ModuleMember -Function ipython3_6_conda_forge_tensorflow;
	#create an alias for activating the ipython (no need for arguments)
}







#py2_7_conda_forge_tensorflow
$py2_7_conda_forge_tensorflow_python_path = ${conda_env_path}+"py2_7_conda_forge_tensorflow\"+$python_exe;
$py2_7_conda_forge_tensorflow_ipython_path = ${conda_env_path}+"py2_7_conda_forge_tensorflow\"+$scripts_path+$ipython_exe;
if ( Test-Path $py2_7_conda_forge_tensorflow_python_path ){
	function python2_7_conda_forge_tensorflow {
		& $py2_7_conda_forge_tensorflow_python_path $args;
	}
if ( -not ${silentOutputScriptAll} ){
		Write-Host "Adding conda environment py2_7_conda_forge_tensorflow python as python2_7_conda_forge_tensorflow paths to the powershell environment: ${py2_7_conda_forge_tensorflow_python_path}";
	}
	Export-ModuleMember -Function python2_7_conda_forge_tensorflow;
	#create a function that can take in the arguments and execute
}

if ( Test-Path ${py2_7_conda_forge_tensorflow_ipython_path} ){
	function ipython2_7_conda_forge_tensorflow {
		& $py2_7_conda_forge_tensorflow_ipython_path;
	}
	if ( -not ${silentOutputScriptAll} ){
		Write-Host "`tAdding conda environment py2_7_conda_forge_tensorflow ipython as ipython2_7_conda_forge_tensorflow paths to the powershell environment: ${py2_7_conda_forge_tensorflow_ipython_path}";
	}
	Export-ModuleMember -Function ipython2_7_conda_forge_tensorflow;
	#create an alias for activating the ipython (no need for arguments)
}







Remove-Variable conda_exe_path;
Remove-Variable conda_env_path;
Remove-variable conda_script_path;
Remove-Variable scripts_path;
Remove-Variable conda_exe;
Remove-Variable env_path;
Remove-Variable python_exe;
Remove-Variable ipython_exe;

###########################################
#####Main Function
########################################### 


###########################################
#####Child Functions
###########################################
function add_conda_channel {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: add_conda_channel description.
	#>
	Param(
		[ Parameter(Mandatory=$true, Position=0) ]
		[string]$channelName,
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
			Write-Host "Adding conda channel: ${channelName}";
	}
	conda config --add channels ${channelName};
}
Export-ModuleMember -Function add_conda_channel; 




function conda_clean {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: conda_clean description.
	#>
	Param(
		[ Parameter(Mandatory=$false, Position=0) ]
    [switch]$packages,
		[ Parameter(Mandatory=$false, Position=1) ]
		[switch]$noConfirmation,
		[ Parameter(Mandatory=$false, Position=2) ]
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
		Write-Host "Running command: conda clean -tp";	
	}
  ${extra_arguments} = "--tarballs";
  if ( ${packages} ){
    ${extra_arguments} = "${extra_arguments} --packages";
  }
  if ( ${noConfirmation} ){
    ${extra_arguments} = "${extra_arguments} --yes";
  }
  if ( ${verboseOutput} ){
    ${extra_arguments} = "${extra_arguments} --verbose";
  }
  Invoke-Expression "conda clean ${extra_arguments}";
}
Export-ModuleMember -Function conda_clean; 




function conda_update {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: conda_update description.
	#>
	Param(
		[Parameter(Mandatory=$false, Position=0)]
    [switch]${noConfirmation},
		[Parameter(Mandatory=$false, Position=1)]
		[switch]${verboseOutput},
		[Parameter(Mandatory=$false, Position=2)]
		[switch]${quietOutput},
		[Parameter(Mandatory=$false, Position=3)]
		[switch]${debugOutput}
	)

  if ( ${verboseOutput} -and ${quietOutput} ){
    Write-Output "verboseOutput flag and quietOutput flag cannot both be set at the same time.";
    return;
  }

  if ( ${debugOutput} -and ${quietOutput} ){
    Write-Output "debugOutput flag and quietOutput flag cannot both be set at the same time.";
    return;
  }

	Write-Host "Updating conda package manager";

  ${extra_arguments} = "";

  if ( ${noConfirmation} ){
    ${extra_arguments} = "${extra_arguments} --yes";
  }

  if ( ${verboseOutput} ){
    ${extra_arguments} = "${extra_arguments} --verbose";
  }

  if ( ${debugOutput} ){
    ${extra_arguments} = "${extra_arguments} --debug";
  }

  if ( ${quietOutput} ){
    ${extra_arguments} = "${extra_arguments} --quiet";
  }

  ${full_command} = "conda update conda ${extra_arguments}";
  if ( ${verboseOutput} ){
    Write-Output "Running Command: ${full_command}";
  }
	Invoke-Expression "${full_command}";
}
Export-ModuleMember -Function conda_update; 




function create_conda_environment {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: create_conda_environment description.
	#>
	Param(
		[Parameter(Mandatory=$true, Position=0)]
		[string]$environmentName,
		[Parameter(Mandatory=$false, Position=1)]
		[string]$pythonVersion="3.6",
		[Parameter(Mandatory=$false, Position=2)]
		[string]$anacondaVersion,
		[Parameter(Mandatory=$false, Position=3)]
		[string]$packageNames,
		[switch]$condaForge,
		[switch]$tensorflow,
		[switch]$verboseOutput
	)

	if ( ${verboseOutput} ){
		conda_update -verboseOutput;
	}
	else {
		conda_update;
	}

	. "${PSScriptRoot}/conda_package_list.ps1"; #load default package lists
	if ( ${verboseOutput} ){
		Write-Host "Default channel only packages: ${package_list_default}";
		Write-Host "Conda-Forge additional packages: ${package_list_conda_forge}";
		Write-Host "tensorflow additional packages: ${package_list_tensorflow}";
	}


	if ( !(${condaForge}) -and !(${tensorflow}) ) {
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Python Version: ${pythonVersion}";
			Write-Host "Anaconda Version: ${anacondaVersion} (up-to-date if blank)";
			Write-Host "Installing Packages: anaconda ${package_list_default} ${packageNames}";
			list_conda_channel;
 		}

		if ( [string]::IsNullOrEmpty(${anacondaVersion} ) ) {
		conda create --name ${environmentName} python=${pythonVersion} anaconda ${package_list_default} ${packageNames};
		}
		else{
		conda create --name ${environmentName} python=${pythonVersion} anaconda=${anacondaVersion} ${package_list_default} ${packageNames};
		}
	}
	elseif ( !(${condaForge}) -and (${tensorflow}) ) {
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Python Version: ${pythonVersion}";
			Write-Host "Anaconda Version: ${anacondaVersion} (up-to-date if blank)";
			Write-Host "Installing Packages: anaconda ${package_list_default} ${package_list_tensorflow} ${packageNames}";
			list_conda_channel;
 		}
		if ( [string]::IsNullOrEmpty(${anacondaVersion} ) ) {
		conda create --name ${environmentName} python=${pythonVersion} anaconda ${package_list_default} ${package_list_tensorflow} ${packageNames};
		}
		else{
		conda create --name ${environmentName} python=${pythonVersion} anaconda=${anacondaVersion} ${package_list_default} ${package_list_tensorflow} ${packageNames};
		}
	}
	elseif ( (${condaForge}) -and (${tensorflow}) ) {
		conda config --append channels conda-forge;
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Python Version: ${pythonVersion}";
			Write-Host "Anaconda Version: ${anacondaVersion} (up-to-date if blank)";
			Write-Host "Installing Packages: anaconda ${package_list_default} ${packageNames} ${package_list_tensorflow} ${package_list_conda_forge}";
			list_conda_channel;
 		}
		if ( [string]::IsNullOrEmpty(${anacondaVersion} ) ) {
		conda create --name ${environmentName} python=${pythonVersion} anaconda ${package_list_default} ${package_list_default} ${package_list_tensorflow} ${package_list_conda_forge} ${packageNames};
		}
		else{
		conda create --name ${environmentName} python=${pythonVersion} anaconda=${anacondaVersion} ${package_list_default} ${package_list_tensorflow} ${package_list_conda_forge} ${packageNames};
		}
		conda config --remove channels conda-forge;
	} 
	else { #condaForge yes, tensorflow no
		conda config --append channels conda-forge;
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Python Version: ${pythonVersion}";
			Write-Host "Anaconda Version: ${anacondaVersion} (up-to-date if blank)";
			Write-Host "Installing Packages: anaconda ${package_list_default} ${packageNames} ${package_list_conda_forge}";
			list_conda_channel;
 		}
		if ( [string]::IsNullOrEmpty(${anacondaVersion} ) ){
			conda create --name ${environmentName} python=${pythonVersion} anaconda ${package_list_default} ${package_list_conda_forge} ${packageNames};
		}
		else{
			conda create --name ${environmentName} python=${pythonVersion} anaconda=${anacondaVersion} ${package_list_default} ${package_list_conda_forge} ${packageNames};
		}
		conda config --remove channels conda-forge;
	}

	if ( ${verboseOutput} ){
		conda_clean -verboseOutput;
	}
	else {
		conda_clean;
	}

}
Export-ModuleMember -Function create_conda_environment; 





function install_conda_environment {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: install_conda_environment description.
	#>
	Param(
		[Parameter(Mandatory=$true, Position=0)]
		[string]$environmentName,
		[Parameter(Mandatory=$false, Position=1)]
		[string]$pythonVersion="3.6",
		[Parameter(Mandatory=$false, Position=2)]
		[string]$anacondaVersion,
		[Parameter(Mandatory=$false, Position=3)]
		[string]$packageNames,
		[switch]$condaForge,
		[switch]$tensorflow,
		[switch]$verboseOutput
	)

	if ( ${verboseOutput} ){
		conda_update -verboseOutput;
	}
	else {
		conda_update;
	}

	. "${PSScriptRoot}/conda_package_list.ps1"; #load default package lists
	if ( ${verboseOutput} ){
		Write-Host "Default channel only packages: ${package_list_default}";
		Write-Host "Conda-Forge additional packages: ${package_list_conda_forge}";
		Write-Host "tensorflow additional packages: ${package_list_tensorflow}";
		Write-Host "User defined packages: ${packageNames}";
	}


	if ( !(${condaForge}) -and !(${tensorflow}) ) {
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Python Version: ${pythonVersion}";
			Write-Host "Anaconda Version: ${anacondaVersion} (up-to-date if blank)";
			Write-Host "Installing Packages: anaconda ${package_list_default} ${packageNames}";
			list_conda_channel;
 		}

		if ( [string]::IsNullOrEmpty(${anacondaVersion} ) ) {
		conda install --name ${environmentName} python=${pythonVersion} anaconda ${package_list_default} ${packageNames};
		}
		else{
		conda install --name ${environmentName} python=${pythonVersion} anaconda=${anacondaVersion} ${package_list_default} ${packageNames};
		}
	}
	elseif ( !(${condaForge}) -and (${tensorflow}) ) {
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Python Version: ${pythonVersion}";
			Write-Host "Anaconda Version: ${anacondaVersion} (up-to-date if blank)";
			Write-Host "Installing Packages: anaconda ${package_list_default} ${package_list_tensorflow} ${packageNames}";
			list_conda_channel;
 		}
		if ( [string]::IsNullOrEmpty(${anacondaVersion} ) ) {
		conda install --name ${environmentName} python=${pythonVersion} anaconda ${package_list_default} ${package_list_tensorflow} ${packageNames};
		}
		else{
		conda install --name ${environmentName} python=${pythonVersion} anaconda=${anacondaVersion} ${package_list_default} ${package_list_tensorflow} ${packageNames};
		}
	}
	elseif ( (${condaForge}) -and (${tensorflow}) ) {
		conda config --append channels conda-forge;
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Python Version: ${pythonVersion}";
			Write-Host "Anaconda Version: ${anacondaVersion} (up-to-date if blank)";
			Write-Host "Installing Packages: anaconda ${package_list_default} ${packageNames} ${package_list_tensorflow} ${package_list_conda_forge}";
			list_conda_channel;
 		}
		if ( [string]::IsNullOrEmpty(${anacondaVersion} ) ) {
		conda install --name ${environmentName} python=${pythonVersion} anaconda ${package_list_default} ${package_list_default} ${package_list_tensorflow} ${package_list_conda_forge} ${packageNames};
		}
		else{
		conda install --name ${environmentName} python=${pythonVersion} anaconda=${anacondaVersion} ${package_list_default} ${package_list_tensorflow} ${package_list_conda_forge} ${packageNames};
		}
		conda config --remove channels conda-forge;
	} 
	else { #condaForge yes, tensorflow no
		conda config --append channels conda-forge;
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Python Version: ${pythonVersion}";
			Write-Host "Anaconda Version: ${anacondaVersion} (up-to-date if blank)";
			Write-Host "Installing Packages: anaconda ${package_list_default} ${packageNames} ${package_list_conda_forge}";
			list_conda_channel;
 		}
		if ( [string]::IsNullOrEmpty(${anacondaVersion} ) ){
			conda install --name ${environmentName} python=${pythonVersion} anaconda ${package_list_default} ${package_list_conda_forge} ${packageNames};
		}
		else{
			conda install --name ${environmentName} python=${pythonVersion} anaconda=${anacondaVersion} ${package_list_default} ${package_list_conda_forge} ${packageNames};
		}
		conda config --remove channels conda-forge;
	}

	if ( ${verboseOutput} ){
		conda_clean -verboseOutput;
	}
	else {
		conda_clean;
	}

}
Export-ModuleMember -Function install_conda_environment; 





function install_conda_package {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: install_conda_package description.
	#>
	Param(
		[Parameter(Mandatory=$true, Position=0)]
		[string]$environmentName,
		[Parameter(Mandatory=$false, Position=1)]
		[string]$packageNames,
		[switch]$condaForge,
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
		conda_update -verboseOutput;
	}
	else {
		conda_update;
	}

	if ( !(${condaForge}) ) {
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Additional Package to Install: ${packageNames}";
			list_conda_channel;
		}
		conda install --name ${environmentName} ${packageNames};
	}
	else{
		conda config --append channels conda-forge;
		if ( ${verboseOutput} ){
			Write-Host "environmentName: ${environmentName}";
			Write-Host "Additional Package to Install: ${packageNames}";
			list_conda_channel;
 		}
		conda install --name ${environmentName} ${packageNames};
		conda config --remove channels conda-forge;
	}

	if ( ${verboseOutput} ){
		conda_clean -verboseOutput;
	}
	else {
		conda_clean;
	}
}
Export-ModuleMember -Function install_conda_package; 





function list_conda_channel {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: list_conda_channel description
	#>
	Param(
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
		Write-Host "---------------------------------------------------------------";
		Write-Host "-----------------------List of Channels------------------------";
		Write-Host "---------------------------------------------------------------";
	}
	conda config --get channels;
}
Export-ModuleMember -Function list_conda_channel; 





function list_conda_environment {
	<#
	.Synopsis
	synopsis.
	#>
	<#
	.Description
	get_anaconda :: list_conda_environment description.
	#>
	Param(
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
		Write-Host "---------------------------------------------------------------";
		Write-Host "----------------------List of Environments---------------------";
		Write-Host "---------------------------------------------------------------";
	}
	conda info --envs;
}
Export-ModuleMember -Function list_conda_environment; 





function list_conda_package {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: list_conda_package description.
	#>
	Param(
		[ Parameter(Mandatory=$true, Position=0) ]
		[string]$environmentName,
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
		Write-Host "---------------------------------------------------------------";
		Write-Host "------------List of Packages in $environmentName---------------";
		Write-Host "---------------------------------------------------------------";
	}
	conda list --name $environmentName;
}
Export-ModuleMember -Function list_conda_package; 





function remove_conda_channel {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: remove_conda_channel description.
	#>
	Param(
		[ Parameter(Mandatory=$true, Position=0) ]
		[string]$channelName,
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
		Write-Host "Removing conda channel: ${channelName}";
	}
	conda config --remove channels ${channelName};
}
Export-ModuleMember -Function remove_conda_channel; 





function remove_conda_environment {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: remove_conda_environment description.
	#>
	Param(
		[ Parameter(Mandatory=$true, Position=0) ]
		[string]$environmentName,
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
		Write-Host "Removing Environment: ${environmentName}";
		Write-Host "Environment (${environmentName}) has following packages.";
		list_conda_package -environmentName ${environmentName} -verboseOutput;
	}
	conda remove --name $environmentName --all;
}
Export-ModuleMember -Function remove_conda_environment; 





function remove_conda_package {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: remove_conda_package description.
	#>
	Param(
		[ Parameter(Mandatory=$true, Position=0) ]
		[string]$environmentName,
		[ Parameter(Mandatory=$true, Position=1) ]
		[string]$packageName,
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
			Write-Host "From Environment: ${environmentName}";
			Write-Host "Removing Package: ${packageName}";
	}
	conda remove --name ${environmentName} ${packageName};
}
Export-ModuleMember -Function remove_conda_package; 





function update_conda_environment {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: update_conda_environment description.
	#>
	Param(
		[ Parameter(Mandatory=$true, Position=0) ]
		[string]${environmentName},
		[Parameter(Mandatory=$false, Position=1)]
		[string]${packageNames},
		[Parameter(Mandatory=$false, Position=2)]
		[switch]${condaForge},
		[Parameter(Mandatory=$false, Position=3)]
		[switch]${tensorflow},
    [Parameter(Mandatory=$false, Position=4)]
    [switch]${noConfirmation},
		[Parameter(Mandatory=$false, Position=5)]
		[switch]${verboseOutput},
		[Parameter(Mandatory=$false, Position=6)]
		[switch]${quietOutput},
		[Parameter(Mandatory=$false, Position=7)]
		[switch]${debugOutput}
	)

  if ( ${verboseOutput} -and ${quietOutput} ){
    Write-Output "verboseOutput flag and quietOutput flag cannot both be set at the same time.";
    return;
  }

  if ( ${debugOutput} -and ${quietOutput} ){
    Write-Output "debugOutput flag and quietOutput flag cannot both be set at the same time.";
    return;
  }

  #update conda first
	if ( ${noConfirmation} ){
		conda_update -noConfirmation;
	}
	else {
		conda_update;
	}

	if ( ${verboseOutput} ){
			Write-Output "Updating packages in environment: ${environmentName}";
	}

	. "${PSScriptRoot}/conda_package_list.ps1"; #load default package lists

	if ( ${verboseOutput} ){
    Write-Output "`n";
		Write-Output "Default channel only packages: ${package_list_default}";
		Write-Output "Conda-Forge additional packages: ${package_list_conda_forge}";
		Write-Output "tensorflow additional packages: ${package_list_tensorflow}";
    Write-Output "`n";
	}

  #populate arguments
  ${full_package_names} = " anaconda ${package_list_default} ${packageNames}";

  if ( ${condaForge} ){
    ${full_package_names} = "${full_package_names} ${package_list_conda_forge}";
  }

  if ( ${tensorflow} ){
    ${full_package_names} = "${full_package_names} ${package_list_tensorflow}";
  }

  ${extra_arguments} = "";
	if ( ${verboseOutput} ){
    ${extra_arguments} = "${extra_arguments} --verbose";
  }

	if ( ${noConfirmation} ){
    ${extra_arguments} = "${extra_arguments} --yes";
  }

	if ( ${debugOutput} ){
    ${extra_arguments} = "${extra_arguments} --debug";
  }

	if ( ${quietOutput} ){
    ${extra_arguments} = "${extra_arguments} --quiet";
  }


	if ( ${verboseOutput} ){
    Write-Output "`n";
		Write-Output "environmentName:`t${environmentName}";
		Write-Output "Package Names:`t${full_package_names}";
    Write-Output "extra arguments:`t${extra_arguments}";
    Write-Output "`n";
    list_conda_channel;
    Write-Output "`n";
  }

  if (${condaForge}){
		conda config --append channels conda-forge;
  }

  ${full_command} = "conda update --name ${environmentName} ${full_package_names} ${extra_arguments}";
  if (${verboseOutput}){
    Write-Output "${full_command}";
  }
  Invoke-Expression "${full_command}";

  if (${condaForge}){
		conda config --remove channels conda-forge;
  }

	#if ( !(${condaForge}) -and !(${tensorflow}) ) {
	#	if ( ${verboseOutput} ){
	#		Write-Host "environmentName: ${environmentName}";
	#		Write-Host "Package Names ${package_list_default} ${packageNames}";
	#		list_conda_channel;
 #		}
	#	conda update --name ${environmentName} anaconda ${package_list_default} ${packageNames};
	#}
	#elseif ( !(${condaForge}) -and (${tensorflow}) ) {
	#	if ( ${verboseOutput} ){
	#		Write-Host "environmentName: ${environmentName}";
	#		Write-Host "Package Names ${package_list_default} ${package_list_tensorflow}";
	#		list_conda_channel;
 #		}
	#	conda update --name ${environmentName} anaconda ${package_list_default} ${packageNames} ${package_list_tensorflow};
	#}
	#elseif ( (${condaForge}) -and (${tensorflow}) ) {
	#	conda config --append channels conda-forge;
	#	if ( ${verboseOutput} ){
	#		Write-Host "environmentName: ${environmentName}";
	#		Write-Host "Package Names ${package_list_default} ${package_list_tensorflow} ${package_list_conda_forge}";
	#		list_conda_channel;
 #		}
	#	conda update --name ${environmentName} anaconda ${package_list_default} ${packageNames} ${package_list_tensorflow} ${package_list_conda_forge};
	#	conda config --remove channels conda-forge;
	#}
	#else { #condaForge yes, tensorflow no
	#	conda config --append channels conda-forge;
	#	if ( ${verboseOutput} ){
	#		Write-Host "environmentName: ${environmentName}";
	#		Write-Host "Package Names ${package_list_default} ${packageNames} ${package_list_conda_forge}";
	#		list_conda_channel;
	#	}
	#	conda update --name ${environmentName} anaconda ${package_list_default} ${package_list_conda_forge} ${packageNames};
	#	conda config --remove channels conda-forge;
	#}

	if ( ${verboseOutput} ){
		conda_clean -verboseOutput -packages -noConfirmation;
	}
	else {
		conda_clean -packages -noConfirmation;
	}
}
Export-ModuleMember -Function update_conda_environment;





function update_conda_package {
	<#
	.Synopsis
	synopsis
	#>
	<#
	.Description
	get_anaconda :: update_conda_package description.
	#>
	Param(
		[ Parameter(Mandatory=$true, Position=0) ]
		[string]$environmentName,
		[Parameter(Mandatory=$true, Position=1)]
		[string]$packageNames,
		[switch]$condaForge,
		[switch]$verboseOutput
	)
	if ( ${verboseOutput} ){
		conda_update -verboseOutput;
	}
	else {
		conda_update;
	}

	if ( ${verboseOutput} ){
			Write-Host "Updating environment: ${environmentName}";
			Write-Host "Updating package: ${packageNames}";
	}

	if ( !(${condaForge}) ) {
		conda update --name ${environmentName} ${packageNames};
	}
	else {
		conda config --append channels conda-forge;
		conda update --name ${environmentName} ${packageNames};
		conda config --remove channels conda-forge;
	}

	if ( ${verboseOutput} ){
		conda_clean -verboseOutput;
	}
	else {
		conda_clean;
	}
}
Export-ModuleMember -Function update_conda_package;


###########################################
#####End Statistics
###########################################

$end_time = $(Get-Date);
$end_time_string = "{0:HH:mm:ss.fffffff}" -f ([datetime]$end_time.Ticks);
$elapsed_time = New-TimeSpan ${start_time} ${end_time};


if ( -not ${silentOutputScript} ){
	Write-Host "`n";
	Write-Host "-----------------------------------------------------------------------";
	Write-Host "Script Dir:`t${current_script_dir}";
	Write-Host "Script Name:`t${current_script_name}";
	Write-Host "Version:`t${version}";
	Write-Host "Script PID:`t${current_pid}";
	Write-Host "Script PWD:`t${current_pwd}";
	Write-Host "Script Start Time:`t${start_time_string}";
	Write-Host "Script End Time:`t${end_time_string}";
	Write-Host "Script Elapsed Time:`t${elapsed_time}";
	Write-Host "-----------------------------------------------------------------------";
	Write-Host "--------------------------------End------------------------------------";
	Write-Host "-----------------------------------------------------------------------";
	Write-Host "`n";
}