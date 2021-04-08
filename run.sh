#!/bin/bash
#!/usr/bin/env expect
# Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
set -x

if [ "$1" = 'mysqlrouter' ]; then
    if [[ -z $MYSQL_URL ||  -z $MYSQL_USER || -z $MYSQL_PASSWORD ]]; then
	    echo "We require all of"
	    echo "    MYSQL_URL"
	    echo "    MYSQL_USER"
	    echo "    MYSQL_PASSWORD"
	    echo "to be set. Exiting."
	    exit 1
    fi

    echo "Succesfully contacted mysql server at $MYSQL_URL. Trying to bootstrap."
unbuffer expect -c "spawn mysqlrouter --bootstrap $MYSQL_URL --user=mysqlrouter --account=$MYSQL_USER --account-create=never --directory /tmp/mysqlrouter  --conf-base-port=8080 --conf-use-sockets
expect -nocase \"Please enter MySQL password for $MYSQL_USER:\" {send \"$MYSQL_PASSWORD\r\"; exp_continue; interact}"
    sed -i -e 's/logging_folder=.*$/logging_folder=/' /tmp/mysqlrouter/mysqlrouter.conf
    echo "Starting mysql-router."
    exec "$@" --config /tmp/mysqlrouter/mysqlrouter.conf
fi
