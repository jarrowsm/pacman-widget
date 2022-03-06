#!/bin/bash

if (( (count=$(checkupdates 2>/dev/null | wc -l)) > 0)); then
		printf "%d" $count
else
	printf "\n"
fi
