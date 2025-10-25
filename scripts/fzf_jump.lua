local M = {}

local function notify(str, level)
	ya.notify({
		title = "FZF Jump",
		content = str,
		timeout = 3,
		level = level or "info",
	})
end

-- This is the function called by the keymap
M.fzf_jump_to_file = function(args)
    -- 1. Define the external command
    local list_cmd = "find . -mindepth 1 -not -path './.*'"
    local full_cmd = list_cmd .. ' | fzf --ansi --layout=reverse +m'

    -- 2. Open an ASYNCHRONOUS job (ya.job:open) to prevent the hang
    local job = ya.job:open(full_cmd)

    if not job then
        return notify("Failed to open shell job.", "error")
    end

    notify("Launching FZF... (Press ESC in FZF to cancel)")

    -- 3. Wait for the output from the job
    local selected_path = job:recv() -- This waits for the job to complete

    -- 4. Process the result
    if selected_path and selected_path:len() > 0 then
        -- Clean up path (remove './' and newline)
        local target_path = selected_path:gsub("^./", ""):gsub("%s+$", "")
        
        -- Jump/reveal the file
        ya.manager:reveal({ target = target_path })
        notify("Jumped to: " .. target_path)
    else
        notify("FZF selection cancelled or failed.")
    end
end

return M