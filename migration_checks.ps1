# Connect to UCS Manager
$ucsManagerAddress = "10.192.120.20"
$username = "admin" # Replace with your UCS username
$password = ConvertTo-SecureString "mDY64LQpxow9uFzndPOZ" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($username, $password)

$null = Connect-Ucs -Name $ucsManagerAddress -Credential $credentials -ErrorAction SilentlyContinue

# Checking Swithing mode

Write-Host -NoNewline "Checking Switching mode "

$switchingmode = Get-UcsLanCloud | Select-Object -ExpandProperty Mode

if ($switchingmode -eq "end-host") {
    Write-Host ([char]8730) -ForegroundColor Green
} else {
    Write-Host "X" -ForegroundColor Red
}

# Checking reserved VLANs
Write-Host -NoNewline "Checking reserved VLANs... "
$vlans = Get-UcsVlan | Where-Object {
    ($_.Id -ge 3915 -and $_.Id -le 4042) -or
    ($_.Id -ge 4043 -and $_.Id -le 4047) -or
    ($_.Id -ge 4094 -and $_.Id -le 4095)
}
if ($vlans) {
    Write-Host "X" -ForegroundColor Red
} else {
    Write-Host ([char]8730) -ForegroundColor Green
}

# Checking Link Grouping Preference
Write-Host -NoNewline "Link Grouping Preference is Port-Channel "
$linkAggPref = Get-UcsManagedObject -Dn "org-root/chassis-discovery" | Select-Object -ExpandProperty LinkAggregationPref

if ($linkAggPref -eq "port-channel") {
    Write-Host ([char]8730) -ForegroundColor Green
} else {
    Write-Host "X" -ForegroundColor Red
}

# Checking Multicast Hardware Hash
Write-Host -NoNewline "Checking Multicast Hardware Hash "
$linkAggPref = Get-UcsManagedObject -Dn "org-root/chassis-discovery" | Select-Object -ExpandProperty MulticastHwHash

if ($linkAggPref -eq "disabled") {
    Write-Host ([char]8730) -ForegroundColor Green
} else {
    Write-Host "X" -ForegroundColor Red
}

# Checking Multicast Optimize
Write-Host -NoNewline "Checking Multicast Optimize "
$multicastoptimize = Get-UcsQosClass | select-object MulticastOptimize | Select-Object -ExpandProperty MulticastOptimize

if ($multicastoptimize -eq "no") {
    Write-Host ([char]8730) -ForegroundColor Green
} else {
    Write-Host "X" -ForegroundColor Red
}

# Disconnect from UCS Manager
$null = Disconnect-Ucs
