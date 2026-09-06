# Linux System Monitoring & Automated Alerting Tool

## Project Overview

A Bash-based Linux system monitoring tool designed to monitor the health and basic security status of a Linux server. It checks important system resources and services, generates alerts when configured thresholds are exceeded, and can run automatically using `systemd`.

## How It Works

The tool monitors:

* CPU usage and load
* Memory usage
* Disk usage
* Top processes
* Network interfaces and connectivity
* SSH (`sshd`) and `firewalld` services

It generates threshold-based alerts and records monitoring results in log and report files. A `systemd` service and timer are used to automate monitoring at regular intervals.

## Environment

* **OS:** RHEL 9
* **Shell:** Bash
* **Service Manager:** systemd
* **Security:** SELinux
* **Privileges:** Standard user for monitoring; `sudo` required for service/system configuration
* **Dependencies:** Standard Linux utilities and `policycoreutils-python-utils` for SELinux configuration

## How to Run

Clone the repository and enter the project directory:

```bash
git clone https://github.com/Kunjan-Pawar/Linux_System_Monitoring_Tool.git
cd Linux_System_Monitoring_Tool
```

Run the monitoring script:

```bash
sudo ./scripts/monitor.sh
```

To enable automated monitoring:

```bash
sudo cp systemd/linux-monitor.service /etc/systemd/system/
sudo cp systemd/linux-monitor.timer /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable --now linux-monitor.timer
```

Check the timer:

```bash
systemctl status linux-monitor.timer
```

## Security Considerations

* Keep **SELinux enabled and enforcing**.
* Use appropriate file ownership and permissions.
* Run the monitoring service with the required privileges only.
* Do not store passwords, private keys, API tokens, or other sensitive information in the repository.
* Keep generated logs and reports out of Git when they contain sensitive system information.
* Maintain secure permissions on scripts, configuration files, and log files.

## Documentation

Detailed implementation steps, screenshots, troubleshooting, challenges, and solutions are available in the documentation included in this repository.
