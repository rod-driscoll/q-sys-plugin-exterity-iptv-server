local CurrentPage = PageNames[props["page_index"].Value]
	
local colors = {  
  Background  = {232,232,232},
  Transparent = {255,255,255,0},
  Text        = {24,24,24},
  Header      = {0,0,0},
  Button      = {48,32,40},
  Red         = {217,32,32},
  DarkRed     = {80,16,16},
  Green       = {32,217,32},
  OKGreen     = {48,144,48},
  Blue        = {32,32,233},
  Black       = {0,0,0},
  White       = {255,255,255},
  Gray        = {96,96,96}
}

layout["code"]={PrettyName="code",Style="None"}  

--local lbl_ = { Position={9,27},Size={128,16}, Type="Text", FontSize=11, HTextAlign="Right" }
--local txt_ = { Position={lbl_.Position[1] + lbl_.Size[1] + 4, lbl_.Position[2]}, Size={lbl_.Size[1],lbl_.Size[2]},Style="Text",Color=colors.White,FontSize=lbl_.FontSize}

if(CurrentPage == 'Setup') then
  -- User defines connection properties
  table.insert(graphics,{Type="Text",Text="IP Address"    ,Position={ 15,35},Size={100,16},FontSize=14,HTextAlign="Right"})
  layout["IPAddress"] = {PrettyName="Settings~IP Address" ,Position={120,35},Size={100,16},Style="Text",Color=colors.White,FontSize=12}

  table.insert(graphics,{Type="Text",Text="Username"      ,Position={ 15,55},Size={100,16},FontSize=14,HTextAlign="Right"})
  layout["Username"] = {PrettyName="Settings~Username"    ,Position={120,55},Size={100,16},Style="Text",Color=colors.White,FontSize=12}
  
  table.insert(graphics,{Type="Text",Text="Password"      ,Position={ 15,75},Size={100,16},FontSize=14,HTextAlign="Right"})
  layout["Password"] = {PrettyName="Settings~Password"    ,Position={120,75},Size={100,16},Style="Text",Color=colors.White,FontSize=12}

  -- Status fields updated upon connect
  table.insert(graphics,{Type="GroupBox",Text="Status",Fill=colors.Background,StrokeWidth=1,CornerRadius=4,HTextAlign="Left",Position={5,135},Size={400,220}})
  layout["Status"] = {PrettyName="Status~Connection Status", Position={40,165}, Size={330,32}, Padding=4 }
  table.insert(graphics,{Type="Text",Text=GetPrettyName(),Position={15,200},Size={380,14},FontSize=10,HTextAlign="Right", Color=colors.Gray})

elseif(CurrentPage == 'System') then 

  table.insert(graphics,{Type="Text",Text="Device names"            ,Position={ 10,   5},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["DeviceNames"] = {PrettyName="Settings~DeviceNames"        ,Position={ 10, 21},Size={140, 16},FontSize=12,Style="ComboBox",Color=colors.White}
  table.insert(graphics,{Type="Text",Text="Device details"          ,Position={ 10, 37},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["DeviceDetails"] = {PrettyName="Settings~DeviceDetails"    ,Position={ 10, 53},Size={140, 90},FontSize=12,Style="ListBox",Color=colors.White}

  table.insert(graphics,{Type="Text",Text="Playlist names"          ,Position={150,  5},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["PlaylistNames"] = {PrettyName="Settings~PlaylistNames"    ,Position={150, 21},Size={140, 16},FontSize=12,Style="ComboBox",Color=colors.White}
  table.insert(graphics,{Type="Text",Text="Playlist details"        ,Position={150, 37},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["PlaylistDetails"] = {PrettyName="Settings~PlaylisDetails" ,Position={150, 53},Size={140, 90},FontSize=12,Style="ListBox",Color=colors.White}
  
  table.insert(graphics,{Type="Text",Text="Channel names"           ,Position={290,  5},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["ChannelNames"] = {PrettyName="Settings~ChannelNames"      ,Position={290, 21},Size={140, 16},FontSize=12,Style="ComboBox",Color=colors.White}
  table.insert(graphics,{Type="Text",Text="Channel details"         ,Position={290, 37},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["ChannelDetails"] = {PrettyName="Settings~ChannelDetails"  ,Position={290, 53},Size={140, 90},FontSize=12,Style="ListBox",Color=colors.White}  


elseif(CurrentPage == 'Devices') then 

  local i = 1

  table.insert(graphics,{Type="Text",Text="Device select"                   ,Position={ 10,  5},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["DeviceSelect "..i] = {PrettyName="Device "..i.."~DeviceSelect"    ,Position={150,  5},Size={140, 16},FontSize=12,Style="ComboBox",Color=colors.White}
 
  table.insert(graphics,{Type="Text",Text="Channel select"                  ,Position={ 10, 21},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["ChannelSelect "..i] = {PrettyName="Device "..i.."~ChannelSelect"  ,Position={150, 21},Size={140, 16},FontSize=12,Style="ComboBox",Color=colors.White}

  table.insert(graphics,{Type="Text",Text="Playlist select"                 ,Position={ 10, 37},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["PlaylistSelect "..i] = {PrettyName="Device "..i.."~PlaylistSelect",Position={150, 37},Size={140, 16},FontSize=12,Style="ComboBox",Color=colors.White}

  table.insert(graphics,{Type="Text",Text="Current content"                 ,Position={ 10, 53},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["CurrentContent "..i] = {PrettyName="Device "..i.."~CurrentContent",Position={150, 53},Size={140, 32},FontSize=12,Style="Text",Color=colors.White}

  table.insert(graphics,{Type="Text",Text="Device details"                  ,Position={ 10, 85},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["DeviceDetails "..i] = {PrettyName="Device "..i.."~DeviceDetails"  ,Position={150, 85},Size={140, 90},FontSize=12,Style="ListBox",Color=colors.White}

  table.insert(graphics,{Type="Text",Text="IP address"                      ,Position={ 10,175},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["Address "..i] = {PrettyName="Device "..i.."~IPAddress"            ,Position={150,175},Size={140, 16},FontSize=12,Style="Text",Color=colors.White}

  table.insert(graphics,{Type="Text",Text="MAC address"                     ,Position={ 10,191},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["MACAddress "..i] = {PrettyName="Device "..i.."~MACAddress"        ,Position={150,191},Size={140, 16},FontSize=12,Style="Text",Color=colors.White}

  table.insert(graphics,{Type="Text",Text="Platform"                        ,Position={ 10,207},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["Platform "..i] = {PrettyName="Device "..i.."~Platform"            ,Position={150,207},Size={140, 16},FontSize=12,Style="Text",Color=colors.White}


  table.insert(graphics,{Type="Text",Text="Power on"                        ,Position={310, 85},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["PowerOn "..i] = {PrettyName="Device "..i.."~PowerOn"              ,Position={450, 85},Size={ 36, 16},FontSize=12,Style="Button"}
  table.insert(graphics,{Type="Text",Text="Power off"                       ,Position={310,101},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["PowerOff "..i] = {PrettyName="Device "..i.."~PowerOff"            ,Position={450,101},Size={ 36, 16},FontSize=12,Style="Button"}
  table.insert(graphics,{Type="Text",Text="Power toggle"                    ,Position={310,117},Size={140, 16},FontSize=14,HTextAlign="Right"})
  layout["PowerToggle "..i] = {PrettyName="Device "..i.."~PowerToggle"      ,Position={450,117},Size={ 36, 16},FontSize=12,Style="Button"}

end;