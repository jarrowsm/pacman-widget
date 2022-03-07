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
config.prompt_bg_color = '#222222'
config.prompt_border_width = 1
config.prompt_border_color = '#7e7e7e'
config.prompt_show = 5
config.prompt_width = 300

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
   
    local rows = wibox.layout.fixed.vertical()
    
    local ptr = 0
    rows:connect_signal("button::press", function(_,_,_,button)
          if button == 4 then
              if ptr > 0 then
                  rows.children[ptr].visible = true
                  ptr = ptr - 1
              end
          elseif button == 5 then
              if ptr < #rows.children and ((#rows.children - ptr) > _config.prompt_show) then
                  ptr = ptr + 1
                  rows.children[ptr].visible = false
              end
          end
       end)
    

    local prompt = wibox {
        border_width = _config.prompt_border_width,
        border_color = _config.prompt_border_color,
        width = _config.prompt_width,
        ontop = true,
        visible = false,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
    }

    pacman_widget:buttons(
        awful.util.table.join(
            awful.button({}, 1, function()
                if prompt.visible then
                    prompt.visible = false
                else
                    prompt.visible = true
                    awful.placement.top(prompt, 
                        { 
                            margins = { top = 25 },
                            parent = mouse
                        })
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
            
            local prompt_header_height = 30
            local prompt_row_height = 18

            local header = wibox.widget {
                markup = '<b>' .. avail .. 'Available Upgrades</b>',
                align = 'center',
                forced_height = prompt_header_height,
                widget = wibox.widget.textbox,
            }
            
            for i = 1, n_upgrades do
                local row
                row = wibox.widget{
                    {
                        text = tostring(i),
                        widget = wibox.widget.textbox
                    },
                    {
                        text = upgrades_tbl[i],
                        forced_height = prompt_row_height,
                        paddings = 1,
                        --margins = 4,
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.ratio.horizontal,
                }
                row:ajust_ratio(2, 0.1, 0.9, 0)
                rows:add(row)
            end
            
            local displ
            if n_upgrades < _config.prompt_show then
                displ = n_upgrades
            else
                displ = _config.prompt_show
            end

            prompt:geometry {
                height = 17 + prompt_header_height + displ * (prompt_row_height + 1.05)
            }
            prompt:setup {
                {
                    {
                        header,
                        rows,
                        layout = wibox.layout.fixed.vertical,
                    },
                    content_fill_horizontal = true,
                    layout = wibox.container.place
                },
                margins = 10,
                layout = wibox.container.margin
            }
       end,
       pacman_widget
    )
   return pacman_widget
end

return setmetatable(pacman_widget, { __call = function(_, ...)
    return worker(...)
end })

