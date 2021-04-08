#!/bin/bash
#!/usr/bin/env expect
set -ex

{

  url=`util/jq -r '.["user-provided"][0]["credentials"]["db-url"]' <<< $VCAP_SERVICES`
  user=`util/jq -r '.["user-provided"][0]["credentials"]["db-user"]' <<< $VCAP_SERVICES`
  password=`util/jq -r '.["user-provided"][0]["credentials"]["db-password"]'  <<< $VCAP_SERVICES`



    echo " server at $url. Trying to bootstrap."
#    echo -e '$MYSQL_PASSWORD\n$MYSQL_PASSWORD\n' |   mysqlrouter --bootstrap "$MYSQL_USER@$MYSQL_HOST:$MYSQL_PORT" --user=mysqlrouter --account $MYSQL_USER ----account-create never --directory /tmp/mysqlrouter --force < "$PASSFILE"

unbuffer expect -c "spawn mysqlrouter --bootstrap $url--user=mysqlrouter --account=$user --account-create=never --directory /tmp/mysqlrouter --conf-base-port=8080 --conf-use-sockets
expect -nocase \"Please enter MySQL password for $user:\" {send \"$password\r\"; exp_continue; interact}"
    sed -i -e 's/logging_folder=.*$/logging_folder=/' /tmp/mysqlrouter/mysqlrouter.conf
    echo "Starting mysql-router."
    exec "$@" --config /tmp/mysqlrouter/mysqlrouter.conf

} &> /dev/null