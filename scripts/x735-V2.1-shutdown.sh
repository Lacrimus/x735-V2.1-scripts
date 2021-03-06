#!/bin/bash

#X735 Shutdown through software

GPIOCHIP=gpiochip0

BUTTON_PIN=18

# Detect all (S)ATA devices
DEVICES=()

PART=$(cat /proc/partitions)

for x in {a..z}
do
   #SATA
   if [[ $PART == *"sd$x"* ]]
   then
      DEVICES+=("sd$x")
   fi
   #ATA
   if [[ $PART == *"hd$x"* ]]
   then
      DEVICES+=("hd$x")
   fi
done

printf "Shutting down all SATA devices... ($DEVICES)"
for d in $DEVICES
do
   sudo hdparm -Y /dev/$d &
   /bin/sleep 0.1
   printf "Device $d off \n"
done

echo "X735 Shutting down..."

#Set internal biases and pull the pin up and shut down. Pull the pin down again in case the command fails
{ gpioset -B pull-up gpiochip0 $BUTTON_PIN=1 && sudo poweroff; } || { gpioset -B pull-down gpiochip0 $BUTTON_PIN=0; tput setaf 1; printf "Aborting shutdown" ; tput sgr0; }