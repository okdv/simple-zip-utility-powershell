# v1.0.0
param(
    [string]$ZippedPath = "./zipped", # Script scope default path of zip files
    [switch]$IgnoreGlobalZippedPath, # Ignore global scope default path of zip files, if its set
    [string]$UnzippedPath = "./unzipped", # Script scope default path of unzipped files/folders
    [switch]$IgnoreGlobalUnzippedPath, # Ignore global scope default path of unzipped files/folders, if its set
    [string]$Prefix = '', # Prepend string to destination name
    [string]$Suffix = '', # Append string to destination name
    [string]$Name = '', # Override default destination name (uses name of origin by default)
    [switch]$Zip, # To zip or to unzip
    [switch]$Force, # To override or to fail on existing destination  
    [switch]$Open # Open if desired 
)
# Workaround for terminals that dont support progress bar https://github.com/PowerShell/Microsoft.PowerShell.Archive/issues/77
$global:ProgressPreference = "SilentlyContinue"
# Default to global if set and not ignored, otherwise use script scope defaults
$UnzippedPath = If ($global:SimplyUnzippedPath -and !$IgnoreGlobalUnzippedPath) { $global:SimplyUnzippedPath } Else { $UnzippedPath }
$ZippedPath = If ($global:SimplyZippedPath -and !$IgnoreGlobalZippedPath) { $global:SimplyZippedPath } Else { $ZippedPath }
# To zip or to unzip
If ($Zip) {
    $FromPath = $UnzippedPath
    $ToPath = $ZippedPath
}
Else {
    $FromPath = $ZippedPath
    $ToPath = $UnzippedPath
}
# Get most recent object in from path and assign vars from it
$FromObject = Get-ChildItem -Path $FromPath | Sort-Object LastAccessTime -Descending | Select-Object -First 1
$FromObjectName = $FromObject.Name
$FromObjectBasename = $FromObject.Basename
$Name = If ($Name -eq '') { $FromObjectBasename } else { $Name }
# Calculate respective paths
$FromObjectPath = "$($FromPath)/$($FromObjectName)"
$ToObjectName = "$($Prefix)$($Name)$($Suffix)"
$ToObjectPath = "$($ToPath)/$($ToObjectName)"
# To override or to fail on existing destination 
If ($Force) {
    If ($Zip) {
        Compress-Archive -Path $FromObjectPath -DestinationPath $ToObjectPath -Force
    }
    Else {
        Expand-Archive -Path $FromObjectPath -DestinationPath $ToObjectPath -Force
    }

}
Else {
    If ($Zip) {
        Compress-Archive -Path $FromObjectPath -DestinationPath $ToObjectPath 
    }
    Else {
        Expand-Archive -Path $FromObjectPath -DestinationPath $ToObjectPath 
    }
}
# Open if desired 
If ($Open) {
    Invoke-Item $ToPath
}
