local wibox = require("wibox")
local watch = require("awful.widget.watch")
local beautiful = require('beautiful')

local ICON_DIR = os.getenv("HOME") .. "/.config/awesome/pacman-widget/icons/"

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
    watch([[bash -c "checkupdates 2>/dev/null | wc -l"]],
        _config.interval,
        function(widget, stdout)
            for line in stdout:gmatch("[^\r\n]+") do
                if tonumber(line) > 0 then
                    widget:set_value(line)
                    return
                end
           end
       end,
       pacman_widget
    )
   return pacman_widget
end

return setmetatable(pacman_widget, { __call = function(_, ...)
    return worker(...)
end })

