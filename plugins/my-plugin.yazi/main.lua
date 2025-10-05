-- return {
-- 	entry = function()
-- 		ya.notify {
-- 			title = "messg",
-- 			content = "Archived files to ",
--			-- content = job.args[1],
-- 			timeout = 2.5,
-- 			level = "info",
-- 		}
-- 	end,
-- }
---- --args='oh-hello --foo --bar=baz'

-- local hovered = ya.sync(function()
-- 	local tab, paths = cx.active, {}
-- 	if tab.current.hovered then
-- 		paths[1] = tostring(tab.current.hovered.url)
-- 	end
-- 	return paths
-- end)

-- local selected = ya.sync(function()
-- 	local tab, paths = cx.active, {}
-- 	for _, u in pairs(tab.selected) do
-- 		paths[#paths + 1] = tostring(u)
-- 	end
-- 	return paths
-- end)

local lul = ya.sync(function()
    local tab, paths = cx.active, {}
    return tostring(tab.current.hovered.url)
    -- return
end)

return {
    entry = function()
        -- local tab = cx.active
        local hovered_file = lul()
        local base_name = hovered_file:gsub("^.+/(.+)%..+$", "%1")
        local archive_name = base_name .. ".tar.gz"

        -- Build the tar command
        local cmd = string.format("tar -czvf %q %q", archive_name, hovered_file)

        -- Execute the command
        -- os.execute(cmd)


        -- local cand = ya.which {
        --     cands = {
        --         { on = "a" },
        --         { on = "b", desc = "optional description" },
        --         { on = "<C-c>", desc = "key combination" },
        --         { on = { "d", "e" }, desc = "multiple keys" },
        --     },
        --     -- silent = true, -- If you don't want to show the UI of key indicator
        -- }
        -- if not (cand >= 1 and cand <= 4) then
        --     return ""
        -- end

        -- ya.notify {
        --     title = "Hover",
        --     content ="you said:" .. cand,
        --     timeout = 3,
        --     level = "info",
        -- }

        -- local value, event = ya.input {
		-- 	title = "lol:",
		-- 	position = { "top-center", y = 3, w = 40 },
		-- }
		-- if event ~= 1 then
		-- 	return
		-- end

        local fzf_command = "echo -e 'Option 1\nOption 2\nOption 3' | fzf --height=10% --border --ansi > /tmp/yazi_selection"
        os.execute(fzf_command)
        
        local file = io.open("/tmp/yazi_selection", "r")
        if file then
            local choice = file:read("*a"):gsub("%s+$", "")
            file:close()
        
        else
        

        --local fzf_command = "echo -e 'Option 1\nOption 2\nOption 3' | fzf --height=10% --border --ansi"
        -- local dropdown = io.popen(fzf_command)
        -- local choice = dropdown:read("*all"):gsub("%s+$", "")
        -- dropdown:close()

        if choice and choice ~= "" then
            ya.notify {
                title = "Selection",
                content = "You selected: " .. choice,
                timeout = 3,
                level = "info",
            }
        end


        local command = string.format(
            'echo "%s\nEnter custom name..." | fzf --header="Choose archive name or enter a custom one:"', archive_name
        )
        local choice = io.popen("command")
        local test = choice:read("*all"):gsub("%s+$", "")
        choice:close()

        -- -- Check if there are selected files
        -- if #tab.selected > 0 then
        --     hovered_file = tostring(tab.selected[1]) -- Get the first selected file
        -- elseif tab.current.hovered then
        --     -- If no files are selected, use the hovered file
        --     hovered_file = tostring(tab.current.hovered.url)
        -- end

            ya.notify {
                title = "Hover",
                content = base_name .. " -> " .. archive_name,
                timeout = 5,
                level = "info",
            }

        -- if hovered_file then
        --     ya.notify {
        --         title = "Hover",
        --         content = base_name,
        --         timeout = 5,
        --         level = "info",
        --     }
        -- else
        --     ya.notify {
        --         title = "No File Selected",
        --         content = "No files are currently selected or hovered.",
        --         timeout = 2.5,
        --         level = "warn",
        --     }
        -- end
    end,
}
