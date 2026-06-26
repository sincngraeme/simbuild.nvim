local M = {}

local local_config_file = ".simplug.json"

M.config = {
    ["Make"] = "make",
}

M.local_config = {}

local function define(name, command)
    vim.api.nvim_create_user_command(name, function(opts)
            vim.cmd("new")
            vim.cmd("wincmd J")
            vim.cmd("res 10")
            vim.cmd("term " .. command .. " " .. table.concat(opts.fargs, " "))
            vim.cmd("startinsert")
    end, { bang = true, nargs = "*" })
end

function M.setup(user_config)
    if not user_config then
        vim.notify("No config found for plugin: Simbuild", vim.log.levels.ERROR)
    else
        M.config = user_config
        -- Setup the autocmd to populate the quickfix with the results of the build in the terminal buffer
        vim.api.nvim_create_autocmd("TermClose", {
            -- pattern = { "Simbuild" },
            callback = function()
                vim.cmd('cgetexpr getline(1, "$")')
            end
        })
        -- Define all the user specified commands
        for name, command in pairs(user_config) do
            define(name, command)
        end
    end
end

local function find_project_root(start_dir)
  local uv = vim.uv or vim.loop
  local dir = start_dir

  while dir do
    local candidate = dir .. "/" .. local_config_file
    local stat = uv.fs_stat(candidate)
    if stat and stat.type == "file" then
      return candidate
    end

    local parent = dir:match("^(.*)/[^/]*$") -- go up one level
    if not parent or parent == dir then break end
    dir = parent
  end

  return nil
end

local function read_config(path)
  local lines = vim.fn.readfile(path)
  if not lines or #lines == 0 then return nil end
  local text = table.concat(lines, "\n")
  local ok, decoded = pcall(vim.fn.json_decode, text)
  if not ok then
    vim.notify("simplug: invalid JSON in " .. path, vim.log.levels.ERROR)
    return nil
  end
  return decoded
end 

local function clear_commands()
    for name, _ in pairs(M.local_config) do
        pcall(vim.api.nvim_del_user_command, name)
    end
    M.local_config = {}
end

function M.refresh()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then return end

    local dir = vim.fn.fnamemodify(name, ":p:h")
    local cfg_path = find_project_root(dir)
    local root_dir = cfg_path and vim.fn.fnamemodify(cfg_path, ":h")

    if not cfg_path then
        clear_commands()
        return
    end

    M.local_config = read_config(cfg_path)
    clear_commands()

    -- Define all the project-local user specified commands
    for name, command in pairs(M.local_config) do
        define(name, command)
    end
end

return M
