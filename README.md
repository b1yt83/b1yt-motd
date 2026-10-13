# GuideCloud Premium MOTD

A Bash installer for a branded GuideCloud login banner on Ubuntu/Debian systems that use `/etc/update-motd.d`.

**Created by B1YT.**

## Features

- GuideCloud terminal banner
- Hostname, OS, kernel, uptime, CPU model/cores/usage, RAM, root disk, load average, IP, processes and logged-in users
- Backs up the existing MOTD scripts and static MOTD
- Creates `restore-guidecloud-motd` to restore the backed-up MOTD setup
- Does not edit PAM files or restart SSH

## Install from GitHub

After you upload this repository to GitHub, replace `b1yt83` with your GitHub username:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/b1yt83/b1yt-motd/refs/heads/main/install.sh))
```

Or clone and inspect it before running:

```bash
git clone https://github.com/YOUR_USERNAME/guidecloud-motd.git
cd guidecloud-motd
less install.sh
sudo bash install.sh
```

Run as root. Review the script before executing code downloaded from the internet. The installer changes MOTD script permissions and clears `/etc/motd`, after making a backup. It does not modify PAM configuration. Systems not configured to display PAM/update-motd output may not show the banner automatically at SSH login.

## Preview

```bash
bash /etc/update-motd.d/00-guidecloud
```

## Restore

```bash
sudo restore-guidecloud-motd
```

The restore helper restores the backed-up MOTD scripts, static MOTD, and motd-news configuration if available. It does not restore unrelated changes made after installation.

## Branding

- Brand: GuideCloud
- Website: https://guidecloud.in
- Support: support@guidecloud.in
- Credit: B1YT
