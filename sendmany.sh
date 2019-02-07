#!/bin/bash
source config.sh

send_from="s1jzUtYm9ycqCPSqGHfupghKdcTYKH2yQ2m"
cmd="$cli2 z_sendmany \
$send_from \"[\
{\\\"address\\\":\\\"s1PipHKjSjPsyqqKvYuEW3VBxX4VWTHcJmH\\\", \\\"amount\\\":100},\
{\\\"address\\\":\\\"s1PipHKjSjPsyqqKvYuEW3VBxX4VWTHcJmH\\\", \\\"amount\\\":100}\
]\""

cmd="$cli2 sendmany \"\" \"{\
\\\"s1ZBftmkGW7XUnJqYzsRbjExBGNBnjcpzR8\\\":0.1,\
\\\"s1e3V62JUJiXy7mqBgMeX22NXk2V4kGu555\\\":0.1\
}\""

echo $cmd

