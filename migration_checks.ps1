# Prompt for UCS Manager address
$ucsManagerAddress = Read-Host -Prompt "Enter UCS Manager Address"

# Prompt for Username
$username = Read-Host -Prompt "Enter your username"

# Prompt for Password securely
$credential = Get-Credential -UserName $username -Message "Enter your password"

# Connect to UCS Manager with the provided credentials
Connect-Ucs -Name $ucsManagerAddress -Credential $credential

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

# Checking Multicast Optimize for each QoS Class, displaying class names and priorities
Write-Host "Checking Multicast Optimize and Priority for each QoS Class"

# Retrieve all QoS Classes with their names, Multicast Optimize setting, and Priority
$qosClasses = Get-UcsQosClass | Select-Object Name, MulticastOptimize, Priority

# Check if any QoS Classes were found
if ($qosClasses) {
    foreach ($qosClass in $qosClasses) {
        # Display the name, Multicast Optimize setting, and Priority of the QoS Class
        Write-Host -NoNewline "Multicast Optimize is set to '$($qosClass.MulticastOptimize)' for Priority: $($qosClass.Priority)... "
        
        # Check the MulticastOptimize property
        if ($qosClass.MulticastOptimize -eq "no") {
            Write-Host ([char]8730) -ForegroundColor Green
        } else {
            Write-Host "X" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No QoS Classes found."
}

# Checking Netflow
Write-Host -NoNewline "Checking Netflow "
$netflow = get-UcsManagedObject -ClassId FabricEthLanFlowMonitoring | Select-Object -ExpandProperty Adminstate

if ($netflow -eq "disabled") {
    Write-Host ([char]8730) -ForegroundColor Green
} else {
    Write-Host "X" -ForegroundColor Red
}

# Begin checking Mac Security
Write-Host "Checking Mac Security"

# Retrieve all port security configurations
$macSecurityConfigs = Get-UcsPortSecurityConfig

# Check if any configurations are returned
if ($macSecurityConfigs) {
    foreach ($config in $macSecurityConfigs) {
        # Display the current port being checked
        Write-Host -NoNewline "Port $($config.Dn) Forge setting is "

        # Check the Forge property
        if ($config.Forge -eq "allow") {
            Write-Host ([char]8730) -ForegroundColor Green
        } else {
            Write-Host "X" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No port security configurations found."
}

# Checking VMM Intergration
Write-Host -NoNewline "Checking VMM Intergration "
$vmmintegration = Get-UcsVmVcenter

if ($null -eq $vmmintegration) {
    Write-Host ([char]8730) -ForegroundColor Green
} else {
    Write-Host "X" -ForegroundColor Red
}

# Checking Dynamic vNIC Connection Policies
Write-Host -NoNewline "Checking Dynamic vNIC Connection Policies "
$dynamicvnic = Get-UcsDynamicVnicConnPolicy

if ($null -eq $dynamicvnic) {
    Write-Host ([char]8730) -ForegroundColor Green
} else {
    Write-Host "X" -ForegroundColor Red
}

# Checking if FC ports are in use
Write-Host -NoNewline "Checking if FC ports are in use "
$fcports = Get-UcsFiFcPort

if ($null -eq $fcports) {
    Write-Host ([char]8730) -ForegroundColor Green
} else {
    Write-Host "X" -ForegroundColor Red
}

# Disconnect from UCS Manager
$null = Disconnect-Ucs
