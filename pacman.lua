local wibox = require("wibox")
local awful = require("awful")
local watch = require("awful.widget.watch")
local beautiful = require('beautiful')
local gears = require("gears")

local ICON_DIR = os.getenv("HOME") .. "/.config/awesome/pacman-widget/icons/"

local widget = {}
local pacman_widget = {}
local config = {}

config.interval = 600
config.prompt_show = 20
config.prompt_bg_color = '#222222'
config.prompt_border_width = 1
config.prompt_border_color = '#7e7e7e'

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
            local icon
            if tonumber(new_value) > 0 then
                icon = 'pacman'
            else
                icon = 'pacman-full'
            end
            self:get_children_by_id('icon')[1]:set_image(ICON_DIR .. icon .. '.svg')
        end
    } 
    
    local rows = {
        { widget = wibox.widget.textbox },
        spacing = 4,
        layout = wibox.layout.fixed.vertical,
    }
    
    local prompt = awful.popup {
        border_width = _config.prompt_border_width,
        border_color = _config.prompt_border_color,
        bg = _config.prompt_bg_color,
        ontop = true,
        visible = false,
        shape = gears.shape.rounded_rect,
        maximum_width = 1000,
        offset = { y = 4 },
        widget = {}
    }

    pacman_widget:buttons(
        awful.util.table.join(
            awful.button({}, 1, function()
                if prompt.visible then
                    prompt.visible = false
                else
                    prompt:move_next_to(mouse.current_widget_geometry)
                end
            end)
        )
    )

    watch([[bash -c "checkupdates 2>/dev/null"]],
        _config.interval,
        function(widget, stdout)
            local upgrades = ""
            local upgrades_tbl = {}

            for line in stdout:gmatch("[^()]+") do
                upgrades = line
            end

            for value in string.gmatch(upgrades, '([^\n]+)') do
                upgrades_tbl[#upgrades_tbl+1] = value 
            end
           
            n_upgrades = #upgrades_tbl
            widget:set_value(n_upgrades)
           
            local avail = ""
            if n_upgrades == 0 then
                avail = "No "
            end
            
            local header = wibox.widget {
                markup = '<b>' .. avail .. 'Available Upgrades</b>',
                align = 'center',
                forced_height = 30,
                widget = wibox.widget.textbox,
            }

            for i = 1, n_upgrades do
                local row
                if i > _config.prompt_show then
                    row = wibox.widget{
                        align = 'center',
                        text = ".\n.\n(plus " .. n_upgrades - _config.prompt_show .. " more)",
                        widget = wibox.widget.textbox
                    }
                    rows[i] = row
                    break
                end
                row = wibox.widget{
                    {
                        text = tostring(i),
                        widget = wibox.widget.textbox
                    },
                    {
                        text = upgrades_tbl[i],
                        forced_height = 14,
                        paddings = 1,
                        margins = 4,
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.ratio.horizontal
                }
                row:ajust_ratio(2, 0.1, 0.9, 0)
                rows[i] = row
            end

            prompt:setup {
                {
                    header,
                    rows,
                    layout = wibox.layout.fixed.vertical,
                },
                margins = 5,
                widget = wibox.container.margin
            }
       end,
       pacman_widget
    )
   return pacman_widget
end

return setmetatable(pacman_widget, { __call = function(_, ...)
    return worker(...)
end })

