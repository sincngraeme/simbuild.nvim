# simbuild.nvim

A simple build interface for populating Neovim Quickfix list.

## Usage

It's in the name; *Sim*ple. Just install the plugin with your
favourite plugin manager, and call the setup function with a key value table for the command you wish to run. 

Here is an example using my plugin manager '`simplug.nvim`'.

```lua
return {
    link = "sincngraeme/simbuild.nvim"
    config = function()
        require("simbuild").setup({
            ["Make"] = "make",
            ["Cargo"] = "cargo"
        })
    end
}
```

This does appear to be redundant, but it is designed this way so
that you can easily make the command name something else if you
prefer. For example, "Mk" for "make". 

>[!note]
>Make is the only command set by default and can be overridden.

Then simply run your build commands with whatever name you set
from Neovim command mode, arguments will be forwarded to the
build command which will run in a terminal buffer. 

Once the build command completes, the output will be passed to
the quickfix list.

If you want to open the build output in an OS window or tmux pane, use [vim-dispatch](https://github.com/tpope/vim-dispatch). This plugin was specifically created to overcome vim-dispatch's problems with neovim terminal buffers but it works very well with tmux panes or if working directly from the quickfix list.
