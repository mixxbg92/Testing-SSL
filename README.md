# SSL Certificate Expiry Checker

## 📌 Overview
This project provides a **Bash-based SSL certificate checker** that:

- Reads a list of websites from `websites.conf`
- Retrieves their SSL/TLS certificates
- Calculates days left until expiration
- Generates a consolidated report
- Sends the report via **Gmail SMTP** to a configured email address
- Runs entirely inside a **Docker container**

---

## 🛠 Requirements
- **Docker** installed and running
- A **Gmail App Password**

⚠️ Normal Gmail passwords will **not** work. You must create an **App Password**.

---

## 🔑 How to Generate a Gmail App Password
1. Enable **2-Step Verification** in your Google Account  
   [Google Account Security Settings](https://myaccount.google.com/security)
2. Go to **App Passwords**:  
   [Google App Passwords](https://myaccount.google.com/apppasswords)
3. Create a new App Password (choose "Other" → name it `SSL Checker`)
4. Copy the 16-character password (without spaces)

---

## 📂 Project Structure
```text
TestingSSl/
├── Dockerfile
├── cert_checker.sh
├── websites.conf
├── msmtprc
├── sample_report.txt
└── README.md
```

---

## ⚙️ Configuration

### Websites
Edit `websites.conf` to add the domains you want to monitor:

```text
google.com
github.com
apple.com
sopharmacy.bg
```

> The script automatically normalizes **sopharmacy.bg** → `www.sopharmacy.bg`.

### SMTP (`msmtprc`)
Configure Gmail SMTP in `msmtprc`:

```ini
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
```

---

## 🚀 Build and Run

### Build the Docker image
```bash
docker build -t cert-checker .
```

### Run the container
```bash
docker run --rm -e GMAIL_APP_PASSWORD=your_app_password cert-checker
```

---

## 📧 Example Output

### Email Subject
```text
[SSL Report] 3 OK, 1 WARNING, 0 CRITICAL, 0 FAILED
```

### Email Body
```text
SSL Certificate Report - Wed Sep 10 08:44:42 UTC 2025

Checking: google.com
🔑 Expiration date: Nov 10 08:40:08 2025 GMT (60 days left)
✅ OK: Valid for 60 more days.
----------------------------------------------------
Checking: github.com
🔑 Expiration date: Feb  5 23:59:59 2026 GMT (148 days left)
✅ OK: Valid for 148 more days.
----------------------------------------------------
Checking: apple.com
🔑 Expiration date: Nov  4 18:12:03 2025 GMT (55 days left)
✅ OK: Valid for 55 more days.
----------------------------------------------------
Checking: www.sopharmacy.bg
🔑 Expiration date: Sep 25 23:59:59 2025 GMT (15 days left)
⚠️ WARNING: Expires in 15 days.
----------------------------------------------------

Summary: [SSL Report] 3 OK, 1 WARNING, 0 CRITICAL, 0 FAILED
```

---

## 📝 Notes
- Certificates are checked on **port 443** by default
- Handles **Windows CRLF line endings** in `websites.conf`
- One consolidated email is sent per run

---

## 🔮 Future Improvements
- Add Slack/Teams webhook notifications
- Support for non-standard ports (e.g., `example.com:8443`)
- Colorized console output
