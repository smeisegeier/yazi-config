--- @since 26.8.15
-- Prompt for arguments, run the selected (or hovered) file with them while yazi
-- is paused, then wait for a key so the output stays readable.

local selected_or_hovered = ya.sync(function()
	local tab = cx.active
	for _, f in pairs(tab.selected) do
		return tostring(f.url)
	end
	if tab.current.hovered then
		return tostring(tab.current.hovered.url)
	end
end)

return {
	entry = function()
		local file = selected_or_hovered()
		if not file then
			return ya.notify { title = "Execute", content = "No file selected", level = "warn", timeout = 5 }
		end

		local args, event = ya.input {
			title = string.format("Run %s – args:", file:match("[^/]+$")),
			pos = { "top-center", y = 3, w = 60 },
		}
		if event ~= 1 then
			return
		end

		-- newline instead of ";" so a trailing "&" or "#" in args can't eat the pause
		ya.emit("shell", {
			ya.quote(file) .. " " .. args .. "\necho; read -n 1 -s -r -p 'Press any key to continue...'",
			block = true,
		})
	end,
}
