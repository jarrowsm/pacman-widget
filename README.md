# Pacman widget for AwesomeWM

This widget shows the number of upgradable Pacman packages on a given interval.

![](screenshots/pacman.png)

## Installation

Clone the repo under **~/.config/awesome/** and add the following to **rc.lua**:

```lua
local pacman_widget = require('pacman-widget.pacman')
...
s.mytasklist, -- Middle widget
	{ -- Right widgets
    	layout = wibox.layout.fixed.horizontal,
        ...
        -- default (10 minute interval)
        pacman_widget(),
        -- custom interval
        pacman_widget{
            interval = 300
        },
```

