 	-----------------------------------------------------------------------------------------------------------------------
	-- dependencies
	-----------------------------------------------------------------------------------------------------------------------
	rapidjson = require("rapidjson")
  helper = require("helpers")
	-----------------------------------------------------------------------------------------------------------------------
	-- Variables
	-----------------------------------------------------------------------------------------------------------------------
	local SimulateFeedback = true
	-- Variables and flags
	local DebugTx=false
	local DebugRx=false
	local DebugFunction=false

	-- Timers, tables, and constants
	QueryTimer = Timer.New()
	--Timeout = Properties["Poll Interval"].Value + 10
	
	-- Device specific
	local Path = 'api/public/control'
  local config_filepath = (System.IsEmulating and 'design' or 'media')..'/logos/channel-logos.json'
  local logos_filepath = (System.IsEmulating and 'design' or 'media')..'/logos/'
local junk = ''
	local devices = {}
	local channels = {}
	local playlists = {}
  local playlist_images = {}
	
	function ErrorHandler(err)
    print('ERROR:', err)
 	end
	-----------------------------------------------------------------------------------------------------------------------
  -- Helper functions
	-------------------------------------------------------------------------------------------------------------------
  -- A function to determine common print statement scenarios for troubleshooting
  function SetupDebugPrint()
    if Properties["Debug Print"].Value=="Tx/Rx" then
      DebugTx,DebugRx=true,true
    elseif Properties["Debug Print"].Value=="Tx" then
      DebugTx=true
    elseif Properties["Debug Print"].Value=="Rx" then
      DebugRx=true
    elseif Properties["Debug Print"].Value=="Function Calls" then
      DebugFunction=true
    elseif Properties["Debug Print"].Value=="All" then
      --DebugTx,DebugRx,DebugFunction=true,true,true
      DebugTx,DebugFunction=true,true,true
    end
  end
	-----------------------------------------------------------------------------------------------------------------------
	-- Device control functions
	-----------------------------------------------------------------------------------------------------------------------
	function UpdateDeviceControlDetails(device) -- selected device, a table of a single device
		if DebugFunction then print('DEVICE ', '--------------------------------------') end	
    --[[ local keys_ = { 'id', 'type', 'ip', 'location', 'name', 'platform', 'state', 'mac', 'room', 'platform_name', 'lock_flag', 'status', 'flatMac', 'last_executed_command', 'jobs', 'content' }
    --Controls.DeviceDetails.Choices = helper.UpdateItemsInArray(device, keys_)  --this is an option to display less data ]]
    Controls.DeviceDetails.Choices = helper.UpdateItems(device)
	end

	function GetPowerAndChannel(device) -- a single device
		if DebugFunction then print('GetPowerAndChannel('..device.name..')') end
    local return_ = { ['channel'] = "", ['power'] = false, ['jobs_pending'] = false, ['playlist'] = "", ['is_tv_playlist'] = false, ['no_content'] = false }
    if type(device.content) == "table" then
      local result_ = xpcall(function()
        if device.content~=nil then
          --TablePrint(device.content, 2)
          if device.content.channel~=nil and device.content.channel.name~=nil then
            --print('channel:', device.content.channel.name)
            return_.channel = device.content.channel.name
            --if device.content.playlist~=nil then tv_chanel_playlist_id = device.content.playlist end
          end         
          if device.content.playlist~=nil then 
            local kvp_  = { ['id'] = device.content.playlist }
            local i, playlist_ = helper.GetArrayItemWithKey(playlists, kvp_)
            if playlist_~=nil and playlist_.name~=nil then
              --print('playlist: '..playlist_.name)
              return_.playlist = playlist_.name
              for i,v in ipairs({ 'tv', 'television', 'channel' }) do
                local x =string.find(string.lower(playlist_.name), v)
                if string.find(string.lower(playlist_.name),v)~=nil then 
                  return_.is_tv_playlist = true
                end
              end
            end          
          end
          if device.content.standby==nil then print('standby is nil') end
          --print('standby state:', device.content.standby, 'type:', type(device.content.standby))
          if type(device.content.standby) == "string" then
            return_.power = not (device.content.standby == "Standby") -- "Unknown" is ON
          elseif type(device.content.standby) == "boolean" then
            return_.power = not device.content.standby
          end
        end
      end
      , ErrorHandler)
      --print('CheckContent result:', result_)

      -- need to look at the jobs to figure out the actual state of the device   
      if device['jobs'] then
        --print(#device.jobs..' jobs Type.'..type(device.jobs))
        if #device.jobs > 0 and type(device.jobs) == "table" then
          local found_successful_job_ = false
          for i=1, #device.jobs do
            --print('job['..i..'].status: '..device.jobs[i].status)
            if device.jobs[i].status~=nil then
              if device.jobs[i].status == "PENDING" then return_.jobs_pending = true end
              if device.jobs[i].status == "SUCCESS" and (not found_successful_job_) and device.jobs[i].params~=nil then
                found_successful_job_ = true
                local params_ = rapidjson.decode(device.jobs[i].params)
                print('successful job['..i..'], params type.'..type(params_))
                if type(params_) == "table" then
                  --if params_.channel.name then print('channel: '..params_.channel.name) end
                  --if params_ and params_.channel and type(params_.channel) .name then 
                  if params_~=nil and params_.channel then -- a channel command
                    --print('type(params_.channel): '..type(params_.channel))
                    if type(params_.channel) == "table" and params_.channel.name then
                      return_.channel = params_.channel.name 
                    end
                  elseif params_ and params_.manifest then -- a signage command
                    return_.channel = "" 
                    --return_.signage = true
                  else
                    if type(params_) == "table" then TablePrint(params_.channel, 2) end
                  end
                else --  type(params_) == "string"
                  return_no_content = true -- probably an audio player
                  return_.channel = "" 
                  --return_.signage = false
                end
              end
            end
          end
        end
      end
    end
    return return_
  end

	function SetDevicePower(display, device, i, command) -- command == 'Power_on', 
		if DebugFunction then print(command..' selected for', device.name, 'type:'..device['type'], 'platform:'..device['platform_name']) end
    print('display type('..type(display)..')')
    --if string.len(device['platform_name']) > 0 then -- it is a decoder so blank it
    local command_=nil
    if display then -- a display module with the command is connected to the display so use it for power
      if command=='Display_off' then 
        if display['PanelOff']~=nil then 
          command_ = 'PanelOff'
        elseif display['PowerOff']~=nil then 
          command_ = 'PowerOff'
        end
      elseif command=='Display_on' then 
        if display['PanelOn']~=nil then 
          command_ = 'PanelOn'
        elseif display['PowerOn']~=nil then 
          command_ = 'PowerOn'
        end
      end
    end
    if command_ then
      print('sending '..command_..' to display component, type:', device['type'])
      SetDisplayCommand(display, command_, true)
    else -- not a decoder, so tell the native device module to power it
      PostRequest(Path.."/devices/"..device['mac'].."/commands/"..command, '') -- this will reset the channel
      --actually don't power it becaue it comes up in the wrong mode
    end
  end
	
	function UpdateDisplayModule(i, device) -- device is a single device
    local component_id = Properties['Display Code Name Prefix'].Value..i                                         -- e.g. 'Display_1'
    local display_ = Component.New(component_id)
    if display_ then
      --print('display['..i..'] #Controls: '..#Component.GetControls(display_))
      display_ = (#Component.GetControls(display_))>0 and display_ or nil
    end
    display_ = (device['platform_name'] == nil or (string.len(device['platform_name']) < 1)) and display_
    print('UpdateDisplayModule('..i..') - ['..component_id..']: '..(display_==nil and 'is nil' or 'exists'))
    Controls['EnableDisplay'][i].Boolean = display_ ~= nil
		--Controls['DisplayIPAddress'][i].String = display_ ~= nil and device['ip'] or ''
		Controls['DisplayIPAddress'][i].IsInvisible = display_ == nil
		--Controls['DisplayStatus'][i].IsInvisible = display_ == nil

    --local decoder_types = { 'UHD Decoder', 'Receiver', 'Media Player' } -- 'sssfp5Lfd'
    Controls['PowerOff'][i].EventHandler = function(ctl) -- power_off
      SetDevicePower(display_, device, i, 'Display_off')
    end   
    
    Controls['PowerOn'][i].EventHandler = function(ctl) -- power_on
      SetDevicePower(display_, device, i, 'Display_on')
    end
    
    Controls['PowerToggle'][i].EventHandler = function(ctl) -- power_on
    --status_ = GetPowerAndChannel(data)
      SetDevicePower(display_, device, i,  ctl.Boolean and 'Display_on' or 'Display_off')
    end  

    if display_ then 
      print("display["..i.."] module exists - updating controls")
      if display_['IPAddress'] then         
        display_['IPAddress'].String = device['ip']
        Controls['DisplayIPAddress'][i].String = display_['IPAddress'].String

        display_['IPAddress'].EventHandler = function(ctl) 
          print('Display IPAddress ['..i..']: '..tostring(ctl.String))
          Controls['DisplayIPAddress'][i].String = ctl.String
        end

      end
      if display_['PanelStatus'] then 
        Controls['PowerToggle'][i].Boolean = display_['PanelStatus'].Boolean
        Controls['PowerOn'    ][i].Boolean = display_['PanelStatus'].Boolean
        Controls['PowerOff'   ][i].Boolean = not display_['PanelStatus'].Boolean
        display_['PanelStatus'].EventHandler = function(ctl) 
          print('Display PanelOnStatus ['..i..']: '..tostring(ctl.Boolean))
          Controls['PowerToggle'][i].Boolean = ctl.Boolean
          Controls['PowerOn'][i].Boolean = ctl.Boolean
          Controls['PowerOff'][i].Boolean = not ctl.Boolean
        end
      end
      if display_['PowerStatus'] then 
        if not display_['PanelStatus'] then 
          display_['PowerStatus'].EventHandler = function(ctl) 
            print('Display PowerStatus ['..i..']: '..tostring(ctl.Boolean))
          end
        end
      end
      if display_['Status'] then 
        Controls['DisplayStatus'][i].Value = display_['Status'].Value
        Controls['DisplayStatus'][i].String = display_['Status'].String

        display_['Status'].EventHandler = function(ctl) 
          print('Display ConnectionStatus ['..i..']: '..ctl.String)
          Controls['DisplayStatus'][i].Value = ctl.Value
          Controls['DisplayStatus'][i].String = ctl.String
        end
      end
    else 
      print("display["..i.."] module doesn't exist - updating controls")
      Controls['DisplayIPAddress'][i].IsInvisible = true
      Controls['DisplayIPAddress'][i].String = ''
      --Controls['DisplayStatus'][i].IsInvisible = true
      Controls['DisplayStatus'][i].Value = 3 -- 3: not present
      Controls['DisplayStatus'][i].String = 'No display connected'
      --display_['IPAddress'].String = ''
    end
  end 

	function UpdateDevice(i, device) -- device is a single device
		if DebugFunction then print('UpdateDevice('..i..'): '..device['name']) end
		Controls['Address'][i].String = device['ip']
		Controls['MACAddress'][i].String = device['mac']        
		Controls['Online'][i].Boolean = (device['status'] == 'online')
		Controls['Details'][i].Choices = helper.UpdateItems(device)
		Controls['DeviceSelect'][i].String = device['name']
		Controls['DeviceName'][i].String = device['name']
		Controls['HasDecoder'][i].Boolean = (string.len(device['platform_name']) > 0)
    UpdateDisplayModule(i, device)
    if string.len(Controls['Details'][i].String) > 0 then
			Controls['Details'][i].String = helper.GetValueStringFromTable(device, Controls['Details'][i].String)
		else
			Controls['Details'][i].String = helper.GetValueStringFromTable(device, "mac: ")
		end
		if string.len(device['platform_name']) > 0 then
			Controls['Platform'][i].String = device['platform_name']
		end
	
		--CheckContent(device)
		--print('trying to update channel from device')
		local status_ = {}
		if type(device.content) == "table" then
			status_ = GetPowerAndChannel(device)
			if DebugFunction then print('channel: '..status_.channel..', is_tv_playlist: '..tostring(status_.is_tv_playlist)..', power: '..tostring(status_.power)..', playlist: '..tostring(status_.playlist)..', signage: '..tostring(status_.signage)) end
			Controls['PlaylistSelect'][i].String = status_.playlist
			Controls['PowerOn'][i].Boolean = status_.power
			Controls['PowerOff'][i].Boolean = not status_.power
			
			if status_.power then -- power on
        if status_.playlist and #status_.playlist>0 then
          if DebugFunction then print('is playlist: '..#status_.playlist) end
          local kvp_  = { ['name'] = status_.playlist }
          local p, playlist_ = helper.GetArrayItemWithKey(playlists, kvp_)
          if p then Controls['Logo'][i].Style = playlist_images[p] end
          Controls['Logo'][i].Color = "#00FFFFFF" -- transparent
        else
          if DebugFunction then print('not playlist: '..status_.playlist) end
          Controls['Logo'][i].Style = ""
          Controls['Logo'][i].Color = "#808080" -- grey
        end
				if string.len(status_.channel) > 0 and not status_.jobs_pending then -- channel exists, set feedback
          if DebugFunction then print('channel not empty, power is on, no jobs pending') end
          Controls['ChannelSelect'][i].String = status_.channel 
          Controls['CurrentContent'][i].String = status_.channel
					Controls['PowerOnChannel'][i].String = status_.channel
          --tv_channel_logos
          get_tv_channel_image(status_.channel, Controls['Logo'][i])
          Controls['Logo'][i].Color = "#00FFFFFF" -- transparent
				else -- need to force it to a channel
					if status_.is_tv_playlist and Controls['ChannelSelect'][i] and string.len(Controls['ChannelSelect'][i].String) > 0 then --it's on a blank channel, have to clear selector before forcing it
						if string.len(Controls['PowerOnChannel'][i].String) < 1 then -- the power on channel is blank
							Controls['PowerOnChannel'][i].String = Controls['ChannelSelect'][i].String -- give it a channel to return to in a moment
						end
						if device.status == 'online' then
							if DebugFunction then 
                print("setting power on channel - because the system doesn't recall the previous channel on power up")
                print("playlist: "..status_.playlist)
              end
							Controls['ChannelSelect'][i].String = "" -- clear the string so we can force an event when we set it again
							Controls['ChannelSelect'][i].String = Controls['PowerOnChannel'][i].String -- force the Event
							Controls['CurrentContent'][i].String = Controls['PowerOnChannel'][i].String
						end
					elseif not status_.is_tv_playlist then
						if DebugFunction then print('not in TV channel playlist: '..status_.playlist..', clearing the current and startup channels') end
            Controls['ChannelSelect'][i].String = "" -- clear the strings
            --Controls['ChannelSelect'][i].String = status_.playlist -- try inserting the playlist name
            Controls['PowerOnChannel'][i].String = ""
            Controls['CurrentContent'][i].String = status_.playlist
            --[[
            local kvp_  = { ['name'] = status_.playlist }
            local p, playlist_ = helper.GetArrayItemWithKey(playlists, kvp_)
            Controls['Logo'][i].Style = playlist_images[p]
            --Controls['Logo'][i].Color = "#00FFFFFF" -- transparent
            ]]--
					end
				end
			else -- power off
				if string.len(Controls['ChannelSelect'][i].String) > 0 then
					Controls['ChannelSelect'][i].String = status_.channel -- clear the string so we can force an event when we set it again
					Controls['CurrentContent'][i].String = status_.channel
          Controls['Logo'][i].Style = ""
          Controls['Logo'][i].Color = "#000000" -- black
				end
			end
			if string.len(status_.channel) > 0 and not status_.jobs_pending then
				if DebugFunction then print('channel not empty') end
				Controls['PowerOnChannel'][i].String = status_.channel
			end
    else 
    	if DebugFunction then print("UpdateDevice - Type("..type(device.content)..") doesn't contain any channel or playlist data") end
      Controls['Logo'][i].Style = ""
      Controls['Logo'][i].Color = "#708090" -- slate grey
			Controls['PowerOn'][i].Boolean = false
			Controls['PowerOff'][i].Boolean = false 
      Controls['CurrentContent'][i].String = ""
		end

		-- EventHandlers
		--print('assigning EventHandlers')
		Controls['ChannelSelect'][i].EventHandler = function(ctl) -- channel select
			if DebugFunction then print('channel selected['..i..'] "'..ctl.String..'" for '..device['name']..' type: '..device['type']..' platform: '..device['platform_name']) end
			if string.len(ctl.String) > 0 then
				--get channel uri
				local kvp_  = { ['name'] = ctl.String }
				local j, channel_ = helper.GetArrayItemWithKey(channels, kvp_)
				if channel_~=nil then
					PostRequest(Path.."/devices/"..device['mac'].."/commands/channel", '{"uri":"'..channel_['uri']..'"}')
          Controls['CurrentContent'][i].String = ctl.String
				end
			end
		end
    
    Controls['PlaylistSelect'][i].EventHandler = function(ctl) -- playlist select 
      if DebugFunction then print('playlist selected',  ctl.String..'" for '..device['name']..' type: '..device['type']..' platform: '..device['platform_name']) end
      if string.len(ctl.String) > 0 then
        --get playlist id
        local kvp_  = { ['name'] = ctl.String }
        local j, playlist_ = helper.GetArrayItemWithKey(playlists, kvp_)
        if playlist_~=nil and playlist_['id']~=nil then
          PostRequest(Path.."/devices/"..device['mac'].."/playlists/"..playlist_['id'], '')
        end
      end
    end
	end
	
	function SetDisplayCommand(display, command, value) -- (table, 'Power_On', true) -- data is a single device
		if DebugFunction then print('SetDisplayCommand('..command..','..tostring(value)..')') end
		if display[command] then -- if component control exists
      if type(value) == 'boolean' then
        display[command].Boolean = value
      elseif  type(value) == 'string' then
        display[command].String = value
      elseif  type(value) == 'table' then
        display[command].Choices = value
      else
        display[command].Value = value
      end
    end
	end

	function AssignDevice(i, device) -- device is a single device
    if DebugFunction then 
      if device then print('AssignDevice('..i..'): ', device['name'])
      else           print('AssignDevice('..i..'): device is nil') end
    end
		if device and device.name then
      Controls['DeviceSelect'][i].String = device['name'] -- assign it to a device
			Controls['DeviceName'][i].String = device['name']
		  --print('assigned ['..i..'] name:', device[i]['name'], 'to device', Controls['DeviceSelect'][i].String..i)
      UpdateDevice(i, device)
    end
  end
	
	function CheckContent(device) -- device is a single device
		if DebugFunction then print('CheckContent()') end
		--TODO
	end

	function UpdateDeviceData(i) -- i is the index in devices[i]
		if DebugFunction then print('UpdateDeviceData('..i..')') end
		--Controls['DeviceSelect'][i].Choices = Controls.DeviceNames.Choices -- update the device selector choices
		--if DebugFunction then print('#Controls["DeviceSelect"]:'..#Controls['DeviceSelect']) end
		-- find all components with the same id
		local found_ = false
		for j=1, #Controls['DeviceSelect'] do --iterate through all devics in data
			-- look for ID in Device_details
	 		--if DebugFunction then print('Controls["DeviceSelect"]['..j..']:'..Controls['DeviceSelect'][j].String..' - checking for ID - found_: '..tostring(found_)) end
		  if not found_ then
        if Controls['DeviceSelect'][j].String == devices[i].name then
 		      --if DebugFunction then print('UpdateDevice('..j..',devices['..i..'])') end
					UpdateDevice(j, devices[i]) --update existing device
  				found_ = true
        elseif Controls['Details'][j].Choices == nil then
 		      if DebugFunction then print('Controls["Details"]['..j..'].Choices == nil') end
        elseif #Controls['Details'][j].Choices>0 then -- if device Control exists
					local id_ = helper.GetChoicesItem(Controls['Details'][j].Choices, 'id') -- this will return the id of the component device, e.g. '657536578'       
				  --print('Control['..j..']: "'..id_..'", device['..i..']: "'..devices[i].id..'"')
					if (id_ and id_ == devices[i].id) or Controls['DeviceSelect'][j].String == devices[i].name then -- if this matches the device update it
						--print('Update ['..i..'] '..Controls['DeviceSelect'][j].String)
						UpdateDevice(j, devices[i]) --update existing device
						--AssignDevice(j, devices[i])
						found_ = true
					end
				end
			end
		end
    
  if not found_ then -- this is a new device, put it into the next empty component
    print('NEW DEVICE ['..i..'] '..devices[i].name..' id: '..devices[i].id) --found the device, now find all matches
    found_ = false
    for j=1, #Controls['DeviceSelect'] do --iterate through all devics in data
      if not found_ then -- go until an empty one is found
        if string.len(Controls['DeviceSelect'][j].String) < 1 then -- an unassigned component
          AssignDevice(j, devices[i])
          found_ = true -- stop looking for more unassigned components
        end
      end
    end
    if not found_ then
      print('NOT ASSIGNED ['..i..'] '..devices[i].name..' id: '..devices[i].id) 
    end
  end


	end

  function UpdateDeviceNames(data)  -- data is an array of devices
    local names_ = {}
    local assigned_idx_ = 0
    for a,b in ipairs(data) do --iterate through devices and create a table of names to update Choices
      if b['name'] then table.insert(names_, b['name']) end   
      --[[ -- this is just for debugging
      if b['name'] then  print('[1].name: ',b['name']) end
      if b['ip'] then table.insert(uris_, b['ip']) end   
      if b['mac'] then table.insert(macs_, b['mac']) end
      for k,v in pairs(b) do
        if a == 1 then print('['..a..']', k) end --print all keys
      end --]]
      -- assign unassigned devices to unassigned controls
      -- look for the first control that is either empty or contains this device
      for i=1, #Controls['DeviceSelect'] do
        if Controls['DeviceSelect'][i].String=="" then AssignDevice(i,data[i]) break --unassigned so assign
        elseif Controls['DeviceSelect'][i].String==b['name'] then break end -- assigned so stop looking
      end
    end
    Controls.DeviceNames.Choices = names_
    for i=1, #Controls['DeviceSelect'] do
		  Controls['DeviceSelect'][i].Choices = Controls.DeviceNames.Choices -- update the device selector choices
    end
  end
	-----------------------------------------------------------------------------------------------------------------------
	-- Parse devices
	-----------------------------------------------------------------------------------------------------------------------
	function ParseDevice(device)  -- data is a single device
		if DebugFunction then print('device data response: '..device['name']) end
		local found_ = false
		for i=1, #devices do --each device
			if devices[i]['id'] == device['id'] then
				if DebugFunction then print('Updating data in device ['..i..']: '.. devices[i]['name']) end
				devices[i] = device -- replace device
				--CheckContent(devices[i]) -- this works
				UpdateDeviceData(i)
				found_ = true
			end
		end
		if not found_ then
			table.insert(devices, data) 
			UpdateDeviceNames(devices)
			UpdateDeviceData(#devices) -- update the last device
		end
	end

	function ParseDevices(data)  -- data is an array of devices
		if DebugFunction then print('ParseDevices', #data.. ' devices found') end
		devices = data
		UpdateDeviceNames(devices)
      --[[ DON'T iterate through devices and assign devices, because it causes a maximum execution error
      -- let it poll the devices one at a time so each device is assigned on a different task
      for i=1, #data do --each device
        UpdateDeviceData(i)
      end ]]
	end
  
	-----------------------------------------------------------------------------------------------------------------------
	-- TV channel logos
	-----------------------------------------------------------------------------------------------------------------------
  local tv_channel_logos = {
    Nightlife = {
      url = "https://www.nightlife.com.au/wp-content/uploads/2021/11/LOGO_BRAND_LIGHT.png",
      file = ""
      -- "{\"IconData\":\"iVBORw0KGgoAAAANSUhEUgAAAwAAAAMACAMAAACkX/C8AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAADNQTFRFR3BM////////////////////////////////////////////////////////////////z9GKYQAAABB0Uk5TADCfIBDvYIC/QM/fUHCvj7ZgoNsAACAASURBVHja7N0JttwqEkVRNYBQr/mPtr7t71quZXVZL5XvBnH2CMiEoBMEVQUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP5UdzluCsZlbqkOfFYaNiVNT5Xgg72/VvP/GQKBasGHdJugWFMx+Ihm05SoGjhu/0QA3M5/mAXhU+vfTdjAShgPG5QDYOuoIDwqSbf/LTIEwPEAwBAAxyuAn+ciqCP43AL6FxtBeFCWD4CZSsJzonwArFQSniPf/rdMJYEAAJ7QEgBgBCAAQACoWqgkPGeQDwA+BeNBjXwATFQSnpPkA4DTcHhQUP8S1lBH8DwHIj0KHtVqDwFsguJh2udBOQuKpynvhLIHCs+TID6C4QNq1QggJwQ+EwGj5g4o7R+fERbBfBBcBcPn9GqDQMMTAfhsCDQ6S4FxpfnjG2IgdQomWj8AAAAAAAAAAAAAAAAAAMD/o54kToP25d8E62eFPzqRdOnP1t/o3IkZ5oJPRIckdP9uSbT8X11S5kLwZ3RiKQhGQuCfTmkVvBNcZMUo5h/I7i8gtZq5sQrMi6uZjDs6T0Evmxeoof1/iOtpkHCG9Ib2zzMkj1N+LL6o3EC18B8d/a4DtLNDl1Qv0u+xuc1DH3gfgJ7G8zJAvFoKeiFG/DGq0WkA8EYYK+DSuppXTOrVspXyTy8bXY0g/XeCS+mY5P9on3MgXor/kF7+j95c7oTqV0shzyTpv0jucxGgXy2FbIR2+v90IgAIAM8B0BEABAABQAAQAE4DYCIA2J52/MHF5yI4y1dLIQdCa/0AcPkqrf7IXBfyT6ufOdkGlx/C5DumYr5Pyn9zd7kGrqqRavkM+U/BTq/EiH+hjOVMTMWXWz7PwskPAQWNyz0DAPXy8gqgpJ2JhZ6GjSCnW0A/BeGjt0PlmO7+RGHHs2QTMG1DqIgA2r/bCHDe/qtqVayVWOCnec0klNl7+/9nJay3F7SUWSt6K644V6iqpBUCudiTWa3WhDN2dP+/J6iryPgc81z0pnRIi0hvMzaJ5v+/ddN/Pyfdzff/0S3tHQAAAAAAAAAAAAAAAACAwrRTt+Tv13TFHwit51Xgj87dXNPqfwtJ6bbeUnAMtKvQzeCx41D0T7Pade1Sr4S1chkIVu7EaN7VXkv8p5NgXog4eW//otk6CkzWIZqAxvm1+F41X1NxESCbgqyh/ydh3/NW2T/a5xOp/27/KKeHLmodIP1MmN8N0VW5Wkp6uC1IP5I0em3/rXT7L2kSJP4cm9eFsPrTVRMDAEPAk9Ui3v63pZR/elb/p32ug5N6tRTzeu1AV8MMyPEcSH6o3aLLABjl66WQx6vkX0l1uhOqXy2ZJQBbzgQAm6BshBIABACTTQKAACAACAACgDXAe0T5ainkPFxPAEjK8tVSyAfKVj8AXH4H0N+dK+XStvwXl+wyAOQ7pmKOg67q/7TT46CZaqGrKerQVVmLsxjoaj7D7bXgzADAEFBUT/NqvSjvhBa1MOvoaSQJXwmIZeXtG5gAsT/xUvsv7IBukI2AwXd6xI727zsCsvf0oIoZK7ehwAsaQfIG3lq51y5y3X+hZxMnuS/CY0/7//E9YNFq/uWmrU9SITAk2v7v4Tk1Et8ExrwWnq+77haJxcCwzDyPAQAAAAAAAAAAAAAAAAAAgEJMXRY4Dx3z0t2+C9bOTRY4Xj/kNb1wq7BNEqUeXyt14dpG6Vrk2N2pmSR1xXa5ebMqZYulLpzeXdV4mahG73JhvnG9pNcrdU377xUvxZ+nKtC8Xn4ZtZIpaDrv7V80NdZZWhTVBCPnCaZslpr2rxcBuimmGoPt33kETJusw4ytwkkGT+YTi26pHUeAxeS40mlmD7dVpF/jmdwGgHZ69N2sNbV0kceDYYv06JobQJt2a7IXs0eToMZkqRkA9IaAWrzI0eAA4HYIsPhIXrPZC1oDj+T5zJFo8ZlU+ce9d7dU5J9JXVwGwLKZ65hq+SJHi0Ot04ey5fulv5PXJ/2m1JrbbPjB5Zkg/WrJpj4CHH4KsFlqAoAA8BMAHjdCWwKAAHD9JYAAIAB+mwkAAuCxAJhNlppdIMGBedJvSoFdIL4DPPYdQH/dsneAKfAdQFIy2JvKj1q7X4IH9VL7/BIs351mg6dqJpOHTpy+l9rYqxb1oB05DWqIxfsAjcmulPsADAFvmk1I3+LcO8D9axksXerRbY446Xo5WJhJz6drkxsOjhPECR8vHoK9YSuZHGxd58bSzQt0OCwbzbDTmCy1gwiItvr/HxGwmOxJRSNgrZyrFTvU5XxZpngkKF5m11FcvcRUoVMbBMbLtlTLJbRobuyktHqlbmn+P+YUndIJg3yrU+qV5kFxvdmQeqV5UKT5/9GlzmtW0E2396TD1C0KRW66l7YRe5OlBgAAAAAAAAAAAAAAAAAAAHTVXda4FTMu6e556KkRucuW1xdSy06rTKkn2v2/0mDumlK7Sl1jG+dbYRu0Lt+NXaDxS14KvrxfKHeL88Y1zqqa5UodGQU0E02Np5OKVjIxylV6kZAVS714HwRU09WcXAyuRfPZDadtqR4tlpr2/20ma+3/vC21JkvN/Ocbp6cHs6Ag/EbG8SwoCL+RkR2vfzdhB5mWpR92OnxsUfphD7/JQbWf7tmtF+03DY4ymoq/xOA1P5D4I2G7rUn8kbCDSVA2WWoGAL0hQP3F0f0hoBYvtdMhQL5aRku7Vmfbt/KldvlQvIFn1//eCIrqRd5910b+cdfBZQDkzVzHZODN9b1vACZLXT753vTvxxtm/aa08/li0i+1y0y5+tWS7c3a9pqSgVJPBAAB4DkAPH4LawkAAsBzADACEAC+90H1q2UpIwBmk6XmQ7DgwGxgPyXY+3y9Of0ULP998u+9Cf11y2hyrI2chTPSm8qPWqvJT44+T8MF9S9hi8HpdG2yq3F6N159DrSzMgviRR5MdjWjz/avPqPevaq3muxKxXevktMAEK+X2l5nenS9NkifBx0qt5TXlAcfJ5V3QuPhbqLyTmis/QaAbrKO41wFwpOgk7Wk8Oo9VY7JJtk5yVbTmGxJDe1fMwI0Z6enGfs0x4CrPJsz7V/za4Biop2Ls1mT4Lg1XM6k+9FiqR2Y1CrmOj96UBsE4p3jlEEtqXXsaP2/QmDRqZlxvXUwK8xCO1jL3XmEVKmHxPMAf4zPc6dgeuFYYjtJFLnrX2pHobdYagAAAAAAAAAAAAAAAAAAoC/0Cl4rc61Q5JfTaposdatQ6Mdu74QkcyFgWG/+yrZTOVofl/n20eJ2lkmTmOe7QRBmmeaRuwfS+KpdVBpvXC/pxdJtNrfqxWSpW7Hr/PndqdwFL9he3VRVvMd8fbswCCaGWC/HLsHkacs77/IEzXQdp4OAZi6X4aJaNPNvDOeDQJBMnfbGVF5BNTfcSYeqmmv5vFpUMzCdllo2bdTbkrno5kY8/Im6WQZjMNiUziJAOBHrmxYCygnSD/JMCWdzPMkyq5zT93juJpw6Nr5lN0j6ya2D/lT6tZXDiZt0qVc7698/NoPesQCQTtq9/26P+GMrrcGe5mg+If58xBuWAervDe21Ju2YPXpsS7zU2dz8eHvLszbi1bI3NMu/ttUaHAD23yKRf5Hzy0NArf4Ldx7vXNTLPBvsS/dXAfLvES5fDYB1s9cxyRd5dzah/hzn7nRC/m3X7asBoP8LOzvfAM5qpdYv9c6Om36hv/otQP8XNuaG5d3p9GSxLRmI2rn4AMimdqYPuyUDpZ4qg4NtRwAQAI+1JQKAACAACAACwEcAJAJA0VJGACSLpXYQAGyDPsHUAe7/crkNutr7hUG+yIPJsXa0dRb6OGrLOQz9QzRYK7vDsvwBjtVi//j1A9HqX+ibUg7DyZfa52E4+SVla+tm1UmvZPI4tPgaMX49N4R4a2oMBm1v6x7/aanF1+7veOVe+mjNwa1P6VXAavB27fG5YulVwPCWS/HKq7Nk7xbD8fXyWniwPZxLKF+ZfVNqoKDbMzXW0gKdV8pksdTCYfuuxECyEdCUlhjLZKnLT4xVBc21/ukKJ0lWy1iby8F6PZXQzOcY39f+NfdVxouP3LXguNVc7sq1gn3NZZ5ZxTzE+c3vBKjlv47d9Q5vEuuZ7uXsNllqtZzuY6rerp11utQl3fvAMTUyU4pxvd0l9c1or9T1KlPo2EzVQ/q++3bza4/gtH36/jJP/YtfJCVKnV4sdegnhUK3FQAAAAAAAAAAAAAAAAAAONL2c6dw3u+VMiucUOy6/sXrGbVEqafXSl33EoXun2r9Oge+t2G+d1A36VxVis3tipEq9d2j9b3O1YtteeA6TC125efOjbBO7ILteKsxqd0Iu3W5ahrVmsd7m38QTH8UL5qT4lXty9u1kjeZ89UVE8WkCcM77wT/h70zW2wchKFojMGAsQ3//7XTzkzXmB0SEd/73DQEdIQAIYjWRWFBR0qyybFSTTRrWYhw9Ea0Lkq7OIhs4RfUBaJgTC9fFwiV4R5FAOHyuHo8+29GAOUK2J5nkCnXLDZj1gb1rQNIVw9vsg4YsDo0J11q31dnmXZ1aN9TK6QftjG8QQBE+32A03EZ832AnXart+HmWtfkfQDqL8To4Zj1OVPirTbDxceuyQsxA74RRtyVekJT8m+EnU1cE/VGV6+D8UpkB9nhgmnflhv5VyKr34hhbjjHhHeCHxcDvf47wfR/IV6Kf5TmAamtfime/i88Rlu2n4/KMmKrB6BWvjwA6jUAGKDVCwAAAFcGQAIAAAAAAAAAuCgAGwCgKDbcOdjpSdg2IrYT/UbvL5wK6vmFY26DDmBL/IrboOSP+k686XhR2wg5J6fHd2pEX5N3G4z6DzQDJhXsQ5652/EyWAO558kyxH+hHPBMiQ+YWHx6EEw/7aT+wdRlwGEhDi0bcrl1jJgrZhrcCKNtTXZAaOfx7nE63/XC+dUnAOLj4rnzRtqZenemj+E8DfXzC9XkUjzljSA93j1O/6BQvsq8jrhR3uA+GPE4bxmvwMLKB6ywEzIlulVzRKvicPwYzf7p2tLKRyxBZqYB60aJhsURSUZB4eKgE8l4QvHxSoPGqCVZGjQCbf7VYHrmFCvZSrCgr4gnplBsdTyfbKc3c1l+ayouaSGgEnI8Jlqhm0gbk5nWkkuwOcU8LC0E2HRrr41RmZ+VTPx9866IDIw5lmSXNO8HkVaL9Fbz5SDiIoXa51svTfr5yvx1nECT81MSx2w1hUbzGwRBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEARBEDSKZj2hE56qqdEITBpDmdtldnXvMmwhahpSyl3P4/So3t5avGie/PfM/B8BXdFNO1PC/ZdRcoNlp/Wbcl8y5BDQ7GtQ2QiujS9fHbruKQxo830EtrIvPYT7LVGD02Ukf/WamsnS+aaDU+/P7achChm13cPV/saJ3Vs/xdGk6K6Oe79ByM0ugnLrzsTubTBsz3y9+8TKq5zEz/5aYOQhHWd9RsbGFtKtS7P/iD2f2H8eAdy6sEBARvxT5IG6aT6d2A3hKGg/7U+b6YHeZo30JZJxMWEx7J88PV0maTTPM7VbugGlJxT3r0W3Sre9u7gEh6XnWZhzJJZOs691ZAdUehp8eD/h89+mPOIi68/oaabdZd7gdqfaoSYX2a0uck+z/1SasAIg1mWry3ao7XzDbtW72J4xGU7Z5ny4mt8oXaKwF5oZAdHoMn9Q23336Tt7a/I2yuJtsW/ZIvwjEP+6LdX+Hc7DMi2MRJfpGuOo8v6q8DTJ75FVbgzqXHS3l4tkALAIyAZAkgag61HAJErPHlguALrGBTEHAK4KQM/56fTwQSTNAeqRAGgHAADAwxZGihwAKgMArAGyAdiuCoCu2JbMBmAqN9o5w/4dTD1zn7FzlE0ZAJVnwnUA3MqN1mbYP4Op53aiuF0UAF6zMZwPgP8cYI18l0m3f4FjgFvuDMyuCkDV0Ww+AP6Tg71dBIR00Hw3Ml0VAFmzLZAPgHcvP5bAtsD+e/q743ZVAKpyE/IB8AIXwy15CWCwA5Q/3jSCxqcAUGDDdR9ey25kBDdB2TZxraVUTKI+RGTNt9K9QXENACZRdOtNIebpRwCRDrwGAIWZFzj2bUbA71ETVILGiwBwm377IJMQtzjSO9hjaf/hghiZ61ZXAeDGf66EZcoIuKqLBNDPAdg/fJCxhM5MLgPAOwKfIyDTRgARUGMG9CYXYrUHLwTA5wgkT78A4PV1LQAyBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAwLjiy/H3YFCoSDbrtEj12elGMbkVHWXN+7/vi39htDEfWRWrsssU+sJ/V3GU1c0AmDfJ1McNH6GUXKZhAJj3/y03qSPQFQC9yOPLsN4708rtcYnV8ntujpr8fXZ6/4Hl5jLPP+8EFD0Sdt4YcSxnJ5ucpV3YyAFgY6eX2459HgAA/fNzSj8RgGln3muCSj4iT/IuP3k5nSMCBR1E1lNy93frVGY63Fcq0dndjLs+u0v/tbUAaBYoErguCT+Hv88ef+X/T0J96s0f8nYA2ORKotMuP5oQuAIWb6dPG4tetT8W/mD7PyGAy1hVSJWMqiy5jvTD+bO8tpykv9sqAJZYhSgRS6+cM4oMfv2spREALLUmgTSupJ2pEcFsE2uN9n160kYvKMbNPxg6/WK+MqN2PhLacnz7Adwkr2mTANBrSl2QYImFTbgi3c+UJQDIxDiGr861audZJ+QUmuv4lu4UrVGiU/1AUixoqnZZeOLV7G8vFcr0GjgJAPAjsTPWKa/L0/4prwdgTq1CVGz/8RJDb+afO7l0Q4BFeoNnFARb4wvApWrXTqd32+c1G5NehSUOQIbv9r8WqsotS9YDwBILM+3OtWtneBGeiECfi+MiXCRpyvID8aul3n83l0VrUW/pcbe2CICsBvhqfU0VhiXqARCJ/3p1DdtZNI3f/6YO10d0uPtyo9UYAf46gPFXuHJj0n8EyAz7iADAc/3WOQFVrlXXAqAT/zV3rmE7C6fx9Fm1/AjA81XhgKWYAJ3rLr85zmyX9JeAI/gDcwAoWBSynC4viS3yAdgT/7WuA2DJtrg0Ha33RG3IPpYSSIME7MWnPlPBzokKmEg2AEWbImeR1vFUAGRiWysB8C0CuKr7v6HNhaaZKLrQ/iN7+sWvRE5FO4e2HQCFm4IbNQBSP9EHgHl1tRLTowBYCltoiwBw4fi/cOdcNwOg0GxPSs7KKwCwNHRj6eFVUwDKe0A3B6D4TMa0AqB45j6ILYJTP9FjEdzG/tsS4AWgorGmOQDlUYNsBEBDU3juNmjyJ4xr2M6m9t+0lKyvP7a1C6FlAFT4TGGeDYBpeRBmHwdAy0itMrWi5zrA1x+m7ZhXATD1sMuHAXDvDsq/pkEqRPInauz1dCNENexTwXsD0ClIKwJgHRuAe1NcRCu76ghAxY7NaTKcbdqpK20AVEsAdjc2ACd5R3PJomZtkg6d8Ym0LOCkdoaeQvveBCXfZFVC/GFJA+DN7CkAgIvRATgbK7583DRJuhBzyGWuNOeiT+iPazuJF2J87UwYxWP/5ijmJeoiNGkA9nYAJE6d/wbAUATAFI5AlyuRxV+Xt+LN3McT9yWqY/OP4Q8H4J30xLhQNQMg4XVOY7/dw9PWPAaAsPeOxEBXA0BHzP/UmLnM3mnqB4D5rKYwbyxh3HkrAKITwP195KS7RjUACPY50Wu5ls+H1wEg6JT810jCCZDz4wD4ZWQ8vo2hGwEQix2P017YRUcAzK9b2vHbHerqAASzakJ5wMELeMejADi5h8Bjt7plIwDCW0De/PB47nQpAGdfGbs1Ia4OgCmdHv0X2Fqtg+MAeO53R1LljkYAmMIDwegxTiEA5/nosS3z+doALDWRPCubO5oB4H1AcCk5qMgFQBfafzx2KgNgL+NNXxsAU2XDa9dVQAyAQHa/zTawfABY8eZKzJqLAPAnOYUTveSlAViKzCvFldnuAAQbaPJn/VwARHnwWACoLrb/yGLl2gCoUh8WPUQWvQEIZ93p/FlftrNIVeE5ygCwxQu948oAzNVb+f42b50B2IqjszYA2KotANkWgLV8paeuDIB/bkzN6Zw6LoOVK3RcsTFvAsDqaqyDtwUgtuISACDTTSaf5R79YiBVM+Q8O+zNA4BX7gGzlgDYim+7MgBz9QQQGpipJwDx+WXtC0AghdbUrZ4KAIiO1gIA8iKgjD0cU7oTUgVAnC7bFwBZvgUUjUpyAYh7gxkAZIUvOd7bdkuHUFVOdukLQO3+WSgJNxeAhP0GAJDlhEyGmeoW/yQXAFvRrjYAGFf5u/dmAIhbD2u8AABTm1OszAPXJgAkLDOnvgBUZ4HoZgAoAFAGwFK1jRFv9tQPAF4DZgsAdO0SINS+JhMaAIj2jW3ju1kTjLL6Q9yeDcDmqr2HaQVAypGjBQC5J6312rsBoJ4OgKybncI/LxOAFOIkAMj5WBvJFwbAuurpkwGA5wLAAUA5AJVtC38fAHgIABoAAAAAAAAaA5CcBLgDgOcCIAFAOQCi/ldrAAAAhgXAAQAAENMCAAAAYQCO3gBoAAAACAPQ+xzM3QAAALgwAAcAAABXBkADAJwDXBiAnpfiKQNwAAAA0MT+BwUg+STYAoCXBUCwvsVxnw+A/8q9qf95AOAhAPizEY2s0aabvA4waipEcjq0AQBUD8LUjYQGBSB18nMAgCoAKwCIWaQt6/M0iwYADwFg6XeE9foAyOpVsAQATwZA14ex1wUgVNiNV/46APAYAHjHM6yXByBQdCUtCZA7APBkAAI57TsAiFlkwH6TllALAHg6AKpfGs/rA6Aqk0BWAPB0APw7GQIAxCwy9D5GQvOC91EBwGMACCzkNgAQscitLg9QAYDnAzA72jEQaQCCRWWiq4AgPgDgQQC0fOV0s+pNbOFXASDswyPVhSMPBQOABwFgWyVzbp95LULyiwAQfHs0shUayUMEAA8CYKrcyfjwZz8abqZrADAHbTj4iCtzAIAEAKH3Y9PzgSaTMfavA0D5M8Z/2Luu9dZBGGz28sj7P21jp0k8xLLBK+jifG1PhgH92kg+/i8A2A0A3Xoz9mv+LOxZRn8CANzDxpZsIvV34ygA2AsAZL0Z62KD9icAUDEPH0sSJC8KAI4DgFuN89Ubq34CAP7OYngOgTroGl4BwG4A4I9NCKA4RQzpqgCgAcJcNx9fgNSYPR43AYC5CQBcbnDPyG5rHumspRRnB0Boc0nTp0hibmBfAAABiaJrAMDjyRnH5tJ4jrkZAKh5ZKErAKC7CQAq3xlKZWN/liaLcGEAeCoabg0Av318EQD4x2ToZqnufOYs/Q0AZGowfAkAPGRN7wCAoDPUHVf/q6WqFnLVEd4RAJTdGgBdoI/ToQsDgGQ4Q/MrAMgzZ+o0AAgfIQHkPK4CAE9V1yrCPwOAHLt3HgBELG5Z+nEZAGQwZOvfAYC/ssdqV54fADH6bVEAcx0AJI/mpbGALgKAtQjQF5gPQLeo/esAoEKJ3QD+UwBYhwBNLwAA59V9X/bzQgBIHM9O1VnxKgAIDJbMTeYrACBqZeq6APCW9kae7Y8BoOKxKlSTS4xIqlDMosSFAZASAck6SlwHAPaqKMvz0+oaAKjMegC0lwJAOgTw6vQAqCN5RG/iMNupJAMAzQgAvh4A8V/Zrj1wkwAAlWIn43/HDgYty0SKTL4NbyS03vNdYBgHALIt7S7S89Z6AODUBy43aceVahy2/1O21bWnYZptCoRGBr0Db4eqEAgw4f++OIUWFHNQa3krIj6iQr+yiVY3zdooRFR7H4q38r8kCfnf4YGhTULPxNpMwVoNYS/704DjjsNzUNqdrnbZwpkieD9R6gOvU2Wk6k1mEEvdVNpsWhaKFejtFiP7zWjckVc3DQ1S+HH6MCzooEMTuKtzATh0P036A2fbXYDtSgCTxPxvZZHAZclItai2iNjRHtYd9M16XjIZCQC6Tcjx1YujYQhgJHQ/efoDFyksoH+5Kc/C/tZi49C2Kyr2yGWyXaxQLTopX6xjZCuA2vlIANhez7epU5JKKvJQlaozHLjljWIV26l4CLAc7G+17YITDThyN+GSEFHlIRlpuMKSOHiiJ1ofTqgatob/4SIzZ5509YGrpCUJCEf5AppnmynGtwVaZez+s80GUAIAyAh8arppL0MX51MClrvjwBN76gRWHzjftDdxvtz0WxpSZaQFS7KoRPMiPqbd+4/MXvLfESSxCnW6wEwbc8bKbIhaEGHPCBhrR+TFE2uU68AXq+s2iuUnBnx6wGCelfuHx5hcvo9uPj0NTGq/MGnMDqadOzDpwNy0sVarYvdy0+KQkAxigjrYoA7Y//UHTidH1ybJSCHeWRS1kaLOzvzvPRR46KyDxZpF0Vq0w9u7QLSiZph18PRcsw7LjM8TvSQxF8PTSVGvkXCowZsWR5T4P43hQ4TyPwThr/3sgm2F1Qf+Xp1IapT31+C/i34+lVDnGKN6bRJJ0veFCl2UYis1ChU6MSml4vjW7gKwspuFLkW0+U944YirQPYis7bsaKEr0ThLJIMh0G4rdS1U6CSEV+UNHOX9qOxpocvyf2huqisuQKFb2D/rMvAkoqq4UKHz+r9sXVuMdoeeAoUKZSexrjGMo+dmsYAKXYgsBWLMXfPiarnZlU0tdBkiq66aOy+ekrKrhS5DytP7KsJsir3fUqjQqQFgM4M89+1KIVyhmwDg8TBLCPgGZRcFUOg+AOjvnHwvTVDVeG8Y8EM7vwAAE4VJREFUFQVQ6CZO8Fiq9xTWWqQkwQpdi9LO1mHlJkChaxFOCoCSBC50RxsouLdY2c9CP6wCdDGACl1PBSSbL8jKPYBCFyRe+L/QT1NX+L9QcQMK/xeyEpIj6iou5ffedyuvn/3vCv8XcpGaVruI0TAFHjjj7eR+ACvxn0KOSInoqW8i/CQ+lAP/h7yHBvJ30HGb5guKwiK/QJ9SR/G99yEe9wDAcyWrlYAuBXC/CIDh59eV8nssb+V0NVbE/y8CwLwKf5/eo7wLAJ6WHl7B/hex/mkjW154OBkA+PALef4r7gOA+QCK+7D//6ijUquUDABK9KWP+PXDrVapgserXUiivofdlba9yQDwtP4N6mXK3QDQY6DzxoRYy68U+axLz5bUABiSAX0s6IYAqIaxTNKmCUzbXC3t1XkmGBeKB8Bwl6qrbgqAFwr60VKf25DD6CpRXzLmaQ7vWvR8AtncCwD8dQNQFKlyeiKHT29q7jA4YQaASg4Z0AKA89Oo4vsgXcruUDE1BwAZhmoVAIS5FIIfd/ry6LZF71565uyRA9S9XD8GjQqaA+DzS2FwN/dzbe2ztbcF1B38AOeuGuTS2Riwr4T+f90IHlyWZmhO9h8XGR1TNtQd3bYCX6JvAJ8nQUvmPIXyZ8cXjrKDfWB6hcpZBPS8LAjYfPT6BK1T+NGdS9Upmkci5xxoUfo87cP/ByBAHj3AlRzePljhYROkECj8oMq0nyz8vzsXkuM7N+pjJ4hw7ZkBiqzlX4WJ0537UYPku+M90ENtIGV811cdjXHKVdc0sY8jbQBzggne+LA54kR6L3DP+V8KWbrdp4j/nKODaH0KixanfwrK2xe2NbZHa8BuB62L/0091lh3BQBqRJ1Zu032FWNzVHDtJDF4kTgOinDIvVTsn2LCgTB1fXMAvNRi3su8E7+Kj2Mx+8phepag3tsU79KdoG+koS22M1YB9dQ6QjPc3BIAn+HwGSUiNXOpIo7JBPHzhDTqTuImSQhIBLVmou3DG9yZxn+6Rdzs5s5pPny3C5sfHxOKxHtGn5BShGQXmlQGxRaU42orKKc+tun3880tDaAdWGKsWPXUFNm5FGA336P+DBBkeU0tq2Ez3Vlnu0tITn32p5k4xPejUVA6F8ApWySfDlIAZJ8EFG3MXnEuK/9PtpbMXiU5GYl2tmD10UOjwzI2+wMglz8qlhEHdowCqOeaKM962cpILzcstreGY04zt5j2D6Om7/1n7PFslI/aoofF6/YilD0lNVYAeMqIexcjdDtUYCizNtehrAGckAX1nC0NZAPRKf9/qh/klLExlJ1r7j/yzeRGuFhKJXGQTJHZLSDare8X3Ebfkpn2Ke+XNOpoKQHPf/Io7cTyJWB9Frr/yEOV2ygwSy+jzW6GwMRyW0DWttohb462tSdRm3dGQc8BMEHJ+GIXtykADeiYG/d8/c+P57qeVwO5J3lMMQ7JfRGltsYaVYQkmr6YNlJa8gUdZPHj+RKldXKJGeGE2h52YI+WVDcm8tzifI0NodB7e4xQqTOXoDnqKMc81YiGOt89sjbeJk1Hne7bdy/JXNoQ++SevjD6Lffs94Qor2/N/vuZHV+Xlx9iAI2wuC3iO9wX7Lz8jxWUZBwClwa5fCUDqBTt9Gi+kNHzmF7nqv4gHygeflP69i7GROLzFtdHYjHco+Ni0fb03dZHOPlfqrFdoWZ8DvQEEguPgTqZV0FGO14sUYeFfmWp+s8eeTx6Y9GKkHbPUKyxKBJt5//Xe6A6Smljxm6ekJl61AvISOC/uoWRRwNvtcs9MiSV6I2uZqSA2v579ay3cv1qR6Rlt5SSpK8k1pgA8bfnZxu8FCyEd692nlpiAflitL/xwFrYTaNcSPmKMXecbJK6h/eLEfFBUAEoDApa9lP+l2QmjxcAWHLjvF/XvHh/ljSBVCtgyKvAK6B7dAt7p63/fUElodkSk8Y5i5kT75zeQhx80nh8xtxm0cafwk8FyAfKZ1E9Hd0FnZ8okaJhF4A0gxTiLp3BQRyx5cFM4ugEcrptgnaUrmpnwQMwPArUqAEp9/HfnEEHucNV6UkJ8LyG+7/2epFHZGoRuIK8uBZ6fAqOupuBSljFYgO8m0VGi9rztBSgIBa/7c80snPFeFcN8DGTZCurl0wFRKKIVVQIS40ngUO6j04pVYvxLaOvGA9Ve2IHSTXm3mV16iDUubOmY2zFItvhfs0ma1ZmUqDILBLC9u6oVP0etaYrgqCfLZ20P1uoVQUxRf1w2DWTP4/qKBHgpXKrF4osm9/ADOsMu4rA6o96h+q9kZcPMbq2BZIRJCWU1yBELKRQqrKwqD2nE9PUuMkeXEMCjqo73XECsD+wMgmlcqFYqq+OUvrlzbhdi23zBSRNQepAoDRhztqTFUlmAMC8KSyJFA2txgsAyoIkRAUnQLhrIFK4DtCZa63//aig6Xxzoxno/jdt10ygWgaote6kjvINIriOsraZ5OOqs8Zf4k/c89oqGJuufsRiGcTKBwAYvob55HUMAFrnFkk3ABALe3O4BZSjEfM3Tm5QzPZ3VhtCgOHO8eNjQDNjSImA9tP4pY1FVDysey8sfL3gfwpazcNGCZtwnwlMSXICIJLaFQBAns90AoCaQAszPAYUuJ/k6c8RS0B2aOinv9IemRitpCbWmOUi4SSEwIC7QsT9txFXf9+OYUNDWbXNNJ8MAsAl3jDseX5vw1CftMqkBFYD4LECAOMkommeTEXV5J6SEwCzMvNWCKxhEzM0BhSiNF7xyJ7JAX/hG9CSoJXm9bHFOCOHbAhvYCtQuSQ4hnXjvyE/iZvVtgJRm0TXqAIBYJdQ8yuYtTcOCCihPEpg/hSkF2uLlZi+9I9MsyAqHgAakgjfwCZzAYDMWyMNX6GjbaBvbIr593KcFhnqCKwWKge9FBUMxtZh4WlQyII7Q3xSvXcyGKYWq6p1Mt/XmCHQp1Mr+y95u3MvE8gIrY15RwHgbafNv/W9YRMrhMcDAL7q+zn5zgUADDzP5M+BAKjDA2uL1jadXT1L0MTzfcV3P5s5/8sWkMtgfXALMHBtFwxI2UMtTYAFhKdHq6Dz1kKIVg7UitoT/vLo8C5v2z74k5HlGxXg/awCgARQPir+X76QWvzdL1YDTSAcHAMFevZhu4VAoBgXC/bHZ/YPJuPtqxxlBZMzgSITPFgizJwibjfmG6iYSkWF5KCoKqwwF3nYpLdELPG21qKadCIAzHJmT0NbjvXk8pxHpzE1XVCkR8sCmZNiX9rnr71z225cBYKoBZIAXf3/X3tiJ/EIqG6QLefEce2nWV5JRsI0fStgSatig9Yu0fPxcUim/wkawALmtUfp8lKf6RspCFnkZNagrCHs6y+CAR5KhbUnSOMEXd4saF7dUQagh3K5ASyifKTfpaVsKr8l4WiP7drmk4TX7C5N4bLJ106ncNZyoxE5AAOerateEdIiaCcXPaFKLezd2maN0gtVncD6FANo8eTtBH95hwFEU6Yz8q2kuQF08pLWrN67nVLK22C3/fW0qDRQtkO5Xb0kFTpkL9VzL5+FLjfVAOaqh0tVvY5ykvxVo7w9DAoVA2iEMrJNdJFjrbuwTzAAL0xeX2hu3VkG/ZwgCxRD509lj/J/w2YM7eSEDEKuyPjKvk/NUhhgxSR/0hlWTfNAvdMkFhUR0Fgogt40kHgfs2gA1iuLtp2XqusRYhGw+UEDcMcZAG6Ege3V2VOFg9yfWKqL5klTcWalqOsYqhsNs6ZpsuDRfDYBorqcgQmsnjK2YmCxyM8Gi0BiDvA1mvJgbAZS+3IjrWb7kgYgnhmWavqzp6rVD+5oA8uLtXy0X/yObZjzF+qsra1W5CnARvBlgMtTmzBRsmZrVWS9GFd0st4Qy5kDjvya8ol7Q92SMd/R9/9lBiCL4eLNrJoBPPTq8tQepew20cGEk97Ub27xx1JapbLf3ViMBWlHyB62EZxT/KLaUbiLFFtaRW+7wv8zQFPsy5NbrPCdwgff/5yH+uDy1xqAFlxs9348ywCCsrRbofPiP5KFURz5FaSJVw+yhB1jn3uMBRSe5swLDqLwInZ1a1sRAc2aWiFSZQt7dcGbbCuYmwnmh9voJF50+xDT97B7P9bWi367AWhXInTN0w3AVMQ2AYRGs2gA7v76XKPMf5jzmNRYnTInvCrGQVGFVV4s3pXgsdF1adgVi2pi/fWwOuO9WjbQ1L/NqxpAoq9JwucnG4AmKB1a+DO9OhzpPPMPuKPt/N8+hM3DGg8tyKr+ZSlpzbzi2pJdOcIGmmht8271UvdK2Tk2KR6ypl76AgZwqXwNhRrjkwxAPrd7dC2MaebCq8RVpXFXbcLJv4svDk5bGHoN3RQUmakJybshs53JQtjUqyXhptQAzF5ifFz7/jsN4PLlTatXBuk5VSBpO8K4OeoFq6BaaZ5MD3wtTvTpAa7rNvlsKWjEsq5LngmYs6jfmZVCqvDG6n6//lTjAZq6bsyBitBDDUDcUIdz9uAkuWX2VJPWA7FTH+6IOWAXwkOP1EiTfBWz0J3+yAmRGuq0DnCFzxeGTG+WFkTBLQmgFpxXc6tGQzHPqXJiW+yyxyPvOHuiAUD5Trq3ajIdmHHZJ43s6j/T6pr9h5kBdCbdiBRwVBKkSHt4oD/vKwKg7d+co9HsK6KCrOKQHkSrZZXf+9NAN2MUFLWyCzCFArCkD8u3pnxEq6fTbzUALxWSv3/2qjBONvW04KBIVQs0wXlUsb0lnjPD3BRW5QBChU4ulpu7hz6evUH4m277w3kXGeYfqRPoJHeH0vfr7DNq8yCpek118x//3ADXsH6Jl6yjD/J43AAkPbnPDWCC6xDY0qqqQQccSZcrkG4rXbNFH7Gisscim9ROB2CF4KmVdhW7f80npNUWCl/LWa5TFe/aCq7Xi6djVac9X7PzvRby4RBtcOtla83q+iccIP+4AQT8RRowAgP2xBUhUDSyDj5QuQRpCjXBOK8c0VaPJNI2DziAWZjnXorrb/8Z2LN6lu97SeZagI+/74i8TagzlfIOIWSPpdDe/fS9JAcaAAwDkoUn3Q8QWQA4qS1/qii8nFGhoGwAvtRIb4WETNRWjg8odBc8z81Z8nUwI/x3MIBc/IJpVvwt7YyrnTySdkk1LsJiczkg+QPnpv9t8h9jAHHDbvyIrNtgurNqANFRHUP+KXiqeMX4XFTa7Umh6453deUkYYTzfBDrqv7+kR+E1mySmC4wuDZFA0jUfQ1wQ7vPnh2UorTdHAjq+99+sP8BBmCqdfFdLgCN3bmVn8rGNtV5Y/y+Inwj5tFoivXQRc2ikGBvaQ5LinulsOlgculqPJB4FmF7p7RMKRFdRyy4D6Zw+v0cYABTtQEkpjJ6P+BiAXqqwv6T8gpcPhHrjMNyJ5Valgd681AlOWttBQeLKw4adTtf5t91AjZ9dERzMtmvW7LuOXz8eiaSef2LWw4wALFlPaQ/a9XDDTUtkBgD71BHGSGQKdYfxVuMzg/0p8E9FbFKKltcs4VmiQxpVYsscvjXrOa+DYa2Of0BjjAAQWQ8TGrJVOsDwqdS96lUNMeHUsGmPxcU7YnnmGQhwY422HerLxFI5X+xhfK9gH7hR3SUfwMhiWz2GABugQ8t2CQ67T0e3ZyqLMDtelVXjpRbVJc30iJ+xx7VmwEszvlcF4yOADRIPWrRW/2IjvJvMApOvMNra1sqKP/7BtvN9/BvPbVSIBPdOiM9lSA2qTsur5iwOjhNjJg6dI8sq3pAZ4rFnFuE1IHX8nQAuyu6ics1pc+TIwTSlrvb/nDUZsH7Ada6K5LgL9fFsE0xB4aiDnmZ78+lpKKyDQC8p/AKHcgQDFgHRF/Z9ZzywqrS489TFfnt8yYt/m4vZPiakt9Jb/I37JreczfXX5LXJD2Gca1M4UKpaRpQTamXo/JxVwaS/3chSLJgcV/B7QDFTSsbXvrSYl/puf6D1O9yiimYRb2Hn7cz/vwjvnefx6FuTkNtLx+Ba1Iv+g7jv34c3nR6fSphaW/m9et317n+G3XF9Rqo8nq50PNQCqxWD5T7nr7q78KdGX20IuV+hcv/O7MWdfs+S4JnpdHwUAqsJav6ZVj9eF6aKmdt1219eli5+r83RSVQJO6/zOnowq5slR8O2KAHApVuv9z9UxuKTn5orx3ZF+nJkufSFZtWcbjsBr16ckhlcRX3Ju+Lpcxq+Q0TdZksL9j7Gm115/mViJRjKxdq8ixCuRRudjWal8NK6+FKy++IPJG5vHUk7BJaBPZWyQuxlg1AbKD2qsOYObjk91NzZwo+OEg8W9Y81AQg5CcZa3LWufqwgs8M9tKRmzi25AUobgcT8mDDBZ78AWxl28pUhj+EvBShtm+75vuWCflLBlDomX4prkfTs7lK/qABlLX79t/FPIT8NQPwHAxCAyCEBkAIDYAQGgAhNABC/iyOBkBoADQAQgPgYBAaACE0AELeBVaByHuz0gDIW2MOOMWHkNfl694gx5Eg78nnFbY8Ipm8byq8bG7iI+QN4S5fQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIeQf+A5A8kNwC9txTAAAAAElFTkSuQmCC\"}",
    },
    Keno = {
      url = "https://www.keno.com.au/assets/images/logo-keno.svg",
      file= ""
    },
    ["ABCTV HD"] = {
      url = "https://static.wikia.nocookie.net/logopedia/images/2/25/ABC_TV_2021.svg/revision/latest?cb=20210101035040",
      file= ""
    }
  }

  function write_config(path, tbl)
    local json_string = rapidjson.encode(tbl)
    if DebugFunction then print("write_config size: "..#json_string) end
    --print("write_config: "..json_string)
    if DebugFunction then print("config type: "..type(tbl)) end
    --helper.TablePrint(tbl)
    local file = io.open(path, "w")
    file:write(json_string)
    file:close()
  end

  function get_filename_from_url(url)
    if DebugFunction then print("get_filename_from_url: "..url) end    
    local last_dot_index = url:find("%.[^%.]*$")
    local last_slash_index = url:sub(1, last_dot_index - 1):find("/[^/]*$")
    local filename_ = url:sub(last_slash_index+1)
    --if DebugFunction then print("filename: "..filename_) end
    local filename_ = filename_:match("^[^?=%/]+")
    --if DebugFunction then print("filename: "..filename_) end
    if DebugFunction then print("filename: "..HttpClient.DecodeString(filename_)) end
   return filename_
  end

  function save_logo_to_file(name, data)
    local f = io.open(logos_filepath..name, "wb") 
    f:write(data)
    f:close()
  end

  function get_tv_channel_logo(logo_tbl, key, control)
    url = logo_tbl[key]["url"]
    if DebugFunction then print('get_tv_channel_logo: '..url) end
    HttpClient.Download({ 
      Url          = url,
      Method       = "GET",
      Headers      =  { ["Accept"] = "*/*" } ,
      User         = Controls["Username"].String or "",  -- Only needed if device requires a sign in
      Password     = Controls["Password"].String or "",  -- Only needed if device requires a sign in
      Timeout      = RequestTimeout,
      EventHandler = function(tbl, code, data, err, headers)
        if DebugFunction then print("TV logo HTTP Response code: " .. code) end
        if code == 200 then  -- Vaild response
          if DebugFunction then 
            print('received image for '..key..' #'..#data)
            print('encoded image for '..key..' url: '..url)
          end
          local filename_ = get_filename_from_url(url)
          local image_ = rapidjson.encode({IconData = Crypto.Base64Encode(data)})
          if control then control.Style = image_ end
          if DebugFunction then print('encoded image for '..key..', '..filename_) end
          logo_tbl[key]["file"] = filename_
          write_config(config_filepath, logo_tbl)
          save_logo_to_file(filename_, data)
        end
      end
    })
  end

  function get_tv_channel_image(name, control)
    if DebugFunction then print('get_tv_channel_image: '..name) end
    --print("Nightlife url: "..tv_channel_logos.Nightlife.url)
    if tv_channel_logos['FoxSports503HD'] then
      --print("FoxSports503HD url: "..tv_channel_logos.FoxSports503HD.url)
    else 
      if DebugFunction then print('tv channel config file not loaded') end
    end
    if tv_channel_logos[name] then 
      if DebugFunction then print('channel '..name..' logo exists') end
      if tv_channel_logos[name].file and tv_channel_logos[name].file ~= '' then
        if DebugFunction then print('get_tv_channel_image: '..tv_channel_logos[name].file) end
        local f = io.open(logos_filepath..tv_channel_logos[name].file, "rb")   
        if f~=nil then -- file exists
          local data_ = f:read("*a")
          if data_ and #data_ then
            control.Style = rapidjson.encode({IconData = Crypto.Base64Encode(data_)})
          end
          io.close(f)
        end
      elseif tv_channel_logos[name]["url"] then
        --print('url: '..get_tv_channel_image[name]["url"]) 
        tv_channel_logos[name]["file"] = ''
        get_tv_channel_logo(tv_channel_logos, name, control)
      end
    end
  end

  --Controls.refresh.EventHandler = function(ctl)
    --get_logo(Controls.url.String)
    --get_tv_channel_image("ESPN HD")
    --get_tv_channel_image("Nightlife")
  --end

  function read_config(path, file)
    if DebugFunction then print('read_config: '..path) end
    local f = io.open(path, "r")   
    if f~=nil then -- file exists
      io.close(f)
      local config = rapidjson.load(path)
      if DebugFunction then
        print("config loaded size: "..#config)
        print("config type: "..type(config))
      end --helper.TablePrint(config)
      --print("nightlife url: "..config.Nightlife.url)
      return config
    else 
      if DebugFunction then print('file not found') end
      return nil
    end
  end

  function load_tv_channel_images()   
    tv_channel_logos = read_config(config_filepath) or tv_channel_logos
  end

	-----------------------------------------------------------------------------------------------------------------------
	-- Parse channels
	-----------------------------------------------------------------------------------------------------------------------
	function ParseChannels(data) -- data is an array of channels
		if DebugFunction then print('channel data response: '..#data..' channels found') end
		channels = data
		local names_ = {}
		for a,b in ipairs(data) do
			--if a == 1 then PrintChannel(data[a]) end
			if b['name'] then
				--print('['..a..']', 'name:', b['name'])
				table.insert(names_, b['name'])
			end   
		end  
    Controls.ChannelNames.Choices = names_
    for i=1, #devices do -- update channel list in the device modules
      if Controls["ChannelSelect"][i]~=nil then -- if device component exists
        Controls["ChannelSelect"][i].Choices = names_ -- update the device selector choices
      end
      if Controls["PowerOnChannel"][i]~=nil then -- if device component exists
        Controls["PowerOnChannel"][i].Choices = names_ -- update the device selector choices
      end
    end
	end

  function UpdateChannelControlDetails(channel)
    if DebugFunction then print('CHANNEL --------------------------------------') end
    --[[ this is an option to display less data
    local keys_ = { 'name', 'uri', 'group', 'icon', 'channelid', 'address', 'stream', 'redundancy', 'groups', 'type', 'source', 'interface', 'bandwidth', 'language', 'definition', 'number' }
    Controls.Channel_details.Choices = helper..UpdateItemsInArray(channel, keys_)  --this is an option to display less data ]]
    local details_ = helper.UpdateItems(channel)
    Controls.ChannelDetails.Choices = helper.UpdateItems(channel)
    get_tv_channel_image(channel.name, Controls.PlaylistLogo)

    if DebugFunction then 
      print('--------------------------------------')
      --helper.TablePrint(details_)
      --print("name: "..channel.name)
    end
  end
	-----------------------------------------------------------------------------------------------------------------------
	-- Parse Playlists
	-----------------------------------------------------------------------------------------------------------------------
	function ParsePlaylists(data) -- data is an array of playlists
		if DebugFunction then print('playlist data response: '..#data..' playlists found') end
		playlists = data
		local names_ = {}
		for a,b in ipairs(data) do
			--if a == 1 then PrintChannel(data[a]) end
			if b['name'] then
				--print('['..a..']', 'name:', b['name'])
				table.insert(names_, b['name'])
			end 
      UpdatePlaylistControlDetails(b.name)
		end
    Controls.PlaylistNames.Choices = names_
    for i=1, #devices do -- update list in the device modules
      if Controls['PlaylistSelect'][i]~=nil then
        Controls['PlaylistSelect'][i].Choices = names_ -- update the device selector choices
      end
    end
	end

  function UpdatePlaylistControlDetails(name)
    --if DebugFunction then print('PLAYLIST '..name..'--------------------------------------') end
    local kvp_  = { ['name'] = name }
    local i,playlist_ = helper.GetArrayItemWithKey(playlists, kvp_)
    if playlist_ then
      if DebugFunction then
        --if i~=nil then print('i:'..i) end
        --if playlist_==nil then print('playlist_==nil') end
        --if playlist_.name~=nil then print('name"'..playlist_.name) end
        --if playlist_.img~=nil then print('img"'..playlist_.img) end
      end
      --helper.TablePrint(playlist_,2)
      if Controls.PlaylistNames.String == playlist_.name then
        Controls.PlaylistDetails.Choices = helper.UpdateItems(playlist_)
      end
      --if DebugFunction then print('get image url: '..playlist_.img) end
      local url = 'http://'..Controls.IPAddress.String..playlist_.img
      --if DebugTx then print("Sending image GET request: " .. url) end
      -- not using GetRequest() because it formats the '?' and '=' badly
      HttpClient.Download({ 
        Url          = url,
        Method       = "GET",
        Headers      =  { ["Accept"] = "*/*" } ,
        User         = Controls["Username"].String or "",  -- Only needed if device requires a sign in
        Password     = Controls["Password"].String or "",  -- Only needed if device requires a sign in
        Timeout      = RequestTimeout,
        EventHandler = function(tbl, code, data, err, headers)
          --if DebugFunction then print("HTTP image["..i.."] Response Handler called. Code: " .. code) end
          if code == 200 then  -- Vaild response
            if headers["Content-Type"]~=nil and headers["Content-Type"]:match('^image')~=nil then -- headers["Content-Type"]=="image/png"
              --ParseImage(data, i)
              playlist_images[i] = rapidjson.encode({IconData = Crypto.Base64Encode(data)})
              if Controls.PlaylistNames.String == playlists[i].name then
                --if DebugFunction then print("playlists["..i.."].name: " .. playlists[i].name) end
                --if DebugFunction then print("Controls.PlaylistNames.String: " .. Controls.PlaylistNames.String) end
                Controls.PlaylistLogo.Style = playlist_images[i]
                Controls.PlaylistLogo.Color = "#00FFFFFF" -- transparent
              end
            end
          end
        end
      })
    end
  end
	-----------------------------------------------------------------------------------------------------------------------
	-- Parse initial response
	-----------------------------------------------------------------------------------------------------------------------
	function QueryAll()
		if DebugFunction then print('Query all (total: '..#devices..', defined: '..#Controls['DeviceSelect']..')') end
    GetRequest(Path.."/devices")	
    if #devices>0  then
      for i=1, #devices do
        GetRequest(Path.."/devices/"..devices[i]['mac'])
      end
    end
    Timer.CallAfter(function() GetRequest(Path.."/channels") end, 1) --wait 1 sec to avoid maximum execution
		Timer.CallAfter(function() GetRequest(Path.."/playlists") end, 2) --wait 1 sec to avoid maximum execution 
	end

  function ParseImage(img, idx)
    if DebugFunction then 
      if idx~=nil then 
        print('ParseImage('..idx..')')
        playlist_images[idx] = rapidjson.encode({IconData = Crypto.Base64Encode(img)})
      else
        print('ParseImage()')
        Controls.PlaylistLogo.Style = rapidjson.encode({IconData = Crypto.Base64Encode(img)})
        Controls.PlaylistLogo.Color = "#00FFFFFF"
      end
    end

  end

  function ParseString(str)
		ParseImage(str)
	end

	function ParseResponse(json)
	-- responses from the HTTP server, determine how to parse them here
		local data_ = rapidjson.decode(json)
		if DebugFunction then print('ParseResponse', #json..' bytes') end
		if data_==nil then -- response is a string
			ParseImage(json)
		elseif data_[1]~=nil then -- response is an array
			if data_[1]['mac']~=nil then              -- devices
				ParseDevices(data_)
			elseif data_[1]['channelid']~=nil then    -- channels
				ParseChannels(data_)
			elseif data_[1]['orientation']~=nil then  -- playlists
				ParsePlaylists(data_)
			end
		elseif data_['mac']~=nil then -- response is a table
			ParseDevice(data_)
		end
		data_ = nil
	end
	-----------------------------------------------------------------------------------------------------------------------
	-- HTTP comms functions
	-------------------------------------------------------------------------------------------------------------------------
	-- the core of this is copied from an example so there is some unused stuff
	-- Constants
	local StatusState = { OK = 0, COMPROMISED = 1, FAULT = 2, NOTPRESENT = 3, MISSING = 4, INITIALIZING = 5}  -- Status states in designer
	-- Variables
	local RequestTimeout = 10           -- Timeout of the connection in seconds
	local Port = 80                     -- Port to use (if not 80 or 443)
	-- Functions
	-- Function that sets plugin status
	function ReportStatus(state, msg)
		if DebugFunction then print("ReportStatus() called:" .. state) end
		local msg = msg or ""
		Controls.Status.Value = StatusState[state]  -- Sets status state
		Controls.Status.String = msg  -- Sets status message
	end

	-- Function reads response code, sets status and prints received data.
	function ResponseHandler(tbl, code, data, err, headers)
		if DebugFunction and DebugRx then print("HTTP Response Code: " .. code) end
		if code == 200 then  -- Vaild response
			ReportStatus("OK")
			if DebugRx then print("Rx: ", data) end
			--ResponseText.String = data
			if headers["Content-Type"]~=nil and headers["Content-Type"]:match('^image')~=nil then -- headers["Content-Type"]=="image/png"
        ParseImage(data)
			elseif headers["Content-Type"]~=nil and headers["Content-Type"]:match('^text') then -- headers["Content-Type"]=="text/plain"
				ParseString(data)
      else
			  ParseResponse(data)
      end

		elseif code == 401.0 or Controls.IPAddress.String == "" then  -- Invalid Address handler
			ReportStatus("MISSING", "Check TCP connection properties") 

		else   -- Other error cases
			ReportStatus("FAULT", err) 
		end
	end

	-- Send an HTTP GET request to the defined
	function GetRequest(path, headers)
		if DebugFunction and DebugTx then print("GetRequest("..path..") called") end
		-- Define any HTTP headers to sent
		headers = headers or {
			--["Content-Type"] = "text/html",
			["Accept"] = "*/*"--"text/html"
		}
		-- Generate the URL of the request using HTTPClient formatter
		url = HttpClient.CreateUrl({
			["Host"] = 'http://'..Controls.IPAddress.String,
			--["Port"] = Port,
			["Path"] = path
			--["Query"] = QueryData
		})
    url = 'http://'..Controls.IPAddress.String..'/'..path

		if DebugTx then print("Sending GET request: " .. url) end
		HttpClient.Download({ 
			Url          = url,
			Method       = "GET",
			Headers      = headers,
			User         = Controls["Username"].String or "",  -- Only needed if device requires a sign in
			Password     = Controls["Password"].String or "",  -- Only needed if device requires a sign in
			Timeout      = RequestTimeout,
			EventHandler = ResponseHandler
		})
	end

	-- Send a POST request to the HTTP server
	function PostRequest(path, data)
		if DebugFunction then print("PostRequest("..path.."): "..(data or '')) end
		-- Define any HTTP headers to sent
		headers = {  
			["Accept"] = "*/*"
		}
		if data and #data then headers["Content-Type"] = "application/json" end
		
		-- Generate the URL of the request using HTTPClient formatter
		url = HttpClient.CreateUrl({
			["Host"] = 'http://'..Controls.IPAddress.String,
			["Path"] = path
		})

		if DebugTx then print("Sending POST request to: " .. url, data) end
		HttpClient.Upload({ 
			Url          = url,
			Headers      = headers,
			User         = Controls["Username"].String,  -- Only needed if device requires a sign in
			Password     = Controls["Password"].String,  -- Only needed if device requires a sign in
			Data         = data,
			Method       = "POST",
			Timeout      = RequestTimeout,
			EventHandler = ResponseHandler
		})
	end
	-------------------------------------------------------------------------------
	-- Device functions
	-------------------------------------------------------------------------------
	function initialize()
  	SetupDebugPrint()
		if DebugFunction then 
      print("initialize() Called") 
      helper.GetVersion()
    end
    load_tv_channel_images()
    for i=1, #Controls['DeviceSelect'] do
      Controls['DeviceSelect'][i].EventHandler = function(ctl) -- device select
        print('device selected',  ctl.String) -- e.g. 'Bar 1', we don't know what module it came from       
        local kvp_  = { ['name'] = ctl.String }
        local j, device_ = helper.GetArrayItemWithKey(devices, kvp_) -- get the device in the data
        AssignDevice(i, devices[j])
      end
    end

		--ClearDevices() -- only do this if you want to reset all the modules
    if Controls.IPAddress.String~=nil and string.len(Controls.IPAddress.String)>0 then
      --GetRequest(Path.."/devices")
      QueryAll()
      Timer.CallAfter(function() QueryAll() end, 5) --wait x sec to avoid maximum execution
      if not QueryTimer:IsRunning() then
        QueryTimer.EventHandler = QueryAll
        QueryTimer:Start(Properties["Poll Interval"].Value)
      else
        print("Query timer is already running")
      end
		else
			print("I can't do anything without a Server address!")
		end
    --local logo_ = "iVBORw0KGgoAAAANSUhEUgAAAKoAAAAhCAYAAABJATCZAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAADJGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDYgNzkuZGFiYWNiYiwgMjAyMS8wNC8xNC0wMDozOTo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjY0RDZGODZGM0IwNDExRUM5NkM3QTEzM0NBQjU2Q0NDIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjY0RDZGODcwM0IwNDExRUM5NkM3QTEzM0NBQjU2Q0NDIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6NjRENkY4NkQzQjA0MTFFQzk2QzdBMTMzQ0FCNTZDQ0MiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NjRENkY4NkUzQjA0MTFFQzk2QzdBMTMzQ0FCNTZDQ0MiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4g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"
    --Controls.PlaylistLogo.Style = rapidjson.encode({IconData = logo_})
	end
	initialize()
	-----------------------------------------------------------------------------------------------------------------------
	-- EventHandlers
	-----------------------------------------------------------------------------------------------------------------------
  Controls.IPAddress.EventHandler = function()
    initialize()
  end

  Controls.DeviceNames.EventHandler = function(ctl)
    if DebugFunction then print('device choice', ctl.String, ', num devices:', #devices) end
    local kvp_  = { ['name'] = ctl.String }
    local i,device_ = helper.GetArrayItemWithKey(devices, kvp_)
    if device_ then
      --[[
      print('device_ type:', type(device_))
      print('device_ name:', devices[i]['name'])
      print('device_ id:', devices[i]['id'])
      print('device_ mac:', devices[i]['mac'])
      --]]
      UpdateDeviceControlDetails(device_) -- update 'Decoder_details'
      GetRequest(Path.."/devices/"..devices[i]['mac'])
    end

  end

  Controls.PlaylistNames.EventHandler = function(ctl)
    if DebugFunction then print('playlist choice', ctl.String, ', num playlists:', #playlists) end
    UpdatePlaylistControlDetails(ctl.String)
  end

  Controls.ChannelNames.EventHandler = function(ctl) 
    if DebugFunction then print('channel choice', ctl.String, ', num channels:', #channels) end
    local kvp_  = { ['name'] = ctl.String }
    local i,channel_ = helper.GetArrayItemWithKey(channels, kvp_)
    if channel_ then
      --print('channel_ type:', type(channel_))
      UpdateChannelControlDetails(channel_)-- update 'Channel_details'
    end
  end
	-----------------------------------------------------------------------------------------------------------------------
	-- End of module
	-----------------------------------------------------------------------------------------------------------------------