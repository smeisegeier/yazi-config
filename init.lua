-- ~/.config/yazi/init.lua
require("relative-motions"):setup({ show_numbers="relative", show_motion = true })
require("githead"):setup()

-- require("eza-preview"):setup()

require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})


require("mactag"):setup {
	-- Keys used to add or remove tags
	keys = {
		r = "Red",
		o = "Orange",
		y = "Yellow",
		g = "Green",
		b = "Blue",
		p = "Purple",
		n = "no-sync",
	},
	-- Colors used to display tags
	colors = {
		Red    = "#ee7b70",
		Orange = "#f5bd5c",
		Yellow = "#fbe764",
		Green  = "#91fc87",
		Blue   = "#5fa3f8",
		Purple = "#cb88f8",
		-- "no-sync" = "#777777",
	},
}


function Linemode:size_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

function Linemode:size_mtime_perm()
	-- -- Retrieve the file's permissions
	local nlink = string.format("%02d", self._file.cha.nlink or 0)
	local permissions = self._file.cha:perm() or ""


	-- Get the last modification time
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	-- Get the size
	local size = self._file:size()

	-- Format the output with permissions, size, and time
	return string.format("%s %s %s %s", size and ya.readable_size(size) or "-", time, nlink, permissions)
end
	




-- Define a function to display a message in Yazi
function hi()
    -- The print function sends output to Yazi's message area
    ya.notify {
		title = "Yazi",
		content = "Hello, world!",
		timeout = 5
	}
end

Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	}
end, 500, Status.RIGHT)

Header:children_add(function()
	if ya.target_family() ~= "unix" then
		return ""
	end
	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
end, 500, Header.LEFT)


function Status:name()
	local h = self._current.hovered
	if not h then
		return ""
	end

	local linked = ""
	if h.link_to ~= nil then
		linked = " -> " .. tostring(h.link_to)
	end

	return " " .. h.name:gsub("\r", "?", 1) .. linked
end


----@diagnostic disable: undefined-global
-- return {
-- 	entry = function(self, args)
-- 		local h = cx.active.current.hovered
-- 		if h and h.cha.is_dir then
-- 			ya.notify {
-- 				title = "Entering Dir!",
-- 				content = string. format ("Path: %s", h.url),
-- 				timeout = 2.5,
-- 			}
-- 			ya.manager_emit("enter", {})
-- 			return
-- 		end
-- 		if #args > 0 and args[1] == "detatch" then
-- 			os.execute(string. format("opener detatch \"%s\"", h.url))
-- 		else
-- 			ya.manager_emit("open", {})
-- 		end 
-- 	end,
-- 	}
