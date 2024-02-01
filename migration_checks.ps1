# Define UCS Manager credentials and address
$ucsManagerAddress = "10.192.120.20"
$username = "admin" # Change this to your UCS username
$password = ConvertTo-SecureString "mDY64LQpxow9uFzndPOZ" -AsPlainText -Force

# Create a PSCredential object
$credentials = New-Object System.Management.Automation.PSCredential($username, $password)

# Connect to UCS Manager
$null = Connect-Ucs -Name $ucsManagerAddress -Credential $credentials -ErrorAction SilentlyContinue

# Retrieve and filter VLANs based on the specified ranges
$vlans = Get-UcsVlan | Where-Object { ($_.Id -ge 3915 -and $_.Id -le 4042) -or ($_.Id -ge 4043 -and $_.Id -le 4047) -or ($_.Id -ge 4094 -and $_.Id -le 4095) }

Write-Host -NoNewline "Checking reserved VLANs... "

# Checking for reserved VLANs
if ($vlans) {
    # If VLANs were found (in use), display a red cross
    Write-Host "X" -ForegroundColor Red
} else {
    # If no VLANs were found (not in use), display a green check
    Write-Host ([char]8730) -ForegroundColor Green
}

# Optionally, disconnect from UCS Manager when done
$null = Disconnect-Ucs
