-- get the config dir path
local config_dir = os.getenv("HOME") .. "/.config/yay"

-- append to Lua package.path so it knows where to look
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

-- options
yay.opt.diff_menu = true -- Show diff menu before building.

-- hooks
require("hooks.maintainer_change")
require("hooks.recently_modified")
