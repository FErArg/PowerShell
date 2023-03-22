Function Restart-SCCMSyncCycle {
    <#
    .Synopsis
        Remotely restarts sccm service cycles.
     
     
    .DESCRIPTION
        This function restarts all sccm policies on a remote client so that the client can immediately get any pending software updates or inventory.
     
     
    .NOTES  
        Name: Restart-SCCMSyncCycle
        Author: theSysadminChannel
        Version: 1
        DateCreated: 2017-02-09
     
     
    .LINK
        https://thesysadminchannel.com/remotely-restart-sccmsynccycle-using-powershell -
     
     
    .PARAMETER ComputerName
        The computer to which connectivity will be checked
     
     
    .EXAMPLE
        Restart-SCCMSyncCycle -Computername Pactest-1
     
        Description:
        Will restart all sccm services on a remote machine.
     
    .EXAMPLE
        Restart-SCCMSyncCycle -ComputerName pactest-1, pactest-2, pactest-3
     
        Description:
        Will generate a list of installed programs on pactest-1, pactest-2 and pactest-3
     
    #>
     
     
        [CmdletBinding()]
            param(
                [Parameter(
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
                [string[]] $ComputerName = $env:COMPUTERNAME
     
            )
     
        Foreach ($Computer in $ComputerName ) {
            try {
     
                Write-Host "====================================================================="
                Write-Output "$Computer : Machine Policy Evaluation Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}" -ErrorAction Stop | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : Application Deployment Evaluation Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : Discovery Data Collection Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : File Collection Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000010}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : Hardware Inventory Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : Machine Policy Retrieval Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : Software Inventory Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : Software Metering Usage Report Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000031}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : Software Update Deployment Evaluation Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000114}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                #Write-Output "$Computer : Software Update Scan Cycle"
                #Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : State Message Refresh"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000111}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                #Write-Output "$Computer : User Policy Retrieval Cycle"
                #Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000026}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                #Write-Output "$Computer : User Policy Evaluation Cycle"
                #Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000027}" | select -ExpandProperty PSComputerName | Out-Null
     
     
                Write-Output "$Computer : Windows Installers Source List Update Cycle"
                Invoke-WMIMethod -ComputerName $Computer -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000032}" | select -ExpandProperty PSComputerName | Out-Null
     
                sleep 1
            }
     
            catch {
                Write-Host $Computer.toUpper() "is not online" -ForegroundColor:Red
                Write-Host
                Write-Host
     
            }
        }
    }