local M = {}

local local_config_file = ".simbuild.json"

M.config = {
    ["Make"] = "make",
}

M.local_config = {}

local function define(name, cmd, dir)
    vim.api.nvim_create_user_command(name, function(opts)
            local prev = vim.uv.cwd()
            vim.cmd("new")
            vim.cmd("wincmd J")
            vim.cmd("res 10")
            vim.uv.chdir(dir)
            vim.cmd("term " .. cmd .. " " .. table.concat(opts.fargs, " "))
            vim.uv.chdir(prev)
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
        for name, opts in pairs(user_config) do
            define(name, opts, vim.uv.cwd())
        end
    end
end

local function get_parent_dir(path)
    return path:match("^(.*)/[^/]*$")
end

local function find_project_root(start_dir)
  local dir = start_dir

  while dir do
    local candidate = dir .. "/" .. local_config_file
    if vim.fn.filereadable(candidate) == 1 then
        vim.notify("Simbuild: " .. local_config_file .. " found") 
        return candidate
    end

    dir = get_parent_dir(dir) -- go up one level
  end

  return nil
end

local function read_config(path)
    -- Open
    local f = io.open(path, "r") 
    if f then 
        -- Read full file
        local content = f:read("*a") 
        f:close()
        -- check for nil or false and length <= 0
        if content and #content > 0 then 
            local ok, decoded = pcall(vim.fn.json_decode, content)
            if ok and type(decoded) == "table" then -- success and correct type
                return decoded 
            else
                vim.notify("Simbuild: invalid JSON in " .. path, vim.log.levels.ERROR)
            end
        end
    end
    return nil
end 

local function clear_commands()
    for name, _ in pairs(M.local_config) do
        pcall(vim.api.nvim_del_user_command, name)
    end
    M.local_config = {}
end

function M.refresh()
    local cfg_path = find_project_root(vim.uv.cwd())
    clear_commands()
    if not cfg_path then return end
    M.local_config = read_config(cfg_path)

    -- Define all the project-local user specified commands
    for name, cmd in pairs(M.local_config) do
        define(name, cmd, get_parent_dir(cfg_path))
        vim.notify("Simbuild: added command '" .. name .. "'")
    end
end

return M
