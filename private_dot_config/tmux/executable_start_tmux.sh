#!/bin/bash

# Check if the tmux session "zero" exists
if ! tmux has-session -t zero 2>/dev/null; then
    # Start a new tmux session named "zero"
    tmux new-session -d -s zero
fi

