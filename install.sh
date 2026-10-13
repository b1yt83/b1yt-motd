#!/usr/bin/env bash
# GuideCloud Premium MOTD Installer
# Created by B1YT
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root: sudo bash install.sh"
  exit 1
fi

MOTD_DIR=/etc/update-motd.d
MOTD_FILE="$MOTD_DIR/00-guidecloud"
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/root/guidecloud-motd-backup-$STAMP"

if [[ ! -d "$MOTD_DIR" ]]; then
  echo "ERROR: $MOTD_DIR was not found. This installer targets Ubuntu/Debian update-motd systems."
  exit 1
fi

mkdir -p "$BACKUP_DIR/update-motd.d"
cp -a /etc/motd "$BACKUP_DIR/" 2>/dev/null || true
cp -a /etc/default/motd-news "$BACKUP_DIR/" 2>/dev/null || true
cp -a "$MOTD_DIR"/. "$BACKUP_DIR/update-motd.d/" 2>/dev/null || true
printf '%s\n' "$BACKUP_DIR" > /root/guidecloud-motd-last-backup

echo "Installing GuideCloud Premium MOTD..."

cat > "$MOTD_FILE" <<'MOTD'
#!/usr/bin/env bash
set +e

GREEN='\033[38;5;82m'; CYAN='\033[38;5;51m'; BLUE='\033[38;5;39m'
MAGENTA='\033[38;5;213m'; YELLOW='\033[38;5;220m'; GRAY='\033[38;5;245m'; RESET='\033[0m'

HOST=$(hostname 2>/dev/null || echo Unknown)
OS=$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-Linux}")
KERNEL=$(uname -r 2>/dev/null || echo Unknown)
UPTIME=$(uptime -p 2>/dev/null || echo Unknown)
CPU_MODEL=$(awk -F ': ' '/model name/ {print $2; exit}' /proc/cpuinfo)
CPU_MODEL=${CPU_MODEL:-$(uname -m)}
CORES=$(nproc 2>/dev/null || echo Unknown)
LOAD=$(awk '{print $1 " / " $2 " / " $3}' /proc/loadavg 2>/dev/null)

read -r MT MU < <(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {print t, t-a}' /proc/meminfo)
MT=${MT:-0}; MU=${MU:-0}
if (( MT > 0 )); then MP=$((MU*100/MT)); else MP=0; fi
MEM="${MU:+$((MU/1024))} MiB / $((MT/1024)) MiB (${MP}%)"
DISK=$(df -hP / 2>/dev/null | awk 'NR==2 {print $3 " used / " $2 " (" $5 ")"}')
DISK=${DISK:-Unknown}
IP=$(ip -o route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')
IP=${IP:-$(hostname -I 2>/dev/null | awk '{print $1}')}; IP=${IP:-Unavailable}
USERS=$(who 2>/dev/null | wc -l)
PROCS=$(ps -e --no-headers 2>/dev/null | wc -l)

# CPU usage sampled over a short interval.
CPU_USAGE='N/A'
read -r _ u1 n1 s1 i1 w1 q1 sq1 st1 _ < /proc/stat
T1=$((u1+n1+s1+i1+w1+q1+sq1+st1)); I1=$((i1+w1))
sleep 0.15
read -r _ u2 n2 s2 i2 w2 q2 sq2 st2 _ < /proc/stat
T2=$((u2+n2+s2+i2+w2+q2+sq2+st2)); I2=$((i2+w2))
DT=$((T2-T1)); DI=$((I2-I1))
if (( DT > 0 )); then CPU_USAGE="$(((DT-DI)*100/DT))%"; fi

printf '\n'
printf "%b" "$MAGENTA"
cat <<'LOGO'
   ____ _   _ ___ ____  _____ ____ _     ___  _   _ ____
  / ___| | | |_ _|  _ \| ____/ ___| |   / _ \| | | |  _ \
 | |  _| | | || || | | |  _|| |   | |  | | | | | | | | | |
 | |_| | |_| || || |_| | |__| |___| |__| |_| | |_| | |_| |
  \____|\___/|___|____/|_____\____|_____\___/ \___/|____/
LOGO
printf "%b\n" "$RESET"
printf "%b  Welcome to GuideCloud Datacenter%b\n" "$GREEN" "$RESET"
printf "%b  High Performance • Secure • Reliable Infrastructure%b\n" "$BLUE" "$RESET"
printf "%b  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n" "$GRAY" "$RESET"
printf "%b%-18s%b %s\n" "$CYAN" 'Hostname:' "$RESET" "$HOST"
printf "%b%-18s%b %s\n" "$CYAN" 'Operating System:' "$RESET" "$OS"
printf "%b%-18s%b %s\n" "$CYAN" 'Kernel:' "$RESET" "$KERNEL"
printf "%b%-18s%b %s\n" "$CYAN" 'Uptime:' "$RESET" "$UPTIME"
printf "%b%-18s%b %s\n" "$CYAN" 'CPU:' "$RESET" "$CPU_MODEL"
printf "%b%-18s%b %s cores\n" "$CYAN" 'CPU Cores:' "$RESET" "$CORES"
printf "%b%-18s%b %s\n" "$CYAN" 'CPU Usage:' "$RESET" "$CPU_USAGE"
printf "%b%-18s%b %s\n" "$CYAN" 'Memory:' "$RESET" "$MEM"
printf "%b%-18s%b %s\n" "$CYAN" 'Root Disk:' "$RESET" "$DISK"
printf "%b%-18s%b %s\n" "$CYAN" 'Load Average:' "$RESET" "${LOAD:-Unknown}"
printf "%b%-18s%b %s\n" "$CYAN" 'IP Address:' "$RESET" "$IP"
printf "%b%-18s%b %s\n" "$CYAN" 'Processes:' "$RESET" "$PROCS"
printf "%b%-18s%b %s\n" "$CYAN" 'Logged-in Users:' "$RESET" "$USERS"
printf "%b  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n" "$GRAY" "$RESET"
printf "%b  Website:%b https://guidecloud.in\n" "$GREEN" "$RESET"
printf "%b  Support:%b support@guidecloud.in\n" "$GREEN" "$RESET"
printf "%b  GuideCloud — Premium Hosting Experience 💎%b\n" "$MAGENTA" "$RESET"
printf "%b  Created by B1YT%b\n\n" "$GRAY" "$RESET"
MOTD
chmod 755 "$MOTD_FILE"

# Disable other dynamic MOTD scripts, preserving their files and contents.
# PAM is intentionally not edited; this avoids locking out SSH users.
find "$MOTD_DIR" -maxdepth 1 -type f ! -name '00-guidecloud' -exec chmod a-x {} +

# Disable Ubuntu's motd-news feature if its config exists.
if [[ -f /etc/default/motd-news ]]; then
  cp -a /etc/default/motd-news "$BACKUP_DIR/motd-news-before-change"
  if grep -q '^ENABLED=' /etc/default/motd-news; then
    sed -i 's/^ENABLED=.*/ENABLED=0/' /etc/default/motd-news
  else
    printf '\nENABLED=0\n' >> /etc/default/motd-news
  fi
fi

# Static /etc/motd is backed up, then emptied to avoid duplicate login text.
: > /etc/motd

cat > /usr/local/sbin/restore-guidecloud-motd <<'RESTORE'
#!/usr/bin/env bash
set -Eeuo pipefail
BACKUP_DIR=$(cat /root/guidecloud-motd-last-backup)
[[ -d "$BACKUP_DIR/update-motd.d" ]] || { echo "Backup not found: $BACKUP_DIR"; exit 1; }
find /etc/update-motd.d -maxdepth 1 -type f -delete
cp -a "$BACKUP_DIR/update-motd.d/." /etc/update-motd.d/
if [[ -f "$BACKUP_DIR/motd" ]]; then cp -a "$BACKUP_DIR/motd" /etc/motd; fi
if [[ -f "$BACKUP_DIR/motd-news-before-change" ]]; then cp -a "$BACKUP_DIR/motd-news-before-change" /etc/default/motd-news; elif [[ -f "$BACKUP_DIR/motd-news" ]]; then cp -a "$BACKUP_DIR/motd-news" /etc/default/motd-news; fi
echo "MOTD files restored from $BACKUP_DIR. PAM was not changed."
RESTORE
chmod 700 /usr/local/sbin/restore-guidecloud-motd

# Syntax-check before displaying test output.
bash -n "$MOTD_FILE"
echo
echo "GuideCloud MOTD installed. Backup: $BACKUP_DIR"
echo "Preview: bash $MOTD_FILE"
echo "Restore: restore-guidecloud-motd"
echo "Reconnect via SSH to test the login banner."
