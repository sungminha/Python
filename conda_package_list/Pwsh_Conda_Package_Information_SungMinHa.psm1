###########################
####Variables
###########################

###########################
##### Functions - Parent Functions
###########################
function Get-CallerPreference {
  <#
  .Synopsis
      Fetches "Preference" variable values from the caller's scope.
  .DESCRIPTION
      Script module functions do not automatically inherit their caller's variables, but they can be
      obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
      for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
      and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
  .PARAMETER Cmdlet
      The $PSCmdlet object from a script module Advanced Function.
  .PARAMETER SessionState
      The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
      Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
      script module.
  .PARAMETER Name
      Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
      Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
      This parameter may also specify names of variables that are not in the about_Preference_Variables
      help file, and the function will retrieve and set those as well.
  .EXAMPLE
      Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

      Imports the default PowerShell preference variables from the caller into the local scope.
  .EXAMPLE
      Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

      Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
  .EXAMPLE
      'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

      Same as Example 2, but sends variable names to the Name parameter via pipeline input.
  .INPUTS
      String
  .OUTPUTS
      None.  This function does not produce pipeline output.
  .LINK
      about_Preference_Variables
  #>

  [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
  param (
      [Parameter(Mandatory = $true)]
      [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
      $Cmdlet,

      [Parameter(Mandatory = $true)]
      [System.Management.Automation.SessionState]
      $SessionState,

      [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
      [string[]]
      $Name
  )

  begin
  {
      $filterHash = @{}
  }
    
  process
  {
      if ($null -ne $Name)
      {
          foreach ($string in $Name)
          {
              $filterHash[$string] = $true
          }
      }
  }

  end
  {
      # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

      $vars = @{
          'ErrorView' = $null
          'FormatEnumerationLimit' = $null
          'LogCommandHealthEvent' = $null
          'LogCommandLifecycleEvent' = $null
          'LogEngineHealthEvent' = $null
          'LogEngineLifecycleEvent' = $null
          'LogProviderHealthEvent' = $null
          'LogProviderLifecycleEvent' = $null
          'MaximumAliasCount' = $null
          'MaximumDriveCount' = $null
          'MaximumErrorCount' = $null
          'MaximumFunctionCount' = $null
          'MaximumHistoryCount' = $null
          'MaximumVariableCount' = $null
          'OFS' = $null
          'OutputEncoding' = $null
          'ProgressPreference' = $null
          'PSDefaultParameterValues' = $null
          'PSEmailServer' = $null
          'PSModuleAutoLoadingPreference' = $null
          'PSSessionApplicationName' = $null
          'PSSessionConfigurationName' = $null
          'PSSessionOption' = $null

          'ErrorActionPreference' = 'ErrorAction'
          'DebugPreference' = 'Debug'
          'ConfirmPreference' = 'Confirm'
          'WhatIfPreference' = 'WhatIf'
          'VerbosePreference' = 'Verbose'
          'WarningPreference' = 'WarningAction'
      }


      foreach ($entry in $vars.GetEnumerator())
      {
          if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
              ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name)))
          {
              $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
              if ($null -ne $variable)
              {
                  if ($SessionState -eq $ExecutionContext.SessionState)
                  {
                      Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                  }
                  else
                  {
                      $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                  }
              }
          }
      }

      if ($PSCmdlet.ParameterSetName -eq 'Filtered')
      {
          foreach ($varName in $filterHash.Keys)
          {
              if (-not $vars.ContainsKey($varName))
              {
                  $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                  if ($null -ne $variable)
                  {
                      if ($SessionState -eq $ExecutionContext.SessionState)
                      {
                          Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                      }
                      else
                      {
                          $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                      }
                  }
              }
          }
      }

  } # end
}

###########################
####Functions
###########################

#export conda environment as yml or txt
function Export-CondaEnvironmentInformation {
  <#
  .Synopsis

  Export Conda Package List as YML file or txt file.

  .Description

  Export Conda Package List as YML file in the directory you provide (the file name will be determined by computer name, user name, and current date time.) for the conda environment name you provide.

  .Parameter EnvironmentName

  By default, will check base environment if none provided.

  .Parameter OutputType

  Choose between yml file or txt file. If you want to clone an environment, yml would be better. If you want to replicate or update an existing environment using another reference, use txt file.

  #>
  [CmdletBinding()]
	Param(
    [Parameter(Mandatory = ${true}, Position = 0 )]
    [string]${EnvironmentName} = "base", 
    [Parameter(Mandatory = ${true}, Position = 1 )]
    [ ValidateSet( "yml", "txt" ) ]
    [string]${OutputType} = "yml",
    [Parameter(Mandatory = ${true}, Position = 2 )]
    [string]${OutputDirectory}
  )
  
  Get-CallerPreference -Cmdlet ${PSCmdlet} -SessionState (${ExecutionContext}.SessionState);

  Write-Verbose "Checking availability of conda executable.";
  ${exe_name} = "conda";
  if (${IsLinux}){
    ${exe_name} = "conda";
  }
  Else (${IsWindows}){
    ${exe_name} = "conda.exe";
  }
  
  if ( -not (Get-Command "${exe_name}" -ErrorAction SilentlyContinue) ){ 
    #conda is not available, exit
    Write-Error "conda does not exist. Exit function.";
    return;
  }

  Write-Verbose "Checking Whether output directory (${OutputDirectory}) exists.";
  if ( -not (Test-Path -Path "${OutputDirectory}" ) ){
    Write-Error "OutputDirectory (${OutputDirectory}) does not exist. Exit function.";
    return;
  }

  #get current datetime
  ${CurrentDateTime} = [string]( $(Get-Date -Format "yyyyMMdd_HHmmss") );#20000101_130159 format

  ${outputFullPath} = "${OutputDirectory}\${ENV:COMPUTERNAME}_${ENV:USERNAME}_${EnvironmentName}_${CurrentDateTime}.${OutputType}";

  If ( "${OutputType}" -eq "yml" ){
    conda env export --name "${EnvironmentName}" > "${outputFullPath}";
    Write-Verbose "Conda Environment Information exported to (${outputFullPath}).";
    Write-Verbose "You can create a new environment that is an exact copy by using command `"conda env create -f ${outputFullPath}`".";
  }
  Elseif ( "${OutputType}" -eq "txt" ){
    conda list --explicit --name "${EnvironmentName}" > "${outputFullPath}";
    Write-Verbose "Conda Environment Information exported to (${outputFullPath}).";
    Write-Verbose "You can create a new environment that is an exact copy by using command `"conda create --name myenv --file ${outputFullPath}`".";
    Write-Verbose "You can update an existing environment that is an exact copy by using command `"conda install --name myenv --file ${outputFullPath}`".";
  }
}

###########################
####Exports
###########################
Export-ModuleMember -Function Export-CondaEnvironmentInformation;