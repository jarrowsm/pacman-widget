local wibox = require("wibox")
local watch = require("awful.widget.watch")
local beautiful = require('beautiful')

local SCRIPT_DIR = "~/.config/awesome/pacman-widget/pac.sh"
local function GET_SCRIPT_DIR(SCRIPT_DIR) return string.format([[bash -c %s]], SCRIPT_DIR) end

local widget = {}
local pacman_widget = {}
local config = {}

config.refresh_rate = 600


local function worker(user_args)
    local args = user_args or {}
    local _config = {}
    for prop, value in pairs(config) do
        _config[prop] = args[prop] or beautiful[prop] or value
    end

    pacman_widget = wibox.widget {
       {
          {
              id = 'label',
              font = font,
              widget = wibox.widget.textbox,
          },
          forced_width = 40,
          valign = 'center',
          halign = 'left',
          layout = wibox.container.place,
       },
       {
           id = 'txt',
           font = font,
           widget = wibox.widget.textbox
       },
       layout = wibox.layout.fixed.horizontal,
       set_value = function(self, new_value)
           self:get_children_by_id('label')[1]:set_text("PAC")
           self:get_children_by_id('txt')[1]:set_text(new_value)
       end
    } 
    watch(GET_SCRIPT_DIR(SCRIPT_DIR),
       _config.refresh_rate,
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

