--- @async entry  -- Required for Command API and ya.manager_emit
local state = ya.sync(function() return cx.active.current.cwd end)

local function fail(s, ...) ya.notify { title = "Fzf", content = string.format(s, ...), timeout = 5, level = "error" } end

local function entry()
    local _permit = ya.hide()
    local cwd = tostring(state())

    -- 1. Command to generate a clean list of files (find | sed)
    -- 🔑 FIX: Escaping the single quotes for 'sed' to fix the Lua syntax error.
    local file_list_cmd = Command("sh"):args({ "-c", "find . -mindepth 1 | sed \'s/^\\.\\///\'" })

    -- 2. Your fzf command, now with arguments and receiving stdin from the list command
    local child, err =
        Command("fzf")
            :args({ 
                "--ansi",
                "--layout=reverse",
                "--preview", "bat --color=always --style=numbers --line-range :500 {}",
                "--bind", "ctrl-u:preview-page-up,ctrl-d:preview-page-down" 
            })
            :cwd(cwd)
            :stdin(file_list_cmd)  -- Pipes the file list into fzf
            :stdout(Command.PIPED)
            :stderr(Command.INHERIT)
            :spawn()

    if not child then
        return fail("Failed to start `fzf`, error: " .. err)
    end

    local output, err = child:wait_with_output()
    if not output then
        return fail("Cannot read `fzf` output, error: " .. err)
    elseif not output.status.success and output.status.code ~= 130 then
        return fail("`fzf` exited with error code %s", output.status.code)
    end

    if output.status.code == 130 then
        return
    end

    -- Process valid output
    local target = output.stdout:gsub("\n$", "")
    target = target:gsub("^./", "") 

    if target ~= "" then
        ya.manager_emit(target:find("[/\\]$") and "cd" or "reveal", { target })
    end
end

return { entry = entry }