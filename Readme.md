# Mythic-MDT
-- Add to Server/Component.lua
# Add

		Dispatch411 = function(self, message)
			for k, v in ipairs(GetPlayers()) do
				local duty = Player(v).state.onDuty
				if duty == "police" or duty == "prison" then
					TriggerClientEvent("chat:addMessage", v, {
						time = os.time(),
						type = "411",
						message = message,
					})
				end
			end
		end,
		DispatchDOC = function(self, message)
			for k, v in ipairs(GetPlayers()) do
				local duty = Player(v).state.onDuty
				if duty == "prison" then
					TriggerClientEvent("chat:addMessage", v, {
						time = os.time(),
						type = "411A",
						message = message,
					})
				end
			end
		end,


# Example
		Dispatch411 = function(self, message)
			for k, v in ipairs(GetPlayers()) do
				local duty = Player(v).state.onDuty
				if duty == "police" or duty == "prison" then
					TriggerClientEvent("chat:addMessage", v, {
						time = os.time(),
						type = "411",
						message = message,
					})
				end
			end
		end,
		DispatchDOC = function(self, message)
			for k, v in ipairs(GetPlayers()) do
				local duty = Player(v).state.onDuty
				if duty == "prison" then
					TriggerClientEvent("chat:addMessage", v, {
						time = os.time(),
						type = "411A",
						message = message,
					})
				end
			end
		end,
		Dispatch = function(self, source, message)
			TriggerClientEvent("chat:addMessage", source, {
				time = os.time(),
				type = "dispatch",
				message = message,
			})
		end,





