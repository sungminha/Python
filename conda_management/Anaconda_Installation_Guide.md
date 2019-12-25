# Anaconda Installation Guide

## Config

## Channels

* call `conda config --append channels channelName` to add channels other than default anaconda channel as lower priority than current (default) channels
* call `conda config --prepend channels channelName` to add channels other than default anaconda channel as higher priority than current (default) channels

* My channels list

| Channel Name | Purpose | Reference Link |
| :----------: | :------ | :------------- |
| conda-forge | packages not found in default | |
| pytorch | deep learning module pytorch official repository | |
| tensorflow |  deep learning module tensorflow official repository | |

### Changing default package directory

* call `conda config --add pkgs_dirs /full/path/to/new/directory`
  * Note that you should use `--add` not `--append` because you want to override the default location

### Changing default environment directory

* call `conda config --add envs_dirs /full/path/to/new/directory`
  * Note that you should use `--add` not `--append` because you want to override the default location
  
## Packages

## environments

### Using custom directory for environment location

* use `conda create --prefix /full/path/to/environment` to override the default environment creation directory
* activate using `conda activate /full/path/to/environment`

## Platform Specific

### Windows

#### Using Powershell Core (Powershell 6.x)

1. Under the Anaconda shortcut directory where you find cmd.exe and powershell.exe prompt shortcuts, copy paste the powershell.exe prompt
  1. e.g. `Anaconda Powershell Prompt (Miniconda3)`
1. Right click copied item and click properties
1. Under Shortcut tab, replace the path to powershell.exe in Target with path to pwsh.exe
  1. e.g. `C:\Program Files\PowerShell\6\pwsh.exe`
1. For best color adjustment, go to Terminal tab
  1. Check `Use Separate Foreground`
  1. Put `255` for `Red`, `Green`, and `Blue` fields
  1. Check `Use Separate Background`
  1. Put `0` for `Red`, `Green`, and `Blue` fields

### Linux