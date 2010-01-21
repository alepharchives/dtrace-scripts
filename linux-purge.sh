#!/bin/sh

# chown root:root linux-purge.sh && chmod +xs linux-purge.sh

sudo sync && sudo sysctl -w vm.drop_caches=3 && sudo sysctl -w vm.drop_caches=0
