 	-----------------------------------------------------------------------------------------------------------------------
	-- dependencies
	-----------------------------------------------------------------------------------------------------------------------
	rapidjson = require("rapidjson")

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
      DebugTx,DebugRx,DebugFunction=true,true,true
    end
  end
	-----------------------------------------------------------------------------------------------------------------------
	-- Device control functions
	-----------------------------------------------------------------------------------------------------------------------

	function UpdateDeviceControlDetails(data) -- selected device, data is a table of a single device
		if DebugFunction then print('DEVICE ', '--------------------------------------') end
		--TODO
	end

	function DoFunctionOnDevice(func, control_name, name)
		if DebugFunction then print('DoFunctionOnDevice()') end
		--TODO
	end

	function GetPowerAndChannel(data) -- data is a single device
		if DebugFunction then print('GetPowerAndChannel()') end
		--TODO
	end

	function SetDevicePower(data, component, control) -- control == 'Power_on', 
		if DebugFunction then print(control..' selected for', data.name, 'type:'..data['type'], 'platform:'..data['platform_name']) end
		--TODO
	end
	
	function UpdateDevice(component, data) -- data is a single device
		if DebugFunction then print('UpdateDevice()') end
		--TODO
	end

	function SetControl(data, control, value) -- (table, 'Power_On', true) -- data is a single device
		if DebugFunction then print('SetControl()') end
		--TODO
	end

	function AssignDevice(i, data) -- data is a single device
		print('AssignDevice['..i..']: ', data['name'])
		--TODO
	end
	
	function CheckContent(device) -- device is a single device
		if DebugFunction then print('CheckContent()') end
		--TODO
	end

	function UpateDeviceData(i) -- 
		if DebugFunction then print('UpateDeviceData()') end
		--TODO
	end

  function UpdateDeviceNames(data)  -- data is an array of devices
    local names_ = {}
    for a,b in ipairs(data) do --iterate through devices and create a table of names to update Choices
      if b['name'] then table.insert(names_, b['name']) end   
      --[[ -- this is just for debugging
      if b['name'] then  print('[1].name: ',b['name']) end
      if b['ip'] then table.insert(uris_, b['ip']) end   
      if b['mac'] then table.insert(macs_, b['mac']) end
      for k,v in pairs(b) do
        if a == 1 then print('['..a..']', k) end --print all keys
      end ]]
    end
    Controls.DeviceNames.Choices = names_ 
  end
	-----------------------------------------------------------------------------------------------------------------------
	-- Parse devices
	-----------------------------------------------------------------------------------------------------------------------

	function ParseDevice(device)  -- data is a single device
		if DebugFunction then print('device data response: '..device['name']) end
		local found_ = false
		for i=1, #devices do --each device
			if devices[i]['id'] == device['id'] then
				print('Updating data in device ['..i..']: '.. devices[i]['name'])
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
      if Controls['PlaylistSelect '..i]~=nil then
        Controls['PlaylistSelect '..i].Choices = names_ -- update the device selector choices
      end
    end
	end
	-----------------------------------------------------------------------------------------------------------------------
	-- Parse initial response
	-----------------------------------------------------------------------------------------------------------------------

	function QueryAll()
		if DebugFunction then print('Query all') end
		for i=1, #devices do
			--GetRequest("/devices/"..devices[i]['mac'])
		end
		--GetRequest("/channels")
    GetRequest("/devices")
	end

	function ParseResponse(json)
	-- responses from the HTTP server, determine how to parse them here
		local data_ = rapidjson.decode(json)
		if DebugFunction then print('ParseResponse', #json..' bytes') end
		if data_[1] then -- response is an array
			if data_[1]['mac']~=nil then              -- devices
				ParseDevices(data_)
			elseif data_[1]['channelid']~=nil then    -- channels
				ParseChannels(data_)
			elseif data_[1]['orientation']~=nil then  -- playlists
				ParsePlaylists(data_)
			end
		elseif data_['mac'] then -- response is a table
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
		if DebugFunction then print("HTTP Response Handler called") end
		if DebugRx then print("HTTP Response Code: " .. code) end
		if code == 200 then  -- Vaild response
			ReportStatus("OK")
			if DebugRx then print("Rx: ", data) end
			--ResponseText.String = data
			ParseResponse(data)

		elseif code == 401.0 or Controls.IPAddress.String == "" then  -- Invalid Address handler
			ReportStatus("MISSING", "Check TCP connection properties") 

		else   -- Other error cases
			ReportStatus("FAULT", err) 
		end
	end

	-- Send an HTTP GET request to the defined
	function GetRequest(path)
		if DebugFunction then print("GetRequest() called") end
		-- Define any HTTP headers to sent
		headers = {
			--["Content-Type"] = "text/html",
			["Accept"] = "*/*"--"text/html"
		}
		-- Generate the URL of the request using HTTPClient formatter
		url = HttpClient.CreateUrl({
			["Host"] = 'http://'..Controls.IPAddress.String,
			--["Port"] = Port,
			["Path"] = Path..path
			--["Query"] = QueryData
		})

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
			["Path"] = Path..path
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
    if Controls.IPAddress.String~=nil and string.len(Controls.IPAddress.String)>0 and not QueryTimer:IsRunning() then
			GetRequest("/devices")
			Timer.CallAfter(function() GetRequest("/channels") end, 1) --wait 1 sec to avoid maximum execution
			Timer.CallAfter(function() GetRequest("/playlists") end, 2) --wait 1 sec to avoid maximum execution
			Timer.CallAfter(function() QueryAll() end, 3) --wait 1 sec to avoid maximum execution
			QueryTimer.EventHandler = QueryAll
			QueryTimer:Start(Properties["Poll Interval"].Value)
		else
			print("I can't do anything without a Server address!")
		end
	end
	initialize()

	-----------------------------------------------------------------------------------------------------------------------
	-- EventHandlers
	-----------------------------------------------------------------------------------------------------------------------
  Controls.IPAddress.EventHandler = function()
    initialize()
  end

  Controls.DeviceNames.Choices = { "choice 1", "choices 2" }
	-----------------------------------------------------------------------------------------------------------------------
	-- End of module
	-----------------------------------------------------------------------------------------------------------------------