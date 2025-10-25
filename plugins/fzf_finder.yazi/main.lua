local function notify(str)
	ya.notify({ title = "FZF Finder", content = str, timeout = 3, level = "info" })
end

local function entry()
    -- ******* ABSOLUTE MINIMAL HANG TEST *******
    -- Test command: Static input, simplest fzf command (no options)
    local full_cmd = "echo 'file1\nfile2\nfile3' | fzf" 
    
    notify("Attempting minimal FZF run...")
    -- HANG OCCURS HERE
    local selected_path = ya.job:sync(full_cmd) 

    if selected_path and selected_path:len() > 0 then
        local target_path = selected_path:gsub("%s+$", "")
        ya.manager:reveal({ target = target_path })
        notify("SUCCESS! FZF worked and selected: " .. target_path)
    else
        notify("FZF CANCELED/FAIL.")
    end
end

return {
    setup = function(state, options) end,
	entry = entry,
}