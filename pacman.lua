local wibox = require("wibox")
local awful = require("awful")
local beautiful = require('beautiful')
local gears = require("gears")

local ICON_DIR = os.getenv("HOME") .. "/.config/awesome/pacman-widget/icons/"

local widget = {}
local pacman_widget = {}
local config = {}

config.interval = 600
config.popup_bg_color = '#222222'
config.popup_border_width = 1
config.popup_border_color = '#7e7e7e'
config.popup_height = 10
config.popup_width = 300

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
    } 
    function pacman_widget:set(new_value)
        pacman_widget:get_children_by_id('txt')[1]:set_text(new_value)
        local icon
        if tonumber(new_value) > 0 then
            icon = 'pacman'
        else
            icon = 'pacman-full'
        end
        pacman_widget:get_children_by_id('icon')[1]:set_image(ICON_DIR .. icon .. '.svg')
    end
   
    local rows = wibox.layout.fixed.vertical()
    
    local ptr = 0
    rows:connect_signal("button::press", function(_,_,_,button)
          if button == 4 then
              if ptr > 0 then
                  rows.children[ptr].visible = true
                  ptr = ptr - 1
              end
          elseif button == 5 then
              if ptr < #rows.children and ((#rows.children - ptr) > _config.popup_height) then
                  ptr = ptr + 1
                  rows.children[ptr].visible = false
              end
          end
       end)
    
    local popup = awful.popup {
        border_width = _config.popup_border_width,
        border_color = _config.popup_border_color,
        shape = gears.shape.rounded_rect,
        visible = false,
        ontop = true,
        offset = { y = 5},
        widget = {}
    }

    pacman_widget:buttons(
        awful.util.table.join(
            awful.button({}, 1, function()
                if popup.visible then
                    popup.visible = false
                else
                    popup.visible = true
                    popup:move_next_to(mouse.current_widget_geometry)
                end
            end)
        )
    )

    awful.widget.watch([[bash -c "checkupdates 2>/dev/null"]],
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
           
            widget:set(#upgrades_tbl)
           
            local avail = ""
            if #upgrades_tbl == 0 then
                avail = "No "
            end
            
            local popup_header_height = 30
            local popup_row_height = 20

            local header = wibox.widget {
                markup = '<b>' .. avail .. 'Available Upgrades</b>',
                align = 'center',
                forced_height = popup_header_height,
                widget = wibox.widget.textbox,
            }

            -- package got added
            for k, v in ipairs(upgrades_tbl) do
                for i = 1, #rows.children do
                    if v == rows.children[i]:get_txt() then goto continue end
                end
                for j = k, #rows.children do  -- increment indeces after added
                    rows.children[j]:set_idx(tostring(j+1))
                end
                
                local row = wibox.widget{
                    {
                        id = 'idx',
                        text = tostring(k),
                        widget = wibox.widget.textbox
                    },
                    {
                        id = 'txt',
                        text = v,
                        forced_height = popup_row_height,
                        paddings = 1,
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.ratio.horizontal,
                }
                function row:get_txt() return row:get_children_by_id('txt')[1].text end
                function row:set_idx(idx) row:get_children_by_id('idx')[1]:set_text(idx) end
                row:ajust_ratio(2, 0.1, 0.9, 0)
                rows:insert(k, row)
                ::continue::
            end

            -- package got removed
            for i = 1, #rows.children do
                for _, v in ipairs(upgrades_tbl) do
                    if v == rows.children[i]:get_txt() then goto continue end
                end
                for j = i+1, #rows.children do  -- decrement indeces after removed
                    rows.children[j]:set_idx(tostring(j-1))
                end
                rows:remove(i)
                break
                ::continue::
            end

            local height = popup_header_height + math.min(#upgrades_tbl, _config.popup_height) * popup_row_height
            popup:setup {
                {
                    {
                        {
                            {
                                header,
                                rows,
                                forced_height = height,
                                layout = wibox.layout.fixed.vertical
                            },
                            content_fill_horizontal = true,
                            layout = wibox.container.place
                        },
                        margins = 10,
                        layout = wibox.container.margin
                    },
                    bg = _config.popup_bg_color,
                    layout = wibox.widget.background
                },
                forced_width = _config.popup_width,
                layout = wibox.layout.fixed.horizontal
            }
       end,
       pacman_widget
    )
   return pacman_widget
end

return setmetatable(pacman_widget, { __call = function(_, ...) return worker(...) end })

