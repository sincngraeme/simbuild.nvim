local M = {}

M.config = {
    ["Make"] = "make",
}

local define = function(name, command)
    vim.api.nvim_create_user_command(name, function(opts)
        if opts.bang then
            -- vim.system(table.insert(opts.fargs, command), { text = true }, function(output)
            --     vim.cmd('cgetexpr ' .. output.stderr .. output.stdout)
            -- end)
            vim.cmd('cgetexpr ' .. vim.system(table.insert(opts.fargs, command)))
        else
            vim.cmd("new")
            vim.cmd("wincmd J")
            vim.cmd("res 10")
            vim.cmd("term " .. command .. " " .. table.concat(opts.fargs, " "))
            vim.cmd("startinsert")
        end
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

return M
