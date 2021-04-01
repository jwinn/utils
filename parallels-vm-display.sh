#!/bin/sh -e

local vm_list=$(prlctl list -a)
# TODO: either present a list to choose, or allow for arg
prlctl set {7a365711-15a7-4657-be55-4b0e3e5da07c} --video-adapter-type virtio
