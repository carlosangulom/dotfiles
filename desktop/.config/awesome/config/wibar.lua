local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local utils = require("utils")
local constants = require("constants")
local my_widgets = require("widgets")

local volume = my_widgets.volume()
utils.volume.set_widget(volume)

local mods = constants.mods

local cw = my_widgets.calendar({
    placement = 'top_right',
})
local date = wibox.widget.textclock("%a %b %d %Y")

date:connect_signal("button::press", function(_, _, _, button)
	if button == 1 then
		cw.toggle()
	end
end)

local clock = wibox.widget.textclock("%H:%M")

local DEFAULT_OPTS = {
	widget_spacing = beautiful.spacing,
	bg = beautiful.bg_normal,
}

local wrap_bg = function(widgets, opts)
	opts = utils.misc.tbl_override(DEFAULT_OPTS, opts or {})

	if type(widgets) == "table" then
		widgets.spacing = opts.widget_spacing
	end

	return wibox.widget({
		{
			widgets,
			left = beautiful.spacing_lg,
			right = beautiful.spacing_lg,
			top = beautiful.spacing,
			bottom = beautiful.spacing,
			widget = wibox.container.margin,
		},
		shape = utils.ui.rounded_rect(20),
		bg = opts.bg,
		widget = wibox.container.background,
	})
end

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ mods.m }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ mods.m }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

awful.screen.connect_for_each_screen(function(s)
	utils.ui.set_wallpaper(s)

	-- Each screen has its own tag table.
	if s.index==1 then
		awful.tag(utils.misc.range(1, 9), s, awful.layout.layouts[1])
	elseif s.index==2 then
		awful.tag.add("1", {
			layout= awful.layout.layouts[1],
			master_count = 3,
			screen = s,
			selected = true,
		})
		awful.tag.add("2", {
			layout= awful.layout.layouts[1],
			master_count = 3,
			screen = s,
			selected = false,
		})
		-- awful.tag(utils.misc.range(2, 9), s, awful.layout.layouts[2])
	end

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		buttons = taglist_buttons,
		filter = awful.widget.taglist.filter.all,
		layout = {
			layout = wibox.layout.fixed.horizontal,
			spacing = beautiful.spacing,
		},
		style = { shape = gears.shape.circle },
		widget_template = {
			{
				{
					{
						id = "text_role",
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				left = beautiful.spacing,
				right = beautiful.spacing,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
		},
	})

	s.mywibox = awful.wibar({
		height = beautiful.bar_height,
		type = "dock",
		bg = "#00000000",
		position = "top",
		screen = s,
	})

	if s.index==1 then
		s.mywibox:setup({
			{
				layout = wibox.layout.stack,
				{
					layout = wibox.layout.align.horizontal,
					{ -- Left widgets
						layout = wibox.layout.fixed.horizontal,
						wrap_bg(s.mytaglist),
					},
					nil,
					{ -- Right widgets
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.spacing,
						wrap_bg(wibox.widget.systray()),
						wrap_bg({
							layout = wibox.layout.fixed.horizontal,
							volume,
						}, { widget_spacing = beautiful.spacing_lg }),
						wrap_bg(date),
					},
					widget = wibox.container.margin,
				},
				{
					wrap_bg(clock),
					valign = "center",
					halign = "center",
					layout = wibox.container.place,
				},
			},
			left = beautiful.useless_gap * 2,
			right = beautiful.useless_gap * 2,
			top = beautiful.useless_gap * 2,
			widget = wibox.container.margin,
		})
	elseif s.index==2 then
		s.mywibox:setup({
			{
				layout = wibox.layout.stack,
				{
					layout = wibox.layout.align.horizontal,
					{ -- Left widgets
						layout = wibox.layout.fixed.horizontal,
						wrap_bg(s.mytaglist),
					},
					nil,
					{ -- Right widgets
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.spacing,
						-- wrap_bg({
						-- 	layout = wibox.layout.fixed.horizontal,
						-- 	volume,
						-- }, { widget_spacing = beautiful.spacing_lg }),
						wrap_bg(date),
					},
					widget = wibox.container.margin,
				},
				{
					wrap_bg(clock),
					valign = "center",
					halign = "center",
					layout = wibox.container.place,
				},
			},
			left = beautiful.useless_gap * 2,
			right = beautiful.useless_gap * 2,
			top = beautiful.useless_gap * 2,
			widget = wibox.container.margin,
		})
	end
end)
