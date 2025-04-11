table.insert(ctrls, {
  Name         = "code",
  ControlType  = "Text",
  Count        = 1,
  UserPin      = true,
  PinStyle     = "Input"
})

-- Configuration Controls --
table.insert(ctrls, {
  Name         = "IPAddress",
  ControlType  = "Text",
  Count        = 1,
  DefaultValue = "Enter an IP Address",
  UserPin      = true,
  PinStyle     = "Input"
})
table.insert(ctrls, {
  Name         = "Username",
  ControlType  = "Text",
  DefaultValue = "admin",
  Count        = 1,
  UserPin      = true,
  PinStyle     = "Input"
})
table.insert(ctrls, {
  Name         = "Password",
  ControlType  = "Text",
  DefaultValue = "",
  Count        = 1,
  UserPin      = true,
  PinStyle     = "Input"
})
table.insert(ctrls, {
  Name         = "Port",
  ControlType  = "Text",
  ControlUnit  = "Integer",
  DefaultValue = "80",
  Min          = 1,
  Max          = 65535,
  Count        = 1,
  UserPin      = true,
  PinStyle     = "Both"
})

-- Status Controls --
table.insert(ctrls, {
  Name          = "Status",
  ControlType   = "Indicator",
  IndicatorType = Reflect and "StatusGP" or "Status",
  PinStyle      = "Output",
  UserPin       = true,
  Count         = 1
})

-- system configurations --
table.insert(ctrls, {
  Name         = "DeviceNames",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "ChannelNames",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "PlaylistNames",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "DeviceDetails",
  ControlType  = "Text",
  Style        = "ListBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "ChannelDetails",
  ControlType  = "Text",
  Style        = "ListBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "PlaylistDetails",
  ControlType  = "Text",
  Style        = "ListBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "PlaylistLogo",
  ControlType  = "Indicator",
  IndicatorType= "LED",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "LoadLogos",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Input",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "QueryDevices",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Input",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "QueryChannels",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Input",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "QueryPlaylists",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Input",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "AutoPopulate",
  ControlType  = "Button",
  ButtonType   = "Toggle",
  PinStyle     = "Input",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "DebugFunction",
  ControlType  = "Button",
  ButtonType   = "Toggle",
  PinStyle     = "Input",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "DebugTx",
  ControlType  = "Button",
  ButtonType   = "Toggle",
  PinStyle     = "Input",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "DebugRx",
  ControlType  = "Button",
  ButtonType   = "Toggle",
  PinStyle     = "Input",
  UserPin      = true,
  Count        = 1
})
  -- Individual Devices --
table.insert(ctrls, {
  Name         = "DeviceSelect",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "ChannelSelect",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "PlaylistSelect",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "DeviceName",
  ControlType  = "Text",
  Style        = "ListBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "PowerOnChannel",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Details",
  ControlType  = "Text",
  Style        = "ListBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "CurrentContent",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "MACAddress",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Address",--Decoder IPAddress
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Platform",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Type",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Id",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Location",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Room",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Schedule",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Group",
  ControlType  = "Indicator",
  IndicatorType= "Text",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Online",
  ControlType  = "Indicator",
  IndicatorType= "Led",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "EnableDisplay",
  ControlType  = "Indicator",
  IndicatorType= "Led",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "HasDecoder",
  ControlType  = "Indicator",
  IndicatorType= "Led",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "ExternalDisplayConnected",
  ControlType  = "Button",
  IndicatorType= "Toggle",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})

table.insert(ctrls, {
  Name         = "PowerOn",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "PowerOff",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "PowerFb",
  ControlType  = "Indicator",
  IndicatorType= "LED",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "PowerToggle",
  ControlType  = "Button",
  ButtonType   = "Toggle",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "Logo",
  ControlType  = "Indicator",
  IndicatorType= "LED",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})

  -- Third party display modules --
table.insert(ctrls, {
  Name         = "DisplayStatus",
  ControlType  = "Indicator",
  IndicatorType= "Status",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "DisplayIPAddress",
  ControlType  = "Text",
  Count        = 1,
  DefaultValue = "Leave blank to disable",
  UserPin      = true,
  PinStyle     = "Input",
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "DisplayMACAddress",
  ControlType  = "Text",
  Count        = 1,
  DefaultValue = "Leave blank to disable",
  UserPin      = true,
  PinStyle     = "Input",
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "DisplayName",
  ControlType  = "Text",
  Count        = 1,
  UserPin      = true,
  PinStyle     = "Input",
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "DisplayPowerOn",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "DisplayPowerOff",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "DisplayPowerFb",
  ControlType  = "Indicator",
  IndicatorType= "LED",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "CustomPowerOn",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "CustomPowerOff",
  ControlType  = "Button",
  ButtonType   = "Trigger",
  PinStyle     = "Both",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "CustomPowerFb",
  ControlType  = "Indicator",
  IndicatorType= "LED",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})

