#!/usr/bin/env bash

set -e -x

ISPN_HOME=../standalone-9.0.0.Final
WF_HOME=/opt/wildfly-10.1.0.Final

start_datagrid_server() {
    local home=$ISPN_HOME
    local name=$1
    local offset=$2
    local node=$3

    (cd $ISPN_HOME; ./bin/standalone.sh \
        -c clustered.xml \
        -b localhost \
        -bmanagement=localhost \
        -Djboss.server.base.dir=$name \
        -Djboss.socket.binding.port-offset=$offset \
        -Djboss.node.name=$node &)
}


start_datagrid_server standalone1 200 ispn1
start_datagrid_server standalone2 300 ispn2
start_datagrid_server standalone3 400 ispn3

$WF_HOME/bin/standalone.sh \
    -Djboss.socket.binding.port-offset=100 \
    -Dinfinispan.visualizer.jmxUser=admin \
    -Dinfinispan.visualizer.jmxPass=p455w0rd \
    -Dinfinispan.visualizer.serverList=localhost:11422 &
