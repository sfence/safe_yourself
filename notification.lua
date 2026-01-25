
local S = safe_yourself.translator
local settings = safe_yourself.settings

-- Send notification to player about rescue commands
local function send_rescue_notification(player, reason)
	local player_name = player:get_player_name()
	
	local message = S("Warning: @1", reason) .. "\n" ..
		S("If you get stuck in death loop, use these commands:") .. "\n" ..
		S("  /@1 - Respawn yourself", settings.respawn_command) .. "\n" ..
		S("  /@1 - Set HP to 1 if you have 0 HP", settings.one_hp_command)
	
	-- Send as chat message with configurable warning color
	core.chat_send_player(player_name, core.colorize(settings.notification_color, message))
end

-- Check protocol version on player join
core.register_on_joinplayer(function(player)
	if not settings.notify_old_clients then
		return
	end
	
	-- Wait a bit to ensure player is fully connected
	core.after(settings.notification_delay, function()
		local player_name = player:get_player_name()
		if not player_name then
			return
		end
		
		-- Re-get player object to ensure it's still valid
		player = core.get_player_by_name(player_name)
		if not player then
			return
		end
		
		-- Get player information including protocol version
		local info = core.get_player_information(player_name)
		if not info then
			return
		end
		
		-- Check protocol version
		local version = core.get_version()
		if info.protocol_version and info.protocol_version < version.proto_max then
			local player_client = table.keyof(core.protocol_versions, info.protocol_version)
			local server_version= table.keyof(core.protocol_versions, version.proto_max)
			local reason = S("You are using an old client v@1, clients of v@2+ are recommended",
				player_client, server_version)
			send_rescue_notification(player, reason)
			
			-- Log for server admin
			core.log("warning", "[safe_yourself] Player " .. player_name .. 
				" connected with old protocol version " .. info.protocol_version)
		end
	end)
end)
