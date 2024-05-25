#!/usr/bin/env bash

count=0
while "$@"; do
  (( count++ ))
  echo "======Attempt #$count PASSED======"
  echo
done
echo "======"
echo "Passed $count times before failing."
echo "======"

