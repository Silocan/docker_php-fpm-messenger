#!/bin/bash
set -e

if [ "$USER" = "root" ]; then

    # set localtime
    ln -sf /usr/share/zoneinfo/$LOCALTIME /etc/localtime
fi

#
# functions

function set_conf() {
    echo '' >$2
    IFSO=$IFS
    IFS=$(echo -en "\n\b")
    for c in $(printenv | grep $1); do echo "$(echo $c | cut -d "=" -f1 | awk -F"$1" '{print $2}') $3 $(echo $c | cut -d "=" -f2)" >>$2; done
    IFS=$IFSO
}

#
# PHP

echo "date.timezone = \"${LOCALTIME}\"" >>$PHP_INI_DIR/conf.d/00-default.ini
set_conf "PHP__" "$PHP_INI_DIR/conf.d/40-user.ini" "="

chmod 777 -Rf /var/www

PARAM_VERBOSE=''
if [[ $VERBOSE -eq 1 ]]; then
    PARAM_VERBOSE='-vv'
fi

sleep 10
/var/www/bin/console messenger:consume $PARAM_VERBOSE $RECEIVER_NAME >&1
