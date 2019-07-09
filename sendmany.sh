#!/bin/bash
source config.sh

send_from="tmSoVKsmLaMWy1sStoeSWRDDfoKQYLQH8s6"
send_from="tmU22F4KhQVLE6XkCvKhb13ib86cqCUATBv"
memo=$(cat /home/equihub/memo_513.txt)
HEX_MEMO=$(hexdump -e '"%X"' <<< "$memo")
cmd="$cli2 z_sendmany \
$send_from \"[\
{\\\"address\\\":\\\"tmF2qSjvHCoLS2y8kfpTfP1e1dytYZdJ5dn\\\", \\\"amount\\\":0.0001, \\\"memo\\\":\\\"$HEX_MEMO\\\"}\
]\""

cmd="$cli2 z_sendmany \
$send_from \"[\
{\\\"address\\\":\\\"ztestsapling1ndu0zyuucvwsrdnpx5h4wwzshdp4zrpynzcapwey7z23wasw90xryl6s9rnzdsn8sg62c2vpfm8\\\", \\\"amount\\\":0.0001, \\\"memo\\\":\\\"$HEX_MEMO\\\"},\
{\\\"address\\\":\\\"ztestsapling1egg8mz5evrlsfzltv4jvh36ru5us60dchllazrg7vr9jaxuc0fte6jwfjmk4lwj4jgxg7m5r9ky\\\", \\\"amount\\\":0.0001, \\\"memo\\\":\\\"$HEX_MEMO\\\"}\
]\""

_cmd="$cli2 sendmany \"\" \"{\
\\\"s1ZBftmkGW7XUnJqYzsRbjExBGNBnjcpzR8\\\":0.1,\
\\\"s1e3V62JUJiXy7mqBgMeX22NXk2V4kGu555\\\":0.1\
}\""

echo $cmd > cmd.txt
#$cmd
