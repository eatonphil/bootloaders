#!/usr/bin/env bash

set -ex

nasm -f bin $1.asm -o $1.bin
qemu-system-x86_64 -fda $1.bin
