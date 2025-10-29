local M = {}

-- Set the absolute path for the 'ouch' binary, bypassing environment issues.
local OUCH_BIN = "/usr/bin/ouch" 

-- Check if the 'ouch' binary is available and executable via sh -c
local function is_ouch_available()
  local status = Command("sh", { "-c", OUCH_BIN .. " --version" }):status() 
  return status.success
end

-- Notify the user if the required dependency is missing
local function notify_ouch_missing(action)
  ya.notify({
    title = action .. " Failed",
    content = "Dependency '" .. OUCH_BIN .. "' not executable in Yazi's environment. Please verify installation.",
    timeout = 5.0,
    level = "error",
  })
end

-- [[ M:peek(job) ]]
function M:peek(job)
  if not is_ouch_available() then
    notify_ouch_missing("Preview")
    return
  end
  
  local file_url = tostring(job.file.url)
  
  -- Final execution: Use 'sh -c' wrapper with '2>&1' redirect
  local command_string = string.format("%s l -t -y %q 2>&1", OUCH_BIN, file_url)
  local child = Command("sh", { "-c", command_string })
      :stdout(Command.PIPED)
      :spawn()
      
  local limit = job.area.h
  local file_name = string.match(file_url, ".*[/\\](.*)")
  local lines = string.format("📁 \x1b[2m%s\x1b[0m\n", file_name)
  local num_lines = 1
  local num_skip = 0
  
  local HEADER_SKIP = 3 -- 🚨 Skipping the first 3 lines 🚨
  
  -- Reading loop 
  repeat
    local line, event = child:read_line()

    if line == nil or (event ~= 0 and line == "") then
        break
    end

    if event == 1 then
      ya.err("Ouch read error: " .. tostring(event))
      break
    elseif event ~= 0 then 
      break
    end
    
    -- SIMPLIFIED FILTER: Skip the first few header lines explicitly
    if num_skip < HEADER_SKIP then
      num_skip = num_skip + 1
    else
      -- Now collect the actual file list content
      if num_lines < limit then
        lines = lines .. line
        num_lines = num_lines + 1
      end
    end
  until num_lines >= limit

  child:start_kill()
  
  -- Rendering logic (Scroll logic is kept)
  if job.skip > 0 and num_lines < limit then
    ya.mgr_emit(
      "peek",
      { tostring(math.max(0, job.skip - (limit - num_lines))), only_if = file_url, upper_bound = "" }
    )
  else
    ya.preview_widgets(job, { ui.Text(lines):area(job.area) })
  end
end

-- [[ M:seek(job) ]]
function M:seek(job)
  local h = cx.active.current.hovered
  if h and h.url == job.file.url then
    local step = math.floor(job.units * job.area.h / 10)
    ya.mgr_emit("peek", { 
      math.max(0, cx.active.preview.skip + step),
      only_if = tostring(job.file.url),
    })
  end
end

-- Check if file exists
local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- Get the files that need to be compressed and infer a default archive name
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
    ya.mgr_emit("escape", {})
  end
  return paths, default_name
end)

-- [[ invoke_compress_command(paths, name) ]]
local function invoke_compress_command(paths, name)
  if not is_ouch_available() then
    notify_ouch_missing("Compression")
    return
  end
  
  -- Build the command string
  local command_parts = { OUCH_BIN, "c", "-y" }
    for _, p in ipairs(paths) do
        table.insert(command_parts, string.format("%q", p))
    end
    table.insert(command_parts, string.format("%q", name))

    local command_string = table.concat(command_parts, " ")
    
    -- Use 'sh -c' wrapper for execution 
    local cmd = Command("sh", { "-c", command_string })
       :stderr(Command.PIPED)
    
    local cmd_output, err_code = cmd:output()
  
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

  ya.mgr_emit("escape", { visual = true })

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