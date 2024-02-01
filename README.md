# UCS Migration pre-check from UCS FI 6200 to 6400 

This PowerShell script performs a comprehensive health check of a Cisco Unified Computing System (UCS) environment. It checks various configurations and hardware compatibility against predefined standards to ensure the system is configured correctly and using supported hardware.

## Features

The script checks the following aspects of the UCS environment:

- **Switching Mode**: Verifies if the switching mode is set to "end-host".
- **Reserved VLANs**: Checks for the usage of specific VLAN ranges that should be reserved.
- **Link Grouping Preference**: Ensures the link aggregation preference is set to "port-channel".
- **Multicast Hardware Hash**: Checks if multicast hardware hashing is disabled.
- **Multicast Optimization for QoS Classes**: Verifies multicast optimization settings for each Quality of Service (QoS) class and displays their names and priorities.
- **Netflow**: Confirms if NetFlow is disabled.
- **MAC Security**: Reviews MAC security configurations for ports.
- **VMM Integration**: Checks for the presence of VMM integration.
- **Dynamic vNIC Connection Policies**: Verifies dynamic vNIC connection policies are not configured.
- **FC Ports Usage**: Checks if Fibre Channel (FC) ports are not in use.
- **Supported Servers**: Validates if servers are of a supported model.
- **IOM Modules**: Checks for supported I/O Module (IOM) models.
- **FEX Devices**: Verifies if Fabric Extenders (FEX) are of supported models.
- **Network Adapters (VIC Cards)**: Checks for supported Virtual Interface Card (VIC) models.

## Usage

1. Run the script in a PowerShell environment with UCS PowerTool module installed.
2. You will be prompted to enter the UCS Manager address, username, and password.
3. The script will then connect to the UCS Manager and perform the checks, outputting the results.
4. To use a local account add ucs-{name of domain}\ to your username

## Output

The script outputs the check results directly to the console. Supported configurations and hardware will display a green check mark (✓), while unsupported or incorrectly configured items will show a red "X".

## Customization

- You can modify the list of supported models for servers, IOM modules, FEX devices, and VIC cards within the script to fit your environment's standards.
- Additional checks can be added by following the pattern established in the script.

## Security

- The script prompts for UCS Manager credentials at runtime to avoid hardcoding sensitive information.
- Consider implementing logging or output redirection to a file for audit purposes.