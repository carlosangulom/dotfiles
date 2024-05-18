-- local awful = require("awful")
-- local naughty = require("naughty")

-- return function()
-- 	local widget = nil
-- 	local noti_obj = nil

-- 	local cmd_set = "pactl set-sink-volume 1"
-- 	local cmd_get = "pactl get-sink-volume 1"
-- 	local cmd_inc = cmd_set .. " 5%+"
-- 	local cmd_dec = cmd_set .. " 5%-"
-- 	local cmd_toggle = "pactl set-sink-mute 1 toggle"

-- 	local get_level = function(cb)
-- 		awful.spawn.easy_async(cmd_get, function(out)
-- 			local level, status = string.match(out, "%[(%d+)%%%] %[(%a+)%]")
-- 			cb(level, status)
-- 		end)
-- 	end

-- 	local action = function(cmd)
-- 		awful.spawn.easy_async(cmd, function()
-- 			get_level(function(level, status)
-- 				local percentage = level .. "%"
-- 				local text = status == "on" and "Volume: " .. percentage or "[Muted] " .. percentage

-- 				if widget then
-- 					widget:emit_signal("volume::update", level, status)
-- 				end

-- 				noti_obj = naughty.notify({
-- 					replaces_id = noti_obj ~= nil and noti_obj.id or nil,
-- 					text = text,
-- 				})
-- 			end)
-- 		end)
-- 	end

-- 	return {
--     get_level = get_level,
-- 		increase = function()
-- 			action(cmd_inc)
-- 		end,
-- 		decrease = function()
-- 			action(cmd_dec)
-- 		end,
-- 		toggle = function()
-- 			action(cmd_toggle)
-- 		end,
-- 		set_widget = function(w)
-- 			widget = w
-- 		end,
-- 	}
-- end

local awful = require("awful")
local naughty = require("naughty")

return function()
	local widget = nil
	local noti_obj = nil

	local cmd_set = "pactl set-sink-volume 0"
	local cmd_get = "pactl get-sink-volume 0"
	local cmd_get_mute = "pactl get-sink-mute 0"
	-- local cmd_get_mute = "pactl get-sink-mute"
	local cmd_inc = cmd_set .. " +5%"
	local cmd_dec = cmd_set .. " -5%"
	local cmd_toggle = "pactl set-sink-mute 0 toggle"

	local get_level = function(cb)
		 
		awful.spawn.easy_async(cmd_get, function(out)
			local level = string.match(out, "Volume: front%-left: (%d+) /")
			level = math.floor(tonumber(level) / 650)  -- Convert to percentage
			cb(level)
		end)
		
	end

	local get_status = function(cb)
		awful.spawn.easy_async(cmd_get_mute, function(out)
			local status = string.match(out, "Mute: (%a+)")
			cb(status)
		end)
	end

	local action = function(cmd)
		awful.spawn.easy_async(cmd, function()
			get_level(function(level)
				get_status(function (status)
					local percentage = string.format("%.0f%%", level)  -- Format as a percentage string
				local status = string.format("%s", status)

				local text = (status == "no" and "Volume: " or "[Muted] ") .. percentage

				if widget then
					widget:emit_signal("volume::update", level, status)
				end

				noti_obj = naughty.notify({
					replaces_id = noti_obj ~= nil and noti_obj.id or nil,
					text = text,
				})
				end)

			end)
		end)
	end

	return {
		get_level = get_level,
		get_status = get_status,
		increase = function()
			action(cmd_inc)
		end,
		decrease = function()
			action(cmd_dec)
		end,
		toggle = function()
			action(cmd_toggle)
		end,
		set_widget = function(w)
			widget = w
		end,
	}
end

