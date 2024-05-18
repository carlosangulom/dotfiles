local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")

local ICONS = {
	normal = {
		high = "/usr/share/icons/breeze-dark/status/16/audio-volume-high.svg",
		low = "/usr/share/icons/breeze-dark/status/16/audio-volume-low.svg",
		medium = "/usr/share/icons/breeze-dark/status/16/audio-volume-medium.svg",
		mute = "/usr/share/icons/breeze-dark/status/16/audio-volume-muted.svg",
	},
}

local current_level = 50
local current_status = "no"

local get_icon = function(level, status)
	level = tonumber(level)
	status = string.format("%s", status)

	if status == "yes" then
		return ICONS.normal.mute
	end

	if level >= 75 then
		return ICONS.normal.high
	elseif (level < 75 and level >= 25) then
		return ICONS.normal.medium
	else
		return ICONS.normal.low
	end
end

local set_icon = function(percentage, icon, level, status)
	percentage.text = level .. "%"
	icon.image = get_icon(level, status)
end

return function()
	local icon = wibox.widget({
		image = get_icon(current_level),
		-- forced_width = beautiful.spacing_xl,
		align = "center",
		valign = "center",
		widget = wibox.widget.imagebox,
	})

	local percentage_text = wibox.widget({
		id = "percent_text",
		font = beautiful.font,
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local percentage = wibox.container.background(percentage_text)

	local widget = wibox.widget({
		icon,
		percentage,
		spacing = beautiful.spacing,
		layout = wibox.layout.fixed.horizontal,
	})

	widget:connect_signal("volume::update", function(_, level, status)
		if current_level ~= level or current_status ~= status then
      set_icon(percentage_text, icon, level, status)
		end

		current_level = level
		current_status = status
	end)

	widget:connect_signal("volume::update", function(_, level, status)
		set_icon(percentage_text, icon, level, status)
		current_level = level
		current_status = status
	end)

	utils.volume.get_level(function(level)
		utils.volume.get_status(function (status)
			set_icon(percentage_text, icon, level, status)
		end)
	end)

	return widget
end
