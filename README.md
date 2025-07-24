# recon1

## Overview

`recon_tool.sh` is an advanced, automated reconnaissance tool for security researchers and penetration testers. It combines multiple popular recon utilities into a single, parallelized, and robust Bash script. The tool collects domain information, DNS records, subdomains, open ports, and more, saving all results in a timestamped directory for easy review.

## Features

- **Input sanitization**: Handles domains with or without protocol/trailing slashes
- **Parallel execution**: All recon modules run concurrently for speed
- **Comprehensive recon**: Integrates whois, dig, nslookup, theHarvester, sublist3r, subfinder, crt.sh, nmap, httpx, and amass
- **Error handling**: Logs errors and missing tools
- **Timestamped output**: Results are organized in a unique, timestamped directory

## Recon Modules

- **whois**: Domain registration info
- **dig**: DNS A, NS, MX records
- **nslookup**: DNS lookup
- **theHarvester**: OSINT (emails, hosts, subdomains)
- **sublist3r**: Subdomain enumeration
- **subfinder**: Subdomain enumeration
- **crt.sh**: Subdomains from certificate transparency logs
- **nmap**: Fast port scan (top 1000 ports)
- **httpx**: Live host probing
- **amass**: Passive subdomain enumeration

## Installation

1. **Clone this repository** (or copy the script to your machine):
   ```bash
   git clone https://github.com/gbrlprs/recon1
   cd recon1/bash
   ```
2. **Make the script executable:**
   ```bash
   chmod +x recon_tool.sh
   ```
3. **Install dependencies:**
   Most tools are available in Kali Linux or can be installed via apt or pip:
   ```bash
   sudo apt update
   sudo apt install whois dnsutils theharvester sublist3r nmap curl
   sudo apt install golang-go # for subfinder and amass
   GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
   GO111MODULE=on go install -v github.com/owasp-amass/amass/v3/...@latest
   go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
   export PATH=$PATH:$(go env GOPATH)/bin
   pip install sublist3r
   # Or install via your package manager as needed
   ```

## Usage

```bash
./recon_tool.sh <domain>
```
- Example:
  ```bash
  ./recon_tool.sh example.com
  ```
- The script will sanitize the input and create a directory like `recon_results_example.com_20240510_153000` with all results and error logs.

## Output

Each tool's output and error log are saved in the results directory. Example structure:

```
recon_results_example.com_20240510_153000/
├── whois.txt
├── whois.err
├── dig_a.txt
├── dig_a.err
├── dig_ns.txt
├── dig_ns.err
├── dig_mx.txt
├── dig_mx.err
├── nslookup.txt
├── nslookup.err
├── theHarvester.html
├── theHarvester.err
├── sublister.txt
├── sublister.err
├── subfinder.txt
├── subfinder.err
├── crtsh.json
├── crtsh.err
├── nmap.txt
├── nmap.err
├── httpx.txt
├── httpx.err
├── amass.txt
├── amass.err
```

## Notes
- If a tool is not installed, the script will skip it and log a warning.
- For best results, ensure all dependencies are installed and in your `$PATH`.
- Some tools (like subfinder, amass, httpx) require Go; see their documentation for details.

## License

MIT License
