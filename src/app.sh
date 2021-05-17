#!/usr/bin/env sh
# The snippet below is originally from https://github.com/ttionya/vaultwarden-backup
# If you self host bitwarden/vaultwarden, check it out!

function configure_cron() {
    local CRON_COUNT=$(crontab -l | grep -c 'backup.sh')
    if [[ ${CRON_COUNT} -eq 0 ]]; then
        echo "${CRON} sh /app/backup.sh > /dev/stdout" >>/etc/crontabs/root
    fi
}

configure_cron
crond -l 2 -f
