#!/bin/sh

case ${MONS_NUMBER} in
    1)
        mons -o
        nitrogen --restore ~/Wallpapers/
        ;;
    2)
        mons -e top
        nitrogen --restore ~/Wallpapers/
        ;;
    *)
        ;;
        # Handle it manually
esac
