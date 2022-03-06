local wibox = require("wibox")
local watch = require("awful.widget.watch")
local beautiful = require('beautiful')

local SCRIPT_DIR = os.getenv("HOME") .. "/.config/awesome/pacman-widget/"
local ICON_DIR = os.getenv("HOME") .. "/.config/awesome/pacman-widget/icons/"

local function GET_SCRIPT_DIR(SCRIPT_DIR) return string.format([[bash -c %spac.sh]], SCRIPT_DIR) end

local widget = {}
local pacman_widget = {}
local config = {}

config.interval = 600


local function worker(user_args)
    local args = user_args or {}
    local _config = {}
    for prop, value in pairs(config) do
        _config[prop] = args[prop] or beautiful[prop] or value
    end

    pacman_widget = wibox.widget {
       {
          {
              id = 'icon',
              resize = false,
              widget = wibox.widget.imagebox,
          },
          valign = 'center',
          layout = wibox.container.place,
       },
       {
           id = 'txt',
           font = font,
           widget = wibox.widget.textbox
       },
       spacing = 5,
       layout = wibox.layout.fixed.horizontal,
       set_value = function(self, new_value)
           self:get_children_by_id('txt')[1]:set_text(new_value)
           self:get_children_by_id('icon')[1]:set_image(ICON_DIR .. 'pacman.svg')
       end
    } 
    watch(GET_SCRIPT_DIR(SCRIPT_DIR),
       _config.interval,
       function(widget, stdout)
           for line in stdout:gmatch("[^\r\n]+") do
               widget:set_value(line)
               return
           end
       end,
       pacman_widget
    )
   return pacman_widget
end

return setmetatable(pacman_widget, { __call = function(_, ...)
    return worker(...)
end })

