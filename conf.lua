function love.conf(t)
    t.identity = "msg_jit_game" -- The name of the save directory
    t.version = "11.5"          -- The LÖVE version this game was made for

    t.window.title = "JIT Game"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.minwidth = 800
    t.window.minheight = 600

    t.console = true            -- Attach a console (Windows only)
end
