#!/bin/bash

# Automated Reconnaissance Tool (Enhanced)
# Usage: ./recon_tool.sh <domain>

set -euo pipefail

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

if [ -z "${1:-}" ]; then
    log "Usage: $0 <domain>"
    exit 1
fi

# Input sanitization: remove protocol and trailing slashes
DOMAIN="$1"
DOMAIN=$(echo "$DOMAIN" | sed -E 's#^https?://##; s#/$##')

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
OUTPUT_DIR="recon_results_${DOMAIN}_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

# Error handling function
tool_wrapper() {
    TOOL_NAME="$1"
    shift
    log "[START] $TOOL_NAME"
    if "$@"; then
        log "[SUCCESS] $TOOL_NAME"
    else
        log "[ERROR] $TOOL_NAME failed."
    fi
}

# 1. WHOIS
(
    tool_wrapper "whois" whois "$DOMAIN" > "$OUTPUT_DIR/whois.txt" 2> "$OUTPUT_DIR/whois.err"
) &

# 2. DIG (A, NS, MX)
(
    tool_wrapper "dig_a" dig "$DOMAIN" +noall +answer > "$OUTPUT_DIR/dig_a.txt" 2> "$OUTPUT_DIR/dig_a.err"
    tool_wrapper "dig_ns" dig ns "$DOMAIN" +noall +answer > "$OUTPUT_DIR/dig_ns.txt" 2> "$OUTPUT_DIR/dig_ns.err"
    tool_wrapper "dig_mx" dig mx "$DOMAIN" +noall +answer > "$OUTPUT_DIR/dig_mx.txt" 2> "$OUTPUT_DIR/dig_mx.err"
) &

# 3. NSLOOKUP
(
    tool_wrapper "nslookup" nslookup "$DOMAIN" > "$OUTPUT_DIR/nslookup.txt" 2> "$OUTPUT_DIR/nslookup.err"
) &

# 4. theHarvester
(
    if command -v theHarvester &> /dev/null; then
        tool_wrapper "theHarvester" theHarvester -d "$DOMAIN" -b all -f "$OUTPUT_DIR/theHarvester.html" 2> "$OUTPUT_DIR/theHarvester.err"
    else
        log "[SKIP] theHarvester not found."
    fi
) &

# 5. sublist3r
(
    if command -v sublist3r &> /dev/null; then
        tool_wrapper "sublist3r" sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/sublister.txt" 2> "$OUTPUT_DIR/sublister.err"
    else
        log "[SKIP] sublist3r not found."
    fi
) &

# 6. subfinder
(
    if command -v subfinder &> /dev/null; then
        tool_wrapper "subfinder" subfinder -d "$DOMAIN" -o "$OUTPUT_DIR/subfinder.txt" 2> "$OUTPUT_DIR/subfinder.err"
    else
        log "[SKIP] subfinder not found."
    fi
) &

# 7. crt.sh (certificate transparency log subdomains)
(
    log "[START] crt.sh"
    if command -v curl &> /dev/null; then
        curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" > "$OUTPUT_DIR/crtsh.json" 2> "$OUTPUT_DIR/crtsh.err" && \
        log "[SUCCESS] crt.sh" || log "[ERROR] crt.sh failed."
    else
        log "[SKIP] curl not found for crt.sh."
    fi
) &

# 8. nmap (top 1000 ports)
(
    if command -v nmap &> /dev/null; then
        tool_wrapper "nmap" nmap -T4 -F "$DOMAIN" -oN "$OUTPUT_DIR/nmap.txt" 2> "$OUTPUT_DIR/nmap.err"
    else
        log "[SKIP] nmap not found."
    fi
) &

# 9. httpx (probe for live hosts)
(
    if command -v httpx &> /dev/null; then
        # Use subfinder output if available, else just the domain
        SUBS_FILE="$OUTPUT_DIR/subfinder.txt"
        if [ -s "$SUBS_FILE" ]; then
            cat "$SUBS_FILE" | httpx -o "$OUTPUT_DIR/httpx.txt" 2> "$OUTPUT_DIR/httpx.err"
        else
            echo "$DOMAIN" | httpx -o "$OUTPUT_DIR/httpx.txt" 2> "$OUTPUT_DIR/httpx.err"
        fi
        log "[SUCCESS] httpx"
    else
        log "[SKIP] httpx not found."
    fi
) &

# 10. amass (subdomain enumeration)
(
    if command -v amass &> /dev/null; then
        tool_wrapper "amass" amass enum -passive -d "$DOMAIN" -o "$OUTPUT_DIR/amass.txt" 2> "$OUTPUT_DIR/amass.err"
    else
        log "[SKIP] amass not found."
    fi
) &

wait
log "[+] Reconnaissance completed. Results saved in $OUTPUT_DIR/" 
