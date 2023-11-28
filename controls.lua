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
  PinStyle     = "Both"
})
table.insert(ctrls, {
  Name         = "Username",
  ControlType  = "Text",
  DefaultValue = "admin",
  Count        = 1,
  UserPin      = true,
  PinStyle     = "Both"
})
table.insert(ctrls, {
  Name         = "Password",
  ControlType  = "Text",
  DefaultValue = "",
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
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "ChannelNames",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "PlaylistNames",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "DeviceDetails",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "ChannelDetails",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})
table.insert(ctrls, {
  Name         = "PlaylistDetails",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = 1
})

  -- Individual Devices --
table.insert(ctrls, {
  Name         = "DeviceSelect",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Toggle",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "ChannelSelect",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Toggle",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
table.insert(ctrls, {
  Name         = "PlaylistSelect",
  ControlType  = "Text",
  Style        = "ComboBox",
  PinStyle     = "Toggle",
  PinStyle     = "Output",
  UserPin      = true,
  Count        = props['Display Count'].Value
})
