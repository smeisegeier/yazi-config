-- plugins/tree-from-hovered.yazi/init.lua

local function info(content)
	return ya.notify({
		title = "ASCII Tree",
		content = content,
		timeout = 5,
	})
end

local get_hovered = ya.sync(function()
	local hovered = cx.active.current.hovered
	if hovered then
		return hovered.url, hovered.cha.is_dir
	end
	return nil, false
end)

return {
	entry = function()
		local hovered_path, is_dir = get_hovered()
		if not hovered_path then
			return info("No item hovered")
		end

		local path = tostring(hovered_path)
		if not is_dir then
			-- If the hovered item is a file, use its parent directory
			path = ya.parent_path(path)
		end

		local output, err = Command("tree")
			:arg("-L")
			:arg("3") -- Limit depth to 3 levels, adjust as needed
			:arg("--charset=ascii") -- Use ASCII characters for compatibility
			:arg(path)
			:output()

		if not output then
			return info("Failed to generate tree, error: " .. err)
		end

		local tree = output.stdout
		local line_count = select(2, tree:gsub("\n", "\n"))

		ya.clipboard(tree)
		info(string.format("Copied ASCII tree with %d lines to clipboard", line_count))
	end,
}