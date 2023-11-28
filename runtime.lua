
	-- Control aliases
	Status = Controls.Status
	
  local SimulateFeedback = true
	-- Variables and flags
	DebugTx=false
	DebugRx=false
	DebugFunction=false
	DebugPrint=Properties["Debug Print"].Value	

	-- Timers, tables, and constants
	StatusState = { OK = 0, COMPROMISED = 1, FAULT = 2, NOTPRESENT = 3, MISSING = 4, INITIALIZING = 5 }
	Heartbeat = Timer.New()
	PollRate = Properties["Poll Interval"].Value
	Timeout = PollRate + 10

	-------------------------------------------------------------------------------
	-- Device functions
	-------------------------------------------------------------------------------
