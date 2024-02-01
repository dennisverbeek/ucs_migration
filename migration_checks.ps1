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

#Checking supported servers
Write-Host "Checking supported servers "

# Define the list of supported models
$supportedModels = @("UCSB-B200-M3", "UCSB-B200-M4", "UCSB-B200-M5", "UCSC-C220-M3", "UCSC-C220-M4", "UCSC-C240-M3S", "UCSC-C220-M5SX", "UCSC-C240-M4SX","UCSC-C240-M5S")

# Retrieve all servers and their models
$servers = Get-UcsServer | Select-Object Model

# Initialize a hashtable to keep track of unsupported models and their counts
$unsupportedModels = @{}

# Loop through the list of servers to identify unsupported models
foreach ($server in $servers) {
    if (-not ($supportedModels -contains $server.Model)) {
        # Increment the count for the unsupported model
        if ($unsupportedModels.ContainsKey($server.Model)) {
            $unsupportedModels[$server.Model]++
        } else {
            $unsupportedModels[$server.Model] = 1
        }
    }
}

# Output summary of unsupported models
if ($unsupportedModels.Count -gt 0) {
    Write-Host "Summary of unsupported server models:"
    foreach ($model in $unsupportedModels.Keys) {
        Write-Host "$model $($unsupportedModels[$model]) instances found" -ForegroundColor Red
    }
} else {
    Write-Host "No unsupported server models found." -ForegroundColor Green
}


#Checking IOM
Write-Host "Checking supported IOM "

# Define the list of supported models
$supportediomModels = @("UCS-IOM-2208XP", "UCS-IOM-2204XP", "N2K-C2232PP-10GE")

# Retrieve all servers and their models
$iom =  get-ucsiom | Select-Object model

# Initialize a hashtable to keep track of unsupported models and their counts
$unsupportediomModels = @{}

# Loop through the list of servers to identify unsupported models
foreach ($iom in $iom) {
    if (-not ($supportediomModels -contains $iom.Model)) {
        # Increment the count for the unsupported model
        if ($unsupportediomModels.ContainsKey($iom.Model)) {
            $unsupportediomModels[$iom.Model]++
        } else {
            $unsupportediomModels[$iom.Model] = 1
        }
    }
}

# Output summary of unsupported models
if ($unsupportediomModels.Count -gt 0) {
    Write-Host "Summary of unsupported IOM modules:"
    foreach ($model in $unsupportediomModels.Keys) {
        Write-Host "$model $($unsupportediomModels[$model]) instances found" -ForegroundColor Red
    }
} else {
    Write-Host "No unsupported server models found." -ForegroundColor Green
}


#Checking Fex
Write-Host "Checking supported FEXES "

# Define the list of supported models
$supportedfexModels = @("N2K-C2232PP-10GE")

# Retrieve all servers and their models
$fex =  get-ucsfex | Select-Object model

# Initialize a hashtable to keep track of unsupported models and their counts
$unsupportedfexModels = @{}

# Loop through the list of servers to identify unsupported models
foreach ($fex in $fex) {
    if (-not ($supportedfexModels -contains $fex.Model)) {
        # Increment the count for the unsupported model
        if ($unsupportedfexModels.ContainsKey($fex.Model)) {
            $unsupportedfexModels[$fex.Model]++
        } else {
            $unsupportedfexModels[$fex.Model] = 1
        }
    }
}

# Output summary of unsupported models
if ($unsupportedfexModels.Count -gt 0) {
    Write-Host "Summary of unsupported FEX Models:"
    foreach ($model in $unsupportedfexModels.Keys) {
        Write-Host "$model $($unsupportedfexModels[$model]) instances found" -ForegroundColor Red
    }
} else {
    Write-Host "No unsupported server models found." -ForegroundColor Green
}


#Checking VIC
Write-Host "Checking supported Network Adapters "

# Define the list of supported models
$supportedadapterModels = @("UCSB-MLOM-40G-01", "UCS-VIC-M82-8P")

# Retrieve all servers and their models
$adapter = Get-UcsAdaptorUnit | select-object model

# Initialize a hashtable to keep track of unsupported models and their counts
$unsupportedadapterModels = @{}

# Loop through the list of servers to identify unsupported models
foreach ($adapter in $adapter) {
    if (-not ($supportedadapterModels -contains $adapter.Model)) {
        # Increment the count for the unsupported adapter model
        if ($unsupportedadapterModels.ContainsKey($adapter.Model)) {
            $unsupportedadapterModels[$adapter.Model]++
        } else {
            $unsupportedadapterModels[$adapter.Model] = 1
        }
    }
}

# Output summary of unsupported models
if ($unsupportedadapterModels.Count -gt 0) {
    Write-Host "Summary of unsupported Adapter Models:"
    foreach ($model in $unsupportedadapterModels.Keys) {
        Write-Host "$model $($unsupportedadapterModels[$model]) instances found" -ForegroundColor Red
    }
} else {
    Write-Host "No unsupported Adapter models found." -ForegroundColor Green
}


# Disconnect from UCS Manager
$null = Disconnect-Ucs
