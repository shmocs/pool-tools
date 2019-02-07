#!/bin/bash
source config.sh

send_from="s1jzUtYm9ycqCPSqGHfupghKdcTYKH2yQ2m"

cmd="$cli2 z_sendmany \
$send_from \"[\
{\\\"address\\\":\\\"s1e3V62JUJiXy7mqBgMeX22NXk2V4kGu555\\\", \\\"amount\\\":1},\
{\\\"address\\\":\\\"s1ZBftmkGW7XUnJqYzsRbjExBGNBnjcpzR8\\\", \\\"amount\\\":2},\
{\\\"address\\\":\\\"s1djunsw5pgbodthbrq9zGeEyKzDVvpSTEF\\\", \\\"amount\\\":3}\
]\""

echo $cmd


