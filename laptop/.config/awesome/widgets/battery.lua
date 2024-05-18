local wibox = require("wibox")
local beautiful = require("beautiful")
local utils = require("utils")
local naughty = require("naughty")
local watch = require("awful.widget.watch")

local DEFAULT_OPTS = {
	timeout = 10,
	bat_item = 0,
	notify = true,
	notification_level = {
		happy = 70,
		tired = 50,
		sad = 20,
	},
}

local ICONS = {
	normal = {
		[0] = "/usr/share/icons/breeze-dark/status/16/battery-000.svg",
		[10] = "/usr/share/icons/breeze-dark/status/16/battery-010.svg",
		[20] = "/usr/share/icons/breeze-dark/status/16/battery-020.svg",
		[30] = "/usr/share/icons/breeze-dark/status/16/battery-030.svg",
		[40] = "/usr/share/icons/breeze-dark/status/16/battery-040.svg",
		[50] = "/usr/share/icons/breeze-dark/status/16/battery-050.svg",
		[60] = "/usr/share/icons/breeze-dark/status/16/battery-060.svg",
		[70] = "/usr/share/icons/breeze-dark/status/16/battery-070.svg",
		[80] = "/usr/share/icons/breeze-dark/status/16/battery-080.svg",
		[90] = "/usr/share/icons/breeze-dark/status/16/battery-090.svg",
		[100] = "/usr/share/icons/breeze-dark/status/16/battery-100.svg",
	},
	charging = {
		[0] = "/usr/share/icons/breeze-dark/status/16/battery-000-charging.svg",
		[10] = "/usr/share/icons/breeze-dark/status/16/battery-010-charging.svg",
		[20] = "/usr/share/icons/breeze-dark/status/16/battery-020-charging.svg",
		[30] = "/usr/share/icons/breeze-dark/status/16/battery-030-charging.svg",
		[40] = "/usr/share/icons/breeze-dark/status/16/battery-040-charging.svg",
		[50] = "/usr/share/icons/breeze-dark/status/16/battery-050-charging.svg",
		[60] = "/usr/share/icons/breeze-dark/status/16/battery-060-charging.svg",
		[70] = "/usr/share/icons/breeze-dark/status/16/battery-070-charging.svg",
		[80] = "/usr/share/icons/breeze-dark/status/16/battery-080-charging.svg",
		[90] = "/usr/share/icons/breeze-dark/status/16/battery-090-charging.svg",
		[100] = "/usr/share/icons/breeze-dark/status/16/battery-100-charging.svg",
	}
}

local NOTI_TYPE = { NONE = nil, HAPPY = "happy", SAD = "sad", TIRED = "tired", CHARGING = "charging" }

return function(opts)
	opts = utils.misc.tbl_override(DEFAULT_OPTS, opts or {})

	local state = {
		current_level = 0,
		current_color = "",
		notified = NOTI_TYPE.NONE,
	}

	local notify = function(type, text)
		local preset_type = type == NOTI_TYPE.CHARGING and "normal" or "critical"
		if opts.notify and state.notified ~= type then
			naughty.notify({
				preset = naughty.config.presets[preset_type],
				text = text,
			})
			state.notified = type
		end
	end

	local icon = wibox.widget({
		image = ICONS.normal[state.current_level],
		align = "center",
		valign = "center",
		widget = wibox.widget.imagebox,
	})

	local percentage_text = wibox.widget({
		id = "percent_text",
		text = state.current_level .. "%",
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

	watch("acpi -i", opts.timeout, function(_, stdout)
		local status, charge_str, _ =
			string.match(stdout, "Battery " .. opts.bat_item .. ": ([%a%s]+), (%d?%d?%d)%%,?(.*)")

		--------------------------------------------------------
		local level = math.floor(tonumber(charge_str))
		local tens = math.floor(level / 10) * 10
		local color = beautiful.fg_normal

		if status == "Charging" then
			color = beautiful.battery_charging
			icon.image = ICONS.charging[state.current_level]
			notify(NOTI_TYPE.CHARGING, "🌲 Charging...")
		elseif level <= opts.notification_level.sad then
			color = beautiful.battery_sad
			notify(NOTI_TYPE.SAD, "📛 Battery is low!")
		elseif level <= opts.notification_level.tired then
			color = beautiful.battery_tired
			notify(NOTI_TYPE.TIRED, "⚠️ Battery is getting low!")
		end

		percentage_text.text = level .. "%"
		percentage.fg = color

		if state.current_color ~= color or state.current_level ~= tens then
			icon.image = ICONS.normal[tens]
		end

		state.current_level = tens
		state.current_color = color
	end)

	return widget
end
