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
FROM oraclelinux:7-slim
#FROM ubuntu:16.04
ARG MYSQL_SERVER_PACKAGE=mysql-community-server-minimal-8.0.23
ARG MYSQL_ROUTER_PACKAGE=mysql-router-community-8.0.23

RUN yum update -y
RUN yum install -y expect
RUN yum install -y https://repo.mysql.com/mysql-community-minimal-release-el7.rpm \
      https://repo.mysql.com/mysql-community-release-el7.rpm \
  && yum-config-manager --enable mysql80-server-minimal \
  && yum-config-manager --enable mysql-tools-community \
  && yum install -y \
      $MYSQL_SERVER_PACKAGE \
      $MYSQL_ROUTER_PACKAGE \
      libpwquality \
  && yum clean all

COPY run.sh /run.sh
COPY util /uitl
COPY start.sh /start.sh
HEALTHCHECK \
	CMD mysqladmin --port 8080 --protocol TCP ping 2 > &1 | grep Access || exit 1
ENTRYPOINT ["/start.sh"]
CMD ["mysqlrouter"]
