# q-sys-plugin-exterity-iptv-server

Q-Sys Plugin for Exterity IPTV server

Language: Lua\
Platform: Q-Sys

Source code location: <https://github.com/rod-driscoll/q-sys-plugin-exterity-iptv-server>

## Demo project

A working demo Q-Sys Designer project is located at [//demo/Exterity plugin - Demo.qsys](https://github.com/rod-driscoll/q-sys-plugin-exterity-iptv-server/blob/main/demo/Exterity%20plugin%20-%20Demo.qsys)\

The demo project has all dependencies pre-loaded so it ready to load to use.

## Deploying code

### Dependencies

Install dependencies before installing the plugin.\
Dependencies (modules) are stored in the [//dependencies](https://github.com/rod-driscoll/q-sys-plugin-exterity-iptv-server/blob/main/dependencies/) folder

Copy any/all module folders in the dependencies directly to the Q-Sys modules folder on your PC ("**%USERPROFILE%\Documents\QSC\Q-Sys Designer\Modules**") and then in Designer go to Tools > Designer Resources, and Install the module(s).\

For more detailed instructions on installing dependencies follow the instructions in the README located in the dependencies folder.

### The compiled plugin

The compiled plugin file is located in this repo at [//demo/q-sys-plugin-exterity-iptv-server.qplug](https://github.com/rod-driscoll/q-sys-plugin-exterity-iptv-server/blob/main/demo/q-sys-plugin-exterity-iptv-server.qplug)\
Copy the *.qplug file into "**%USERPROFILE%\Documents\QSC\Q-Sys Designer\Plugins**" then drag the plugin into a design.

## Developing code

Instructions and resources for Q-Sys plugin development is available at:

* <https://q-syshelp.qsc.com/DeveloperHelp/>
* <https://github.com/q-sys-community/q-sys-plugin-guide/tree/master>

Do not edit the *.qplug file directly, this is created using the compiler.
"plugin.lua" contains the main code.

### Development and testing

The files in "./testing/" are for dev only and may not be the most current code, they were created from the main *.qplug file following these instructions for run-time debugging:\
[Debugging Run-time Code](https://q-syshelp.qsc.com/DeveloperHelp/#Getting_Started/Building_a_Plugin.htm?TocPath=Getting%2520Started%257C_____3)

## Features

* Get devices
* Get channels
* Get playlists
* Get playlist logos

### Features not implemented

* Power endpoint
* Authentication

### Features not tested

* Trigger channel
* Trigger playlist
* Trigger power

## References

Protocol can be found on any deployed Exterity server at <http://server-ip/docs>

## Contributors

Author: Rod Driscoll <rod@theavitgroup.com.au>
