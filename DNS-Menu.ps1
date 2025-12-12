
# DNS-Menu.ps1
# Features: IPv4+IPv6, Auto-Interface, Auto-Update, Backup/Restore, Logging

$logFile = "$PSScriptRoot\dns-log.txt"
$backupFile = "$PSScriptRoot\dns-backup.json"

function Get-ActiveInterface {
    (Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1).Name
}

function Log-Action {
    param([string]$message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

function Backup-DNS {
    $iface = Get-ActiveInterface
    $currentDNS = Get-DnsClientServerAddress -InterfaceAlias $iface
    $currentDNS | ConvertTo-Json | Out-File $backupFile
    Log-Action "Backup erstellt für Interface $iface"
    Write-Host "Backup gespeichert: $backupFile"
}

function Restore-DNS {
    if (Test-Path $backupFile) {
        $iface = Get-ActiveInterface
        $dnsData = Get-Content $backupFile | ConvertFrom-Json
        $addresses = $dnsData.ServerAddresses
        Set-DnsClientServerAddress -InterfaceAlias $iface -ServerAddresses $addresses
        Log-Action "DNS wiederhergestellt: $($addresses -join ', ')"
        Write-Host "DNS wiederhergestellt!"
    } else {
        Write-Host "Kein Backup gefunden!"
    }
}

function Set-DNS {
    param([string[]]$Addresses)
    $iface = Get-ActiveInterface
    Set-DnsClientServerAddress -InterfaceAlias $iface -ServerAddresses $Addresses
    Log-Action "DNS gesetzt auf: $($Addresses -join ', ') für $iface"
    Write-Host "DNS erfolgreich gesetzt!"
}

function Update-Script {
    $url = "https://github.com/iceliveone/DNS-Menu/DNS-Menu.ps1"
    Invoke-WebRequest -Uri $url -OutFile "$PSScriptRoot\DNS-Menu.ps1"
    Log-Action "Update von GitHub durchgeführt"
    Write-Host "Update abgeschlossen!"
}

Clear-Host
Write-Host "==============================="
Write-Host "   DNS-Server Auswahl"
Write-Host "==============================="
Write-Host "1) Cloudflare Gaming"
Write-Host "2) Cloudflare Familie"
Write-Host "3) Cloudflare Malware-Block"
Write-Host "4) Google DNS"
Write-Host "5) Quad9 Sicher"
Write-Host "6) Quad9 ECS"
Write-Host "7) Quad9 Unsecured"
Write-Host "B) Backup aktueller DNS"
Write-Host "R) Restore DNS"
Write-Host "U) Update von GitHub"
Write-Host "0) Beenden"
Write-Host "==============================="
$choice = Read-Host "Bitte Auswahl eingeben"

switch ($choice) {
    "1" { $dns = @("1.1.1.1","1.0.0.1","2606:4700:4700::1111","2606:4700:4700::1001") }
    "2" { $dns = @("1.1.1.2","1.0.0.2","2606:4700:4700::1112","2606:4700:4700::1002") }
    "3" { $dns = @("1.1.1.3","1.0.0.3","2606:4700:4700::1113","2606:4700:4700::1003") }
    "4" { $dns = @("8.8.8.8","8.8.4.4","2001:4860:4860::8888","2001:4860:4860::8844") }
    "5" { $dns = @("9.9.9.9","149.112.112.112","2620:fe::fe","2620:fe::9") }
    "6" { $dns = @("9.9.9.11","149.112.112.11","2620:fe::11","2620:fe::fe:11") }
    "7" { $dns = @("9.9.9.10","149.112.112.10","2620:fe::10","2620:fe::fe:10") }
    "B" { Backup-DNS; exit }
    "R" { Restore-DNS; exit }
    "U" { Update-Script; exit }
    "0" { exit }
}

if ($dns) { Set-DNS -Addresses $dns }
