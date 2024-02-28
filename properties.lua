table.insert(props,{
  Name = 'Display Count',
  Type = 'integer',
  Min = 1,
  Max = 255,
  Value = 2
})
table.insert(props,{
  Name = 'Display Code Name Prefix',
  Type = 'string',
  Value = "Display_"
})
table.insert(props,{
  Name  = "Poll Interval",
  Type  = "integer",
  Min   = 5,
  Max   = 255, 
  Value = 60
})
table.insert(props,{
  Name    = "Debug Print",
  Type    = "enum",
  Choices = {"None", "Tx/Rx", "Tx", "Rx", "Function Calls", "All"},
  Value   = "None"
})
