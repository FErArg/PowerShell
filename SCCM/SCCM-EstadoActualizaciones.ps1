function Get-SCCMSoftwareUpdateStatus {
    <#
    .Synopsis
        This will output the device status for the Software Update Deployments within SCCM.
        For updated help and examples refer to -Online version.
      
     
    .DESCRIPTION
        This will output the device status for the Software Update Deployments within SCCM.
        For updated help and examples refer to -Online version.
     
     
    .NOTES  
        Name: Get-SCCMSoftwareUpdateStatus
        Author: The Sysadmin Channel
        Version: 1.0
        DateCreated: 2018-Nov-10
        DateUpdated: 2018-Nov-10
     
    .LINK
        https://thesysadminchannel.com/get-sccm-software-update-status-powershell -
     
     
    .EXAMPLE
        For updated help and examples refer to -Online version.
     
    #>
     
        [CmdletBinding()]
     
        param(
            [Parameter()]
            [switch]  $DeploymentIDFromGUI,
     
            [Parameter(Mandatory = $false)]
            [Alias('ID', 'AssignmentID')]
            [string]   $DeploymentID,
             
            [Parameter(Mandatory = $false)]
            [ValidateSet('Success', 'InProgress', 'Error', 'Unknown')]
            [Alias('Filter')]
            [string]  $Status
     
     
        )
     
        BEGIN {
            $Site_Code   = 'PAC'
            $Site_Server = 'PAC-SCCM01'
            $HasErrors   = $False
     
            if ($Status -eq 'Success') {
                $StatusType = 1
            }
     
            if ($Status -eq 'InProgress') {
                $StatusType = 2
            }
     
            if ($Status -eq 'Unknown') {
                $StatusType = 4
            }
     
            if ($Status -eq 'Error') {
                $StatusType = 5
            }
     
        }
     
        PROCESS {
            try {
                if ($DeploymentID -and $DeploymentIDFromGUI) {
                    Write-Error "Select the DeploymentIDFromGUI or DeploymentID Parameter. Not Both"
                    $HasErrors   = $True
                    throw
                }
     
                if ($DeploymentIDFromGUI) {
                    $ShellLocation = Get-Location
                    Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
                     
                    #Checking to see if module has been imported. If not abort.
                    if (Get-Module ConfigurationManager) {
                            Set-Location "$($Site_Code):\"
                            $DeploymentID = Get-CMSoftwareUpdateDeployment | select AssignmentID, AssignmentName | Out-GridView -OutputMode Single -Title "Select a Deployment and Click OK" | Select -ExpandProperty AssignmentID
                            Set-Location $ShellLocation
                        } else {
                            Write-Error "The SCCM Module wasn't imported successfully. Aborting."
                            $HasErrors   = $True
                            throw
                    }
                }
     
                if ($DeploymentID) {
                        $DeploymentNameWithID = Get-WMIObject -ComputerName $Site_Server -Namespace root\sms\site_$Site_Code -class SMS_SUMDeploymentAssetDetails -Filter "AssignmentID = $DeploymentID" | select AssignmentID, AssignmentName
                        $DeploymentName = $DeploymentNameWithID.AssignmentName | select -Unique
                    } else {
                        Write-Error "A Deployment ID was not specified. Aborting."
                        $HasErrors   = $True
                        throw  
                }
     
                if ($Status) {
                       $Output = Get-WMIObject -ComputerName $Site_Server -Namespace root\sms\site_$Site_Code -class SMS_SUMDeploymentAssetDetails -Filter "AssignmentID = $DeploymentID and StatusType = $StatusType" | `
                        select DeviceName, CollectionName, @{Name = 'StatusTime'; Expression = {$_.ConvertToDateTime($_.StatusTime) }}, @{Name = 'Status' ; Expression = {if ($_.StatusType -eq 1) {'Success'} elseif ($_.StatusType -eq 2) {'InProgress'} elseif ($_.StatusType -eq 5) {'Error'} elseif ($_.StatusType -eq 4) {'Unknown'}  }}
     
                    } else {      
                        $Output = Get-WMIObject -ComputerName $Site_Server -Namespace root\sms\site_$Site_Code -class SMS_SUMDeploymentAssetDetails -Filter "AssignmentID = $DeploymentID" | `
                        select DeviceName, CollectionName, @{Name = 'StatusTime'; Expression = {$_.ConvertToDateTime($_.StatusTime) }}, @{Name = 'Status' ; Expression = {if ($_.StatusType -eq 1) {'Success'} elseif ($_.StatusType -eq 2) {'InProgress'} elseif ($_.StatusType -eq 5) {'Error'} elseif ($_.StatusType -eq 4) {'Unknown'}  }}
                }
     
                if (-not $Output) {
                    Write-Error "A Deployment with ID: $($DeploymentID) is not valid. Aborting"
                    $HasErrors   = $True
                    throw
                     
                }
     
            } catch {
                 
             
            } finally {
                if (($HasErrors -eq $false) -and ($Output)) {
                    Write-Output ""
                    Write-Output "Deployment Name: $DeploymentName"
                    Write-Output "Deployment ID:   $DeploymentID"
                    Write-Output ""
                    Write-Output $Output | Sort-Object Status
                }
            }
        }
     
        END {}
     
    }