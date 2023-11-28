table.insert(props,{
  Name = 'Display Count',
  Type = 'integer',
  Min = 1,
  Max = 255,
  Value = 2
})
table.insert(props,{
  Name  = "Poll Interval",
  Type  = "integer",
  Min   = 1,
  Max   = 255, 
  Value = 30
})
table.insert(props,{
  Name    = "Debug Print",
  Type    = "enum",
  Choices = {"None", "Tx/Rx", "Tx", "Rx", "Function Calls", "All"},
  Value   = "None"
})
