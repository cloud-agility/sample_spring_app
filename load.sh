#!/bin/bash
echo "Press [CTRL+C] to stop.."

while :
do
  curl http://192.168.99.100:30644/hello
  printf "\n"
  sleep $1
done

