<#

.SYNOPSIS

.DESCRIPTION

.PARAMETER target

.PARAMETER options

.EXAMPLE

.NOTES

#>
param (
    [Parameter(Mandatory=$true)][string] $target
 )

$options = ""
$smtpServer="mail.altercareonline.net"
$from = "NOREPLY - IT Support <no-reply@altercareonline.net>"
$Recipient = "justin.herman@altercareonline.net"

if ( Test-Path baselinescan.xml ) {
    Write-Host "<<< Creating delta scan. >>>"
    Invoke-Expression "& nmap $target $options -oX deltascan.xml --system-dns" > $null

    $ndiff = (ndiff baselinescan.xml deltascan.xml) | Out-String

    $ndiff.TrimEnd() > ndiff.txt

    $filtered = Get-Content .\ndiff.txt | select-string -pattern "Nmap" -NotMatch

    if ( $filtered -ne $null) {
        write-host "<<< Changes found in delta vs baseline. Sending Email. >>>" -ForegroundColor Yellow
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $recipient -subject "NMap Changes found" -body $ndiff -priority High -UseSsl 
    } else {
        Write-Host "<<< No changes in delta scan vs. baseline. Closing. >>>" -ForegroundColor Green
    }

    Remove-Item .\ndiff.txt

    Remove-Item baselinescan.xml 
    Rename-Item deltascan.xml baselinescan.xml
} else {
    Write-Host "Creating First Baseline Scan"
    Invoke-Expression "& nmap $target $options -oX baselinescan.xml --system-dns" > $null
}
