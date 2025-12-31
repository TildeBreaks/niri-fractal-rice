#!/bin/bash
# Swayidle - automatic screen locking and power management

swayidle -w \
    timeout 300 'lock-screen.sh' \
    timeout 600 'niri msg action power-off-monitors' \
    resume 'niri msg action power-on-monitors' \
    before-sleep 'lock-screen.sh'
