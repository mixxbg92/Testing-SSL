# SSL Certificate Expiry Checker

## 📌 Overview
This project provides a **Bash-based SSL certificate checker** that:
- Reads a list of websites from `websites.conf`
- Retrieves their SSL/TLS certificates
- Calculates days left until expiration
- Generates a consolidated report
- Sends the report via **Gmail SMTP** to a configured email address

---

## 🛠 Requirements
- **Docker** installed and running
- A **Gmail App Password**

---

## 🔑 How to Generate a Gmail App Password
1. Enable **2-Step Verification** in your Google Account
2. Go to [Google App Passwords](https://myaccount.google.com/apppasswords)
3. Create a new password for "SSL Checker"
4. Copy the 16-character password (without spaces)

---

## 📂 Project Structure
TestingSSl
/
├── Dockerfile
├── cert_checker.sh
├── websites.conf
├── msmtprc
└── README.md

---

## ⚙️ Configuration
Websites

Edit websites.conf to add the domains you want to monitor:

google.com
github.com
apple.com
sopharmacy.bg


The script automatically normalizes sopharmacy.bg → www.sopharmacy.bg.

SMTP (msmtprc)

Configure Gmail SMTP in msmtprc:

defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account gmail
host smtp.gmail.com
port 587
from your.email@gmail.com
user your.email@gmail.com
passwordeval "echo $GMAIL_APP_PASSWORD"

account default : gmail
### Websites
Edit `websites.conf` to add the domains you want to monitor:

google.com
github.com
apple.com
sopharmacy.bg

markdown

🚀 Build and Run
Build the Docker image
docker build -t cert-checker .

Run the container
docker run --rm -e GMAIL_APP_PASSWORD=your_app_password cert-checker

---

📝 Notes

Certificates are checked on port 443 by default

Handles Windows CRLF line endings in websites.conf

One consolidated email is sent per run
