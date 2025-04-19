



-- Add to chat resource component.lua
-- Add to CHAT.Send = {
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






-- Like this in your component.lua
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