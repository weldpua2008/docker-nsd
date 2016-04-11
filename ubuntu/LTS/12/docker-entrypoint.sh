#!/bin/bash
# weldpua2008@gmail.com

PID_PATH="/var/run/nsd3/nsd.pid"
NS_DB="/var/lib/nsd3/nsd.db"
NS_CONF="/etc/nsd3/nsd.conf"
set -e

# Clean files related to some previous run
[[ -f "$PID_PATH" ]] && rm -f "$PID_PATH"
[[ -f "$NS_DB" ]] && rm -f "$NS_DB"

# Rebuild the database
nsdc -c "$NS_CONF" rebuild

# Start NSD
/usr/sbin/nsd -d -c "$NS_CONF" -l /var/log/nsd/nsd.log
