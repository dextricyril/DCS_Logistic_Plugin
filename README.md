# DCS_Logistic_Plugin

Move troops and ground units dynamically using only the F10 menu. No trigger, special naming required.

## Goals

This project aim is to enable dynamic interraction between helicopter players and ground units while not having to do any manipulation in the Mission Editor. (no naming conventions)

The first goal is to create an easy way to carry troops.
The second goal aims at allowing sling loading ground units by "packing them" in cargo containers.

## Setting it up

This plugin does not require any outside library (it does not need MIST or MOOSE)

In the mission editor create a trigger that will be executed after a few seconds. As its action, it needs to 
**do the script file transportMain.lua**

and that's it :)

## How to use

Having the script run should now add a F10 menu for the helicopter pilots.
If an infantry unit is close you should be able to embark it through this menu.
