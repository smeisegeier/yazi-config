--- @since 26.8.15
-- Fetcher wrapper: run the mactag fetcher only on macOS, where the `tag` command exists.
-- Elsewhere it would try to spawn `tag` for every directory and log an error each time.

return {
	fetch = function(_, job)
		if ya.target_os() ~= "macos" then
			return require("noop"):fetch(job)
		end
		return require("mactag"):fetch(job)
	end,
}
