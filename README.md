# Pacman widget for AwesomeWM

This widget shows the number of upgradable Pacman packages on a given interval. Clicking the icon reveals a scrollable list of available upgrades.

![](screenshots/pacman.gif) ![](screenshots/pacman-full.png)

## Installation

Clone the repo under **~/.config/awesome/** and add the following to **rc.lua**:

```lua
local pacman_widget = require('pacman-widget.pacman')
...
s.mytasklist, -- Middle widget
	{ -- Right widgets
    	layout = wibox.layout.fixed.horizontal,
        ...
        -- default
        pacman_widget(),
        -- custom
        pacman_widget{
            interval = 300,
            prompt_bg_color = '#000000',
            prompt_border_width = 3,
            prompt_border_color = '#FFFFFF',
            prompt_height = 10,     -- No. packages shown in scrollable window
            prompt_width = 200
        },
```

