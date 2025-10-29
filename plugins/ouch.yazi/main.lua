local M = {}

function M:peek(job)
  -- 1. Check the target file path
  local file_url = tostring(job.file.url)
  ya.err("DEBUG: Starting peek for file: " .. file_url)
  ya.err("DEBUG: Area H: " .. tostring(job.area.h) .. ", Skip: " .. tostring(job.skip))

  -- Command setup (The fixed version)
  local child = Command("ouch", { "l", "-t", "-y", file_url })
      :stdout(Command.PIPED)
      :stderr(Command.PIPED)
      :spawn()
      
  local limit = job.area.h
  local file_name = string.match(file_url, ".*[/\\](.*)")
  local lines = string.format("📁 \x1b[2m%s\x1b[0m\n", file_name)
  local num_lines = 1
  local num_skip = 0
  
  -- 2. Debug the loop
  local iteration = 1
  repeat
    local line, event = child:read_line()
    
    -- Log every read attempt
    ya.err(string.format("DEBUG: Read %d - Line: '%s', Event: %s", iteration, tostring(line), tostring(event)))

    -- Check for clean break conditions
    if line == nil then
        ya.err("DEBUG: Clean break (line is nil).")
        break
    end
    
    if event == 1 then
      -- Event 1 usually means a read error or cancellation
      ya.err("ERROR: Child process returned event 1 (read error).")
      break
    elseif event ~= 0 then 
      -- Non-zero event (e.g., EOF/process exit)
      ya.err("DEBUG: Child process exited with event: " .. tostring(event))
      break
    end
    
    -- 3. Debug the filtering logic
    local is_filtered = line:find('Archive', 1, true) == 1 or line:find('[INFO]', 1, true) == 1
    
    if is_filtered then
        ya.err("DEBUG: Line filtered: " .. line)
    end
    
    if not is_filtered then
      if num_skip >= job.skip then
        lines = lines .. line
        num_lines = num_lines + 1
      else
        num_skip = num_skip + 1
      end
    end
    
    iteration = iteration + 1
  until num_lines >= limit

  ya.err("DEBUG: Loop finished. Total lines collected: " .. tostring(num_lines))
  child:start_kill()
  
  -- ... (rest of the function is fine)
  if job.skip > 0 and num_lines < limit then
    ya.mgr_emit(
      "peek",
      { tostring(math.max(0, job.skip - (limit - num_lines))), only_if = file_url, upper_bound = "" }
    )
  else
    -- 4. Check final output size
    ya.err("DEBUG: Previewing final text (length: " .. #lines .. ")")
    ya.preview_widgets(job, { ui.Text(lines):area(job.area) })
  end
end
-- [[ M:seek(job) ]]
function M:seek(job)
  local h = cx.active.current.hovered
  if h and h.url == job.file.url then
    local step = math.floor(job.units * job.area.h / 10)
    -- Fix 4: Use ya.mgr_emit instead of ya.manager_emit (deprecated)
    ya.mgr_emit("peek", {
      math.max(0, cx.active.preview.skip + step),
      only_if = tostring(job.file.url),
    })
  end
end

-- [[ file_exists(name) ]]
local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- [[ get_compression_target() ]]
local get_compression_target = ya.sync(function()
  local tab = cx.active
  local default_name
  local paths = {}
  if #tab.selected == 0 then
    if tab.current.hovered then
      local name = tab.current.hovered.name
      default_name = name
      table.insert(paths, name)
    else
      return
    end
  else
    default_name = tab.current.cwd:name()
    for _, url in pairs(tab.selected) do
      table.insert(paths, tostring(url))
    end
    -- The compression targets are aquired, now unselect them
    ya.mgr_emit("escape", {}) -- Fix 5: use ya.mgr_emit
  end
  return paths, default_name
end)

-- [[ invoke_compress_command(paths, name) ]]
local function invoke_compress_command(paths, name)
  local cmd = Command("ouch")
      :arg("c")
      :arg("-y")
      
  -- Fix 6: Use Command:arg() in a loop instead of Command:args(paths)
  for _, p in ipairs(paths) do
      cmd:arg(p)
  end

  cmd:arg(name)
     :stderr(Command.PIPED)
  
  local cmd_output, err_code = cmd:output()
  
  -- Error handling logic remains the same
  if err_code ~= nil then
    ya.notify({
      title = "Failed to run ouch command",
      content = "Status: " .. err_code,
      timeout = 5.0,
      level = "error",
    })
  elseif not cmd_output.status.success then
    ya.notify({
      title = "Compression failed: status code " .. cmd_output.status.code,
      content = cmd_output.stderr,
      timeout = 5.0,
      level = "error",
    })
  end
end

-- [[ M:entry(job) ]]
function M:entry(job)
  local default_fmt = job.args[1]
  if default_fmt == nil then
    default_fmt = "zip"
  end

  ya.mgr_emit("escape", { visual = true }) -- Fix 7: use ya.mgr_emit

  -- Get the files that need to be compressed and infer a default archive name
  local paths, default_name = get_compression_target()
  if not paths then
    return
  end

  -- Get archive name from user
  local output_name, name_event = ya.input({
    title = "Create archive:",
    value = default_name .. "." .. default_fmt,
    position = { "top-center", y = 3, w = 40 },
  })
  if name_event ~= 1 then
    return
  end

  -- Get confirmation if file exists
  if file_exists(output_name) then
    local confirm, confirm_event = ya.input({
      title = "Overwrite " .. output_name .. "? (y/N)",
      position = { "top-center", y = 3, w = 40 },
    })
    if not (confirm_event == 1 and confirm:lower() == "y") then
      return
    end
  end

  invoke_compress_command(paths, output_name)
end

return M