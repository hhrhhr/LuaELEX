local f = {}

f["class gCNavigation_PS"] = function(level, size)
    local start = r:pos()
    tab(level); wr("float_0 = "); func.read_float(3); wr("\n")
    tab(level); wf("guid_ = %s,\n", func.get_guid())
    GAR5_UTIL.read_unknown_bytes(28)
    tab(level); wr("float_1 = "); func.read_float(3); wr("\n")
   
    
--    tab(level); wf("['Name'] = %q,\n", func.get_string())
--    tab(level); wf("int_1 = %d,\n", r:uint32())
--    tab(level); wf("enum_ = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
--    tab(level); wf("int_2 = %d,\n", r:uint32())
    
    GAR5_UTIL.read_unknown_bytes(size - r:pos() + start, "gCNavigation_PS")
end

f["class gCNPC_PS"] = function(level, size)
    local start = r:pos()
    tab(level); wf("['Bravery'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['AttitudeLock'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['Reason'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['LastReason'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['LastPlayerAR'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['LastFightAgainstPlayer'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['LastFightTimestamp'] = %f,\n", r:float())
    tab(level); wf("['LastGoingDownTimestamp'] = %f,\n", r:float())
    tab(level); wf("['PlayerWeaponTimestamp'] = %f,\n", r:float())
    tab(level); wf("['LastPlayerHealTimestamp'] = %f,\n", r:float())
    tab(level); wf("['LastDistToTarget'] = %f,\n", r:float())
    tab(level); wf("['DefeatedByPlayer'] = %s,\n", r:bool())
    tab(level); wf("['Ransacked'] = %s,\n", r:bool())
    tab(level); wf("['Discovered'] = %s,\n", r:bool())
--    tab(level); wf("['CurrentTargetEntity'] = %s,\n", get_guid()) -- ???
    tab(level); wf("['CurrentAttackerEntity'] = %s,\n", func.get_guid())
    tab(level); wf("['LastAttackerEntity'] = %s,\n", func.get_guid())
    tab(level); wf("['GuardPoint'] = %s,\n", func.get_guid())
    tab(level); wf("['GuardStatus'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['LastDistToGuardPoint'] = %f,\n", r:float())
    tab(level); wf("['DamageCalculationType'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['Guild'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['Group'] = %q,\n", func.get_string())
    tab(level); wf("%d, %d -- last\n", r:uint32(), r:uint32())
--    GAR5_UTIL.read_unknown_bytes(size - r:pos() + start)
end

f["class gCScriptRoutine_PS"] = function(level, size)
    local start = r:pos()
    tab(level); wf("['GeneratedPlunder'] = %s,\n", r:bool())
    tab(level); wf("['GeneratedTrade'] = %s,\n", r:bool())
    tab(level); wf("['Owner'] = %s,\n", func.get_guid())
    
    GAR5_UTIL.read_unknown_bytes(size - r:pos() + start)
end

f["class gCScriptRoutine_PS"] = function(level, size)
    local start = r:pos()
    tab(level); wf("['Routine'] = %q,\n", func.script_proxy())
    tab(level); wf("['ResumeTask'] = %q,\n", func.script_proxy())
    tab(level); wf("['AdditionalPerceptionRadius'] = %f,\n", r:float())
    tab(level); wf("['CurrentTask'] = %q,\n", func.script_proxy())
    tab(level); wf("['TaskTime'] = %f, -- ??? 'StateTime'\n", r:float())
    tab(level); wf("%d, %d -- ???\n", r:uint32(), r:uint32())
    tab(level); wf("['LastTask'] = %q,\n", func.script_proxy())
    tab(level); wf("['CurrentState'] = %q,\n", func.script_proxy())
    tab(level); wf("['AIMode'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
    tab(level); wf("['LastAIMode'] = %q, -- %d\n", func.get_name(r:uint32()), r:uint32())
--    GAR5_UTIL.read_unknown_bytes(size - r:pos() + start)
end

f["class gCDialog_PS"] = function(level, size)
    local start = r:pos()
    tab(level); wf("['EndDialogTimestamp'] = %f,\n", r:float())
    tab(level); wf("%d, %d, %d, %d, %d -- ??? TradeEnabled/TeachEnabled/TalkedToPlayer/PartyEnabled/PickedPocket\n",
        r:uint32(), r:uint32(),r:uint32(), r:uint32(), r:uint32())
end

f["class gCEffect_PS"] = function(level, size)
    tab(level); wf("['Enabled'] = %s,\n", r:bool())
end

f["class gCMapLocation_PS"] = function(level, size)
    tab(level); wf("['Enabled'] = %s,\n", r:bool())
end

return f