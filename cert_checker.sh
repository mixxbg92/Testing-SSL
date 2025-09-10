#!/bin/bash
# SSL Certificate Expiry Checker - Consolidated Report with Summary
# Author: Hristo Rusev

CONFIG_FILE="websites.conf"
ALERT_EMAIL="hristo.rusev92@gmail.com"

WARNING_DAYS=30
CRITICAL_DAYS=15

REPORT="SSL Certificate Report - $(date)\n\n"

# Counters
ok_count=0
warn_count=0
crit_count=0
fail_count=0

# Function to fetch expiry date
get_cert_expiry() {
    local host=$1
    echo | openssl s_client -servername "$host" -connect "$host:443" -showcerts 2>/dev/null \
        | openssl x509 -noout -enddate 2>/dev/null
}

# Main loop
while read -r site || [[ -n "$site" ]]; do
    site=$(echo "$site" | tr -d '\r' | xargs)   # fix CRLF
    [[ -z "$site" ]] && continue

    if [[ "$site" == "sopharmacy.bg" ]]; then
        site="www.sopharmacy.bg"
    fi

    REPORT+="Checking: $site\n"

    end_date=$(get_cert_expiry "$site")

    if [[ -z "$end_date" && "$site" != www.* ]]; then
        REPORT+="❌ Failed for $site, retrying with www.$site ...\n"
        alt_site="www.$site"
        end_date=$(get_cert_expiry "$alt_site")
        if [[ -n "$end_date" ]]; then
            site="$alt_site"
        fi
    fi

    if [[ -z "$end_date" ]]; then
        REPORT+="❌ Could not retrieve certificate for $site\n"
        REPORT+="----------------------------------------------------\n"
        ((fail_count++))
        continue
    fi

    expiry_date=$(echo "$end_date" | cut -d= -f2)
    expiry_epoch=$(date -d "$expiry_date" +%s)
    now_epoch=$(date +%s)
    days_left=$(( (expiry_epoch - now_epoch) / 86400 ))

    REPORT+="🔑 Expiration date: $expiry_date ($days_left days left)\n"

    if (( days_left <= CRITICAL_DAYS )); then
        REPORT+="🚨 CRITICAL: Expires in $days_left days!\n"
        ((crit_count++))
    elif (( days_left <= WARNING_DAYS )); then
        REPORT+="⚠️ WARNING: Expires in $days_left days.\n"
        ((warn_count++))
    else
        REPORT+="✅ OK: Valid for $days_left more days.\n"
        ((ok_count++))
    fi

    REPORT+="----------------------------------------------------\n"
done < "$CONFIG_FILE"

SUBJECT="[SSL Report] ${ok_count} OK, ${warn_count} WARNING, ${crit_count} CRITICAL, ${fail_count} FAILED"

echo -e "Subject: $SUBJECT\nTo: $ALERT_EMAIL\n\n$REPORT" \
    | msmtp --account=gmail "$ALERT_EMAIL"

echo -e "$REPORT"
echo -e "Summary: $SUBJECT"
