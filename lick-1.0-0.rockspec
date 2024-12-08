package = "lick"
version = "1.0-0"
source = {
    url = "git://github.com/usysrc/lick",
    tag = "v1.0.0"
}
description = {
    summary = "A small live coding library for LÖVE",
    detailed = [[The livecoding library for LÖVE provides a simple and efficient way to live code in the LÖVE framework. It allows developers to see changes in their code in real-time without restarting the application. This is achieved by monitoring file changes and reloading the necessary files automatically.
- Automatic Reloading: Watches for changes in your source files and reloads them as needed.
- Error Handling: Redirects errors to the command line or displays them on the screen, making debugging easier.
- **Customizable: Offers several optional parameters to customize the behavior of the live coding environment.
]]
}
dependencies = {
    "lua >= 5.1"
}
build = {
    type = "builtin",
    modules = {
        ["lick"] = "lick.lua"
    }
}