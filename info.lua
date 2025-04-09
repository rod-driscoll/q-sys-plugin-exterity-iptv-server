-- Q-Sys plugin for Exterity IPTV server
-- <https://github.com/rod-driscoll/q-sys-plugin-exterity-iptv-server>
-- 20231128 v1.0.0 Rod Driscoll<rod@theavitgroup.com.au>
  -- initial version
-- 20240607 v1.0.1 Rod Driscoll<rod@theavitgroup.com.au>
  -- fix: when more devices defined than exist the channels and playlists now populate all
-- 20240614 v1.0.2 Rod Driscoll<rod@theavitgroup.com.au>
  -- fix: when a display is powered off it sends the power_on command directly to the display as well as the panel_on command
  -- fix: sometimes tv channel logo filenames were being saved wrong in the icon config file
  -- update: clear and update the selected display logo when a new channel or playlist is selected
-- 20240626 v1.0.3 Rod Driscoll<rod@theavitgroup.com.au>
  -- fix: send power command to decoder if the output is a decoder and not a display running the vitec app
  -- fix: when more devices defined than exist the power buttons always works
  -- update: add a blank name to the end of the device list so you can clear a device
  -- update: added LoadLogos button to settings, pressing that will re-load the channels-config.json file
  -- update: added QueryDevices, QueryChannels and QueryPlaylists buttons to settings. These are polled on a timer via PollInterval but you may want to update them manually
  -- update: logos changed to indicators instead of buttons so they can be overlayed on combo boxes for channel select
  -- update: resends a similar inmage after each image to deal with a QSD bug with LED images
  -- update: logos will look for a logo with similar name, searching case insensitive, removing whitespace, sub and super strings  
-- 20240710 v1.0.4 Rod Driscoll<rod@theavitgroup.com.au>
  -- fix: don't load tv channel logo if display is on a non-television playlist
  -- update: keep track of last icon and don't update on poll if not required
  -- update: query devices button clears display icon cache so it forces the icons to update
-- 20240813 v1.0.5 Rod Driscoll<rod@theavitgroup.com.au>
  -- update: removed a few unneccesary whitespaces in lines
  -- fix: log when write files fail
  -- update: changed emulation file path because sub folders aren't working in 9.12.1
  -- update: force to a channel when detecting the player has started and not loaded the previous channel
  -- known issue: there is QSD a bug where images on indicators displays the previous image rather than current
    -- there is currently no way to display logos overlaying combo boxes that works correctly on all UCI platforms
    -- to get a working logo overlaying the combo box; 
      -- create UCI LEDs and copy the component["icon 1"].Legend onto that LED,
      -- and give it a css 'background-color: transparent;' to hide the LED circle gradient
      -- logos won't work in QSD so you'll need to test the icons are working on a live core with UCI viewer or a touch panel
  -- update: playlist name added to currentContent
  -- update: don't clear PowerOnChannel if there are no channels or playlists running
-- 20250331 v1.0.6 Rod Driscoll<rod@theavitgroup.com.au>
  -- update: added https support (enter 443 as the port number for https).
  -- update: after a player is powered on and blank, check all previous commands then set player to the last successful channel in player log
  -- update: only turn decoder off if there is no connected display

PluginInfo = {
  Name = "Exterity~IPTV Server", -- The tilde here indicates folder structure in the Shematic Elements pane
  Version = "1.0.6",
  Id = "exterity-iptv-server.plugin",
  Description = "Plugin controlling Exterity IPTV",
  ShowDebug = true,
  Author = "Rod Driscoll"
}