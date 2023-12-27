 	-----------------------------------------------------------------------------------------------------------------------
	-- dependencies
	-----------------------------------------------------------------------------------------------------------------------
	rapidjson = require("rapidjson")
  helper = require("Helpers")
	-----------------------------------------------------------------------------------------------------------------------
	-- Variables
	-----------------------------------------------------------------------------------------------------------------------
	local SimulateFeedback = true
	-- Variables and flags
	local DebugTx=true
	local DebugRx=false
	local DebugFunction=false

	-- Timers, tables, and constants
	QueryTimer = Timer.New()
	--Timeout = Properties["Poll Interval"].Value + 10
	
	-- Device specific
	local Path = 'api/public/control'

	local devices = {}
	local channels = {}
	local playlists = {}
	
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
		if DebugFunction then print('GetPowerAndChannel()') end
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

	function SetDevicePower(data, component, control) -- control == 'Power_on', 
		if DebugFunction then print(control..' selected for', data.name, 'type:'..data['type'], 'platform:'..data['platform_name']) end
		--TODO
	end
	
	function UpdateDevice(i, device) -- data is a single device
		if DebugFunction then print('UpdateDevice('..i..')') end
		Controls['Address'][i].String = device['ip']
		Controls['MACAddress'][i].String = device['mac']        
		Controls['Online'][i].Boolean = (device['status'] == 'online')
		Controls['Details'][i].Choices = helper.UpdateItems(device)
		Controls['DeviceSelect'][i].String = device['name']
		Controls['HasDecoder'][i].Boolean = (string.len(device['platform_name']) > 0)
		Controls['Enabledisplay'][i].Boolean = device['platform_name'] == nil or (string.len(device['platform_name']) < 1)
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
			print('channel: '..status_.channel..', is_tv_playlist: '..tostring(status_.is_tv_playlist)..', power: '..tostring(status_.power)..', playlist: '..tostring(status_.playlist)..', signage: '..tostring(status_.signage))    
			Controls['PlaylistSelect'][i].String = status_.playlist
			Controls['PowerOn'][i].Boolean = status_.power
			Controls['PowerOff'][i].Boolean = not status_.power
			
			if status_.power then -- power on
				if string.len(status_.channel) > 0 and not status_.jobs_pending then -- channel exists, set feedback
          print('channel not empty, power is on, no jobs pending')
          Controls['ChannelSelect'][i].String = status_.channel 
          Controls['CurrentContent'][i].String = status_.channel
					Controls['PowerOnChannel'][i].String = status_.channel
					Controls['CurrentContent'][i].String = status_.channel
				else -- need to force it to a channel
					if status_.is_tv_playlist and Controls['ChannelSelect'][i] and string.len(Controls['ChannelSelect'][i].String) > 0 then --it's on a blank channel, have to clear selector before forcing it
						if string.len(Controls['PowerOnChannel'][i].String) < 1 then -- the power on channel is blank
							Controls['PowerOnChannel'][i].String = Controls['ChannelSelect'][i].String -- give it a channel to return to in a moment
						end
						if data.status == 'online' then
							print("setting power on channel - because the system doesn't recall the previous channel on power up")
							print("playlist: "..status_.playlist..", tv playlist: "..tv_chanel_playlist_id)
							Controls['ChannelSelect'][i].String = "" -- clear the string so we can force an event when we set it again
							Controls['ChannelSelect'][i].String = Controls['PowerOnChannel'][i].String -- force the Event
							Controls['CurrentContent'][i].String = Controls['PowerOnChannel'][i].String
						end
					elseif not status_.is_tv_playlist then
						print('not in TV channel playlist:'..status_.playlist..', clearing the current and startup channels')
							Controls['ChannelSelect'][i].String = "" -- clear the strings
							--Controls['ChannelSelect'][i].String = status_.playlist -- try inserting the playlist name
							Controls['PowerOnChannel'][i].String = ""
							 Controls['CurrentContent'][i].String = status_.playlist
					end
				end
			else -- power off
				if string.len(Controls['ChannelSelect'][i].String) > 0 then
					Controls['ChannelSelect'][i].String = status_.channel -- clear the string so we can force an event when we set it again
					Controls['CurrentContent'][i].String = status_.channel
				end
			end
			if string.len(status_.channel) > 0 and not status_.jobs_pending then
				print('channel not empty')
				Controls['PowerOnChannel'][i].String = status_.channel
			end
		end

		-- EventHandlers
		--print('assigning EventHandlers')
		Controls['ChannelSelect'][i].EventHandler = function(ctl) -- channel select
			print('channel selected "'..ctl.String..'" for '..device['name']..' type: '..device['type']..' platform: '..device['platform_name'])
			if string.len(ctl.String) > 0 then
				--get channel uri
				local kvp_  = { ['name'] = ctl.String }
				local i, channel_ = helper.GetArrayItemWithKey(channels, kvp_)
				if channel_~=nil then
					PostRequest("/devices/"..device['mac'].."/commands/channel", '{"uri":"'..channel_['uri']..'"}')
				else
					print('channel', type(i))
				end
			end
		end

    Controls['DeviceSelect'][i].EventHandler = function(ctl) -- ctl is the name of the 
      print('device selected',  ctl.String) -- e.g. 'Bar 1', we don't know what module it came fromDoFunctionOnDevice
      DoFunctionOnDevice(AssignDevice, 'Device_Select', ctl.String)
    end
	end
	

	function SetControl(data, control, value) -- (table, 'Power_On', true) -- data is a single device
		if DebugFunction then print('SetControl()') end
		--TODO
	end

	function AssignDevice(i, device) -- device is a single device
		print('AssignDevice('..i..'): ', device['name'])
		if device.name then
      Controls['DeviceSelect'][i].String = device['name'] -- assign it to a device
      --print('assigned ['..i..'] name:', device[i]['name'], 'to device', Controls['DeviceSelect'][i].String..i)
      UpdateDevice(i, device)
    end
  end
	
	function CheckContent(device) -- device is a single device
		if DebugFunction then print('CheckContent()') end
		--TODO
	end

	function UpateDeviceData(i) -- i is the index in devices[i]
		if DebugFunction then print('UpateDeviceData('..i..')') end
		--Controls['DeviceSelect'][i].Choices = Controls.DeviceNames.Choices -- update the device selector choices
		
		-- find all components with the same id
		local found_ = false
		for j=1, #Controls['DeviceSelect'] do --iterate through all devics in data
			-- look for ID in Device_details
			if not found_ then
        if Controls['DeviceSelect'][j].String == devices[i].name then
 					UpdateDevice(j, devices[i]) --update existing device
  				found_ = true
        elseif #Controls['Details'][j].Choices>0 then -- if device Control exists
					local id_ = helper.GetChoicesItem(Controls['Details'].Choices, 'id') -- this will return the id of the component device, e.g. '657536578'       
					print('Control['..j..']: "'..id_..'", device['..i..']: "'..devices[i].id..'"')
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
        if string.len(Controls['DeviceSelect'].String) < 1 then -- an unassigned component
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
				UpateDeviceData(i)
				found_ = true
			end
		end
		if not found_ then
			table.insert(devices, data) 
			UpdateDeviceNames(devices)
			UpateDeviceData(#devices) -- update the last device
		end
	end

	function ParseDevices(data)  -- data is an array of devices
		if DebugFunction then print('ParseDevices', #data.. ' devices found') end
		devices = data
		UpdateDeviceNames(devices)
      --[[ DON'T iterate through devices and assign devices, because it causes a maximum execution error
      -- let it poll the devices one at a time so each device is assigned on a different task
      for i=1, #data do --each device
        UpateDeviceData(i)
      end ]]
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
      if Controls["ChannelSelect "..i]~=nil then -- if device component exists
        Controls["ChannelSelect "..i].Choices = names_ -- update the device selector choices
      end
      if Controls["PowerOnChannel "..i]~=nil then -- if device component exists
        Controls["PowerOnChannel "..i].Choices = names_ -- update the device selector choices
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
    if DebugFunction then print('--------------------------------------') end
    helper.TablePrint(details_)
    --print("name: "..channel.name)
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
		end
    Controls.PlaylistNames.Choices = names_
    for i=1, #devices do -- update list in the device modules
      if Controls['PlaylistSelect'][i]~=nil then
        Controls['PlaylistSelect'][i].Choices = names_ -- update the device selector choices
      end
    end
	end
  
  function UpdatePlaylistControlDetails(playlist)
    if DebugFunction then print('PLAYLIST --------------------------------------') end
    Controls.PlaylistDetails.Choices = helper.UpdateItems(playlist)
    --if DebugFunction then print('get image url: '..playlist.img) end
    local url = 'http://'..Controls.IPAddress.String..playlist.img
		if DebugTx then print("Sending GET request: " .. url) end
    -- not using GetRequest() because it formats the '?' and '=' badly
    HttpClient.Download({ 
			Url          = url,
			Method       = "GET",
			Headers      =  { ["Accept"] = "*/*" } ,
			User         = Controls["Username"].String or "",  -- Only needed if device requires a sign in
			Password     = Controls["Password"].String or "",  -- Only needed if device requires a sign in
			Timeout      = RequestTimeout,
			EventHandler = ResponseHandler
		})
    --local logo_ = 
    --Controls.PlaylistLogo.Style = rapidjson.encode({IconData = logo_})
  end
	-----------------------------------------------------------------------------------------------------------------------
	-- Parse initial response
	-----------------------------------------------------------------------------------------------------------------------
	function QueryAll()
		if DebugFunction then print('Query all ('..#devices..')') end
		if #devices>0  then
      for i=1, #Controls['DeviceSelect'] do GetRequest(Path.."/devices/"..devices[i]['mac']) end
    else 
      GetRequest(Path.."/devices")
    end
    Timer.CallAfter(function() GetRequest(Path.."/channels") end, 1) --wait 1 sec to avoid maximum execution
		Timer.CallAfter(function() GetRequest(Path.."/playlists") end, 2) --wait 1 sec to avoid maximum execution 
	end

  function ParseImage(img)
    if DebugFunction then print('ParseImage()') end
    Controls.PlaylistLogo.Style = rapidjson.encode({IconData = Crypto.Base64Encode(img)})
    Controls.PlaylistLogo.Color = "#00FFFFFF"
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
		if DebugFunction then print("HTTP Response Handler called. Code: " .. code) end
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
		if DebugFunction then print("GetRequest() called: /"..path) end
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
		if DebugFunction then print("PostRequest() called") end
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
		if DebugFunction then print("initialize() Called") end
		--ClearDevices() -- only do this if you want to reset all the modules
    if Controls.IPAddress.String~=nil and string.len(Controls.IPAddress.String)>0 then
      --GetRequest(Path.."/devices")
      QueryAll()
      Timer.CallAfter(function() QueryAll() end, 2) --wait 1 sec to avoid maximum execution
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
    local kvp_  = { ['name'] = ctl.String }
    local i,playlist_ = helper.GetArrayItemWithKey(playlists, kvp_)
    if playlist_ then
      --print('playlist_ type:', type(playlist_))
      UpdatePlaylistControlDetails(playlist_)
    end
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