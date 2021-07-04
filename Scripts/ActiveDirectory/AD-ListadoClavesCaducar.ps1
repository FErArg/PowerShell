Function Get-PasswordExpirationDate {
#requires -Module ActiveDirectory
 
<#
.SYNOPSIS
    Checks to see if the account is X days within password expiration.
    For updated help and examples refer to -Online version.
 
.NOTES
    Name: Get-PasswordExpirationDate
    Version: 2.0
    Author: theSysadminChannel
    DateCreated: 2019-Dec-15
 
.LINK
    https://thesysadminchannel.com/get-password-expiration-date-using-powershell-active-directory -
 
 
 
.PARAMETER DaysWithinExpiration
    Set the number of days you want to check until the password is expired.  Valid options are 1 - 365.
 
.PARAMETER SendEmail
    Send an email to each user that has the EmailAddress populated to notify them that their password is nearning expiration.
 
.PARAMETER SamAccountName
    Specify the user accounts you want to check.  This option does not support the SendEmail or DaysWithinExpiration parameters.
 
.EXAMPLE
    Get-PasswordExpirationDate 15
 
.EXAMPLE
    Get-PasswordExpirationDate -DaysWithinExpiration 10 -SendEmail
 
.EXAMPLE
    Get-PasswordExpirationDate -SamAccountName Username1, username2
 
#>
 
    [CmdletBinding(DefaultParameterSetName="AllAccounts")]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ParameterSetName = "AllAccounts"
        )]
        [ValidateRange(1,365)]
        [int]       $DaysWithinExpiration = 10,
 
 
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "AllAccounts"
        )]
        [switch]    $SendEmail,
 
 
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "SpecificAccounts",
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
            )]
        [string[]]  $SamAccountName
    )
 
    BEGIN {}
 
    PROCESS {
        #Calculating the expired date from the domain's default password policy. -- Do Not Modify --
        $MaxPwdAge   = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
        $expiredDate = (Get-Date).addDays(-$MaxPwdAge)
 
        #Calculating the number of days until you would like to begin notifying the users. -- Do Not Modify --
        $emailDate = (Get-Date).addDays(-($MaxPwdAge - $DaysWithinExpiration))
 
        #Since specific accounts were specified we'll output their password expiration dates regardless if they are within the expiration date
        if ($PSBoundParameters.ContainsKey("SamAccountName")) {
            foreach ($User in $SamAccountName) {
                try {
                    $ADObject = Get-ADUser $User -Properties PasswordNeverExpires, PasswordLastSet, EmailAddress
                    if ($ADObject.PasswordNeverExpires -eq $true) {
                        $DaysUntilExpired = "NeverExpire"
                      } else {
                        $DaysUntilExpired = $ADObject.PasswordLastSet - $ExpiredDate | select -ExpandProperty Days
                    }
                    [PSCustomObject]@{
                        SamAccountName   = $ADObject.samaccountname.toLower()
                        PasswordLastSet  = $ADObject.PasswordLastSet
                        DaysUntilExpired = $DaysUntilExpired
                        EmailAddress     = $ADObject.EmailAddress
                    }
                } catch {
                    Write-Error $_.Exception.Message
                }
            }
        } else {
            $ExpiredAccounts = Get-ADUser -Filter {(PasswordLastSet -lt $EmailDate) -and (PasswordLastSet -gt $ExpiredDate) -and (PasswordNeverExpires -eq $false) -and (Enabled -eq $true)} -Properties PasswordNeverExpires, PasswordLastSet, EmailAddress
            foreach ($ADObject in $ExpiredAccounts) {
                try {
                    $DaysUntilExpired = $ADObject.PasswordLastSet - $ExpiredDate | select -ExpandProperty Days
                    if ($PSBoundParameters.ContainsKey("SendEmail") -and $null -ne $ADObject.EmailAddress) {
                        #Setting up email parameters to send a notification email to the user
                        $From       = "example@thesysadminchannel.com"
                        $Subject    = "Your Password Will Expire in " + $DaysUntilExpired + " days"
                        $Body       = "Hello,`n`nThis email is to notify you that your password will expire in " + $DaysUntilExpired + " days.`n`nPlease consider changing it to avoid any service interruptions.`n`nThank you,`nThe I.T. Department."
                        $smtpServer = "mail.thesysadminchannel.com"
                        #$CC        =  "cc1@thesysadminchannel.com", "cc2@thesysadminchannel.com"
 
                        Send-MailMessage -To $($ADObject.EmailAddress) -From $From -Subject $Subject -BodyAsHtml $Body -SmtpServer $SmtpServer #-Priority High -Cc $CC
                    }
                    [PSCustomObject]@{
                        SamAccountName   = $ADObject.samaccountname.toLower()
                        PasswordLastSet  = $ADObject.PasswordLastSet
                        DaysUntilExpired = $DaysUntilExpired
                        EmailAddress     = $ADObject.EmailAddress
                    }
                } catch {
                    Write-Error $_.Exception.Message
                }
            }
        }
    }
 
    END {}
 
}
