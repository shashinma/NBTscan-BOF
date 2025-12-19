# NBTscan-BOF
> #### Developed for [@Adaptix-Framework](https://github.com/Adaptix-Framework)

NetBIOS name scanner that queries NetBIOS name service (port 137) to discover NetBIOS names, MAC addresses, and service information from Windows hosts on the network. Automatically registers discovered targets in Adaptix.

> [!WARNING]
> To use all features (including automatic target registration in Adaptix), changes from [PR #90: Implemented API for Targets](https://github.com/Adaptix-Framework/Extension-Kit/pull/90) are required.

```
nbtscan <target> [-v] [-q] [-e] [-l] [-s <separator>] [-t <timeout>] [-no-targets]
```

- `target` (required): Destination IP address, range or CIDR format
  - Single IP: `192.168.1.1`
  - IP range: `192.168.1.1-192.168.1.20` or `192.168.1.1-20`
  - CIDR: `192.168.1.0/24`
  - Comma-separated: `192.168.1.1,192.168.1.5,192.168.1.10`
- `-v` (optional): Verbose output - shows detailed NetBIOS information including service types
- `-q` (optional): Quiet mode - suppresses error messages
- `-e` (optional): Output in `/etc/hosts` format
- `-l` (optional): Output in `lmhosts` format
- `-s <separator>` (optional): Script-friendly output with custom separator (enables script mode)
- `-t <timeout>` (optional): Response timeout in milliseconds (default: 1000, max: 600000)
- `-no-targets` (optional): Disable automatic target registration in Adaptix

**Output Formats:**

1. **Normal mode** (default): Shows IP address, NetBIOS name, and MAC address
2. **Verbose mode** (`-v`): Shows detailed information including:
   - NetBIOS names with service types (00, 03, 20, etc.)
   - MAC address
   - Domain/workgroup information
3. **Script mode** (`-s <separator>`): Machine-readable output with custom separator
4. **Hosts format** (`-e` or `-l`): Output suitable for `/etc/hosts` or `lmhosts` files

**NetBIOS Service Types:**

| Code | Service Type |
|------|--------------|
| `00` | Workstation Service |
| `03` | Messenger Service |
| `20` | File Server Service |
| `1B` | Domain Master Browser |
| `1C` | Domain Controller |
| `1D` | Master Browser |
| `1E` | Browser Service Elections |

```Shell
# Basic scan of a single host
nbtscan 192.168.1.1

# Scan a subnet
nbtscan 192.168.1.0/24

# Scan an IP range
nbtscan 192.168.1.1-192.168.1.20

# Verbose output with detailed information
nbtscan 192.168.1.0/24 -v

# Quiet mode (suppress errors)
nbtscan 192.168.1.0/24 -q

# Output in /etc/hosts format
nbtscan 192.168.1.0/24 -e

# Output in lmhosts format
nbtscan 192.168.1.0/24 -l

# Script-friendly output with custom separator
nbtscan 192.168.1.0/24 -s "|"

# Custom timeout (2 seconds)
nbtscan 192.168.1.0/24 -t 2000

# Scan without auto-registering targets
nbtscan 192.168.1.0/24 -no-targets

# Combined: verbose scan with custom timeout
nbtscan 192.168.1.0/24 -v -t 3000
```

**Target Registration:**

By default, nbtscan automatically registers discovered hosts in Adaptix with the following information:
- Computer name (from NetBIOS name)
- Domain/workgroup (if available)
- IP address
- OS information (if detected)
- MAC address

> [!NOTE] 
> Use `-no-targets` flag to disable automatic registration if you only want to view the scan results without adding them to Adaptix targets.

