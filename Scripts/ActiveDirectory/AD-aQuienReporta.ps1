#requires -Module ActiveDirectory
    
<#
.SYNOPSIS
    This script will get a user's direct reports recursively from ActiveDirectory unless specified with the NoRecurse parameter.
    It also uses the user's EmployeeID attribute as a way to exclude service accounts and/or non standard accounts that are in the reporting structure.
    
.NOTES
    Name: Get-DirectReport
    Author: theSysadminChannel
    Version: 1.0
    DateCreated: 2020-Jan-28
    
.LINK
    https://thesysadminchannel.com/get-direct-reports-in-active-directory-using-powershell-recursive -  
    
.PARAMETER SamAccountName
    Specify the samaccountname (username) to see their direct reports.
    
.PARAMETER NoRecurse
    Using this option will not drill down further than one level.
    
.EXAMPLE
    Get-DirectReport username
    
.EXAMPLE
    Get-DirectReport -SamAccountName username -NoRecurse
    
.EXAMPLE
    "username" | Get-DirectReport
#>

Function Get-DirectReport {
     
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
    
        [string]  $SamAccountName,
    
        [switch]  $NoRecurse
    )
    
    BEGIN {}
    
    PROCESS {
        $UserAccount = Get-ADUser $SamAccountName -Properties DirectReports, DisplayName
        $UserAccount | select -ExpandProperty DirectReports | ForEach-Object {
            $User = Get-ADUser $_ -Properties DirectReports, DisplayName, Title, EmployeeID
            if ($null -ne $User.EmployeeID) {
                if (-not $NoRecurse) {
                    Get-DirectReport $User.SamAccountName
                }
                [PSCustomObject]@{
                    SamAccountName     = $User.SamAccountName
                    UserPrincipalName  = $User.UserPrincipalName
                    DisplayName        = $User.DisplayName
                    Manager            = $UserAccount.DisplayName
                }
            }
        }
    }
    
    END {}
     
}


Get-DirectReport aval001