local CurrentPage = PageNames[props["page_index"].Value]
local logo = "iVBORw0KGgoAAAANSUhEUgAAAKoAAAAhCAYAAABJATCZAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAAZdEVYdFNvZnR3YXJlAEFkb2JlIEltYWdlUmVhZHlxyWU8AAADJGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNi4wLWMwMDYgNzkuZGFiYWNiYiwgMjAyMS8wNC8xNC0wMDozOTo0NCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjQgKFdpbmRvd3MpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjY0RDZGODZGM0IwNDExRUM5NkM3QTEzM0NBQjU2Q0NDIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjY0RDZGODcwM0IwNDExRUM5NkM3QTEzM0NBQjU2Q0NDIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6NjRENkY4NkQzQjA0MTFFQzk2QzdBMTMzQ0FCNTZDQ0MiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NjRENkY4NkUzQjA0MTFFQzk2QzdBMTMzQ0FCNTZDQ0MiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4g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"

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
  Gray        = {96,96,96},
  LightGray   = {194,194,194}
}

layout["code"]={PrettyName="code",Style="None"}  

if(CurrentPage == 'Setup') then
  table.insert(graphics,{Type="GroupBox",Text="Connect",Fill=colors.Background,StrokeWidth=1,CornerRadius=4,HTextAlign="Left",Position={5,5},Size={400,120}})
  table.insert(graphics,{Type="Image",Image=logo,Position={230,45},Size={170,34}})

  -- User defines connection properties
  table.insert(graphics,{Type="Text",Text="IP Address"    ,Position={ 15,35},Size={100,16},FontSize=14,HTextAlign="Right"})
  layout["IPAddress"] = {PrettyName="Settings~IP Address" ,Position={120,35},Size={100,16},Style="Text",Color=colors.White,FontSize=12}

  table.insert(graphics,{Type="Text",Text="Username"      ,Position={ 15,55},Size={100,16},FontSize=14,HTextAlign="Right"})
  layout["Username"] = {PrettyName="Settings~Username"    ,Position={120,55},Size={100,16},Style="Text",Color=colors.White,FontSize=12}
  
  table.insert(graphics,{Type="Text",Text="Password"      ,Position={ 15,75},Size={100,16},FontSize=14,HTextAlign="Right"})
  layout["Password"] = {PrettyName="Settings~Password"    ,Position={120,75},Size={100,16},Style="Text",Color=colors.White,FontSize=12}

  -- Status fields updated upon connect
  table.insert(graphics,{Type="GroupBox",Text="Status",Fill=colors.Background,StrokeWidth=1,CornerRadius=4,HTextAlign="Left",Position={5,135},Size={400,85}})
  layout["Status"] = {PrettyName="Status~Connection Status", Position={40,165}, Size={330,32}, Padding=4 }
  table.insert(graphics,{Type="Text",Text=GetPrettyName(),Position={15,200},Size={380,14},FontSize=10,HTextAlign="Right", Color=colors.Gray})

elseif(CurrentPage == 'System') then 
  layout["PlaylistLogo"] = {PrettyName="Settings~PlaylistLogo"      ,Position={460,  9},Size={180,180},Style="Button",Color=colors.Transparent}
  table.insert(graphics,{Type="Text",Text="Query devices"           ,Position={460,200},Size={135, 16},FontSize=14,HTextAlign="Left"})
  layout["QueryDevices"] = {PrettyName="Settings~QueryDevices"      ,Position={604,200},Size={ 36, 16},FontSize=12,Style="Button"}
  table.insert(graphics,{Type="Text",Text="Query channels"          ,Position={460,216},Size={135, 16},FontSize=14,HTextAlign="Left"})
  layout["QueryChannels"] = {PrettyName="Settings~QueryChannels"    ,Position={604,216},Size={ 36, 16},FontSize=12,Style="Button"}
  table.insert(graphics,{Type="Text",Text="Query playlists"         ,Position={460,232},Size={135, 16},FontSize=14,HTextAlign="Left"})
  layout["QueryPlaylists"] = {PrettyName="Settings~QueryPlaylists"  ,Position={604,232},Size={ 36, 16},FontSize=12,Style="Button"}
  table.insert(graphics,{Type="Text",Text="Reload logo config"      ,Position={460,248},Size={135, 16},FontSize=14,HTextAlign="Left"})
  layout["LoadLogos"] = {PrettyName="Settings~LogoLoad"             ,Position={604,248},Size={ 36, 16},FontSize=12,Style="Button"}

  table.insert(graphics,{Type="Text",Text="Device names"            ,Position={ 10,  5},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["DeviceNames"] = {PrettyName="Settings~DeviceNames"        ,Position={ 10, 21},Size={140, 16},FontSize=12,Style="ComboBox"}
  table.insert(graphics,{Type="Text",Text="Device details"          ,Position={ 10, 37},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["DeviceDetails"] = {PrettyName="Settings~DeviceDetails"    ,Position={ 10, 53},Size={140,360},FontSize=12,HTextAlign="Left",Style="ListBox"}

  table.insert(graphics,{Type="Text",Text="Playlist names"          ,Position={150,  5},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["PlaylistNames"] = {PrettyName="Settings~PlaylistNames"    ,Position={150, 21},Size={140, 16},FontSize=12,Style="ComboBox"}
  table.insert(graphics,{Type="Text",Text="Playlist details"        ,Position={150, 37},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["PlaylistDetails"] = {PrettyName="Settings~PlaylisDetails" ,Position={150, 53},Size={140,360},FontSize=12,HTextAlign="Left",Style="ListBox"}
  
  table.insert(graphics,{Type="Text",Text="Channel names"           ,Position={290,  5},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["ChannelNames"] = {PrettyName="Settings~ChannelNames"      ,Position={290, 21},Size={140, 16},FontSize=12,Style="ComboBox"}
  table.insert(graphics,{Type="Text",Text="Channel details"         ,Position={290, 37},Size={140, 16},FontSize=14,HTextAlign="Center"})
  layout["ChannelDetails"] = {PrettyName="Settings~ChannelDetails"  ,Position={290, 53},Size={140,360},FontSize=12,HTextAlign="Left",Style="ListBox"}  

elseif(CurrentPage == 'Devices') then 

  local offset_= { 530, 176 } -- index, x-offset, y-offset
  local max_rows_ = 15

  for i=1, props['Display Count'].Value do

    x = offset_[1]*math.floor(((i-1)/max_rows_)+.05)
    y = offset_[2]*math.floor(((i-1)%max_rows_)+.05)

    table.insert(graphics,{Type="GroupBox",Text="Device "..i                  ,Position={ 14+x,  5+y},Size={526,172},FontSize=12,HTextAlign="Left",Fill=colors.Background,StrokeWidth=1,CornerRadius=4})
    -- column 1
    table.insert(graphics,{Type="Text",Text="Device select"                   ,Position={ 24+x, 28+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["DeviceName "..i] = {PrettyName="Device "..i.."~DeviceName"        ,Position={136+x, 28+y},Size={140, 16},FontSize=12,Style="Text",Color=colors.White,WordWrap=true,IsReadOnly=true}
    layout["DeviceSelect "..i] = {PrettyName="Device "..i.."~DeviceSelect"    ,Position={136+x, 28+y},Size={140, 16},FontSize=12,Style="ComboBox"}
    table.insert(graphics,{Type="Text",Text="Channel select"                  ,Position={ 24+x, 44+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["ChannelSelect "..i] = {PrettyName="Device "..i.."~ChannelSelect"  ,Position={136+x, 44+y},Size={140, 16},FontSize=12,Style="ComboBox"}
    table.insert(graphics,{Type="Text",Text="Playlist select"                 ,Position={ 24+x, 60+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["PlaylistSelect "..i] = {PrettyName="Device "..i.."~PlaylistSelect",Position={136+x, 60+y},Size={140, 16},FontSize=12,Style="ComboBox"}
    
    table.insert(graphics,{Type="Text",Text="Power"                           ,Position={ 24+x, 76+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["PowerOn "..i] = {PrettyName="Device "..i.."~PowerOn"              ,Position={134+x, 76+y},Size={ 36, 16},FontSize=12,Style="Button",Text="ON"}
    layout["PowerOff "..i] = {PrettyName="Device "..i.."~PowerOff"            ,Position={170+x, 76+y},Size={ 36, 16},FontSize=12,Style="Button",Text="OFF"}
    layout["PowerToggle "..i] = {PrettyName="Device "..i.."~PowerToggle"      ,Position={206+x, 76+y},Size={ 36, 16},FontSize=12,Style="Button",Text="TOGGLE"}
    table.insert(graphics,{Type="Text",Text="Current content"                 ,Position={ 24+x, 92+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["CurrentContent "..i] = {PrettyName="Device "..i.."~CurrentContent",Position={134+x, 92+y},Size={140, 32},FontSize=12,Style="Text",Color=colors.White,WordWrap=true,IsReadOnly=true}

    table.insert(graphics,{Type="GroupBox",Text="Connected display"           ,Position={ 14+x,124+y},Size={262, 52},FontSize=10,HTextAlign="Left",Fill=colors.Transparent,StrokeWidth=1,CornerRadius=4})
    table.insert(graphics,{Type="Text",Text="Status"                          ,Position={ 24+x,138+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["DisplayStatus "..i] = {PrettyName="Device "..i.."~Display~Status" ,Position={134+x,128+y},Size={140, 30},FontSize=10,Style="Text",IsReadOnly=true,Color=colors.LightGray}
    table.insert(graphics,{Type="Text",Text="IP address"                      ,Position={ 24+x,156+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["DisplayIPAddress "..i] = {PrettyName="Device "..i.."~Display~IPAddress"
                                                                              ,Position={134+x,158+y},Size={140, 16},FontSize=12,Style="Text",Color=colors.White}

    -- column 2
    table.insert(graphics,{Type="Text",Text="IP address"                      ,Position={276+x, 28+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["Address "..i] = {PrettyName="Device "..i.."~IPAddress"            ,Position={388+x, 28+y},Size={140, 16},FontSize=12,Style="Text",Color=colors.White}
    table.insert(graphics,{Type="Text",Text="MAC address"                     ,Position={276+x, 44+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["MACAddress "..i] = {PrettyName="Device "..i.."~MACAddress"        ,Position={388+x, 44+y},Size={140, 16},FontSize=12,Style="Text",Color=colors.White}
    table.insert(graphics,{Type="Text",Text="Platform"                        ,Position={276+x, 60+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["Platform "..i] = {PrettyName="Device "..i.."~Platform"            ,Position={388+x, 60+y},Size={140, 16},FontSize=12,Style="Text",Color=colors.White}
    table.insert(graphics,{Type="Text",Text="Device details"                  ,Position={276+x, 76+y},Size={110, 16},FontSize=14,HTextAlign="Right"})
    layout["Details "..i] = {PrettyName="Device "..i.."~Details"              ,Position={388+x, 76+y},Size={140, 90},FontSize=12,HTextAlign="Left",Style="ListBox"}
 
    layout["Logo "..i] = {PrettyName="Device "..i.."~PlaylistLogo"            ,Position={280+x, 92+y},Size={104, 74},Style="Button",Color=colors.Transparent,StrokeWidth=0}
 
  end

end;