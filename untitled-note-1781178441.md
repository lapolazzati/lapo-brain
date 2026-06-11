---
type: Note
---
#

echo "=== USERS ===" && cut -d: -f1 /etc/passwd | sort && echo "=== CADDY ===" && ls /etc/caddy/ && echo "=== SERVICES ===" && systemctl list-units --type=service --state=running --no-pager && echo "=== DISK ===" && df -h && echo "=== /srv ===" && ls /srv/ 2>/dev/null || echo "no /srv"
