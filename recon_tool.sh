#!/bin/bash

# Automated Reconnaissance Tool
# Usage: ./recon_tool.sh <domain>

if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN="$1"
OUTPUT_DIR="recon_results_$DOMAIN"
mkdir -p "$OUTPUT_DIR"

# 1. WHOIS
whois "$DOMAIN" > "$OUTPUT_DIR/whois.txt"
echo "[+] WHOIS completed."

# 2. DIG
# A record
 dig "$DOMAIN" +noall +answer > "$OUTPUT_DIR/dig_a.txt"
# NS record
dig ns "$DOMAIN" +noall +answer > "$OUTPUT_DIR/dig_ns.txt"
# MX record
dig mx "$DOMAIN" +noall +answer > "$OUTPUT_DIR/dig_mx.txt"
echo "[+] DIG completed."

# 3. NSLOOKUP
nslookup "$DOMAIN" > "$OUTPUT_DIR/nslookup.txt"
echo "[+] NSLOOKUP completed."

# 4. theHarvester
if command -v theHarvester &> /dev/null; then
    theHarvester -d "$DOMAIN" -b all -f "$OUTPUT_DIR/theHarvester.html"
    echo "[+] theHarvester completed."
else
    echo "[!] theHarvester not found. Skipping."
fi

# 5. sublist3r
if command -v sublist3r &> /dev/null; then
    sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/sublister.txt"
    echo "[+] sublist3r completed."
else
    echo "[!] sublist3r not found. Skipping."
fi

# 6. subfinder
if command -v subfinder &> /dev/null; then
    subfinder -d "$DOMAIN" -o "$OUTPUT_DIR/subfinder.txt"
    echo "[+] subfinder completed."
else
    echo "[!] subfinder not found. Skipping."
fi

echo "[+] Reconnaissance completed. Results saved in $OUTPUT_DIR/" 