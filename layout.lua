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
    
if(CurrentPage == 'Setup') then
  -- User defines connection properties
  table.insert(graphics,{Type="Text",Text="IP Address",Position={15,35},Size={100,16},FontSize=14,HTextAlign="Right"})
  layout["IPAddress"] = {PrettyName="Settings~IP Address",Style="Text",Color=colors.White,Position={120,35},Size={99,16},FontSize=12}

  -- Status fields updated upon connect
  table.insert(graphics,{Type="GroupBox",Text="Status",Fill=colors.Background,StrokeWidth=1,CornerRadius=4,HTextAlign="Left",Position={5,135},Size={400,220}})
  layout["Status"] = {PrettyName="Status~Connection Status", Position={40,165}, Size={330,32}, Padding=4 }
  table.insert(graphics,{Type="Text",Text=GetPrettyName(),Position={15,200},Size={380,14},FontSize=10,HTextAlign="Right", Color=colors.Gray})

elseif(CurrentPage == 'System') then 

elseif(CurrentPage == 'Devices') then 

end;
