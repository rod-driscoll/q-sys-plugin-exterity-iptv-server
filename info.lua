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

  -- known issue: if device name is changed in Vitec server then the device needs to be re-selected in the device select drop down.
  -- known issue: you can't select no device, so copying from an existing installation won't clear devices.


PluginInfo = {
  Name = "Exterity~IPTV Server", -- The tilde here indicates folder structure in the Shematic Elements pane
  Version = "1.0.2",
  Id = "exterity-iptv-server.plugin",
  Description = "Plugin controlling Exterity IPTV",
  ShowDebug = true,
  Author = "Rod Driscoll"
}