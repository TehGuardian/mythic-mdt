AddEventHandler('MDT:Server:RegisterCallbacks', function()
	Callbacks:RegisterServerCallback('MDT:Hire', function(source, data, cb)
		local char = Fetch:Source(source):GetData('Character')

		local isSystemAdmin = char:GetData('MDTSystemAdmin')
		local hasPerms, loggedInJob = CheckMDTPermissions(source, {
			'MDT_HIRE',
			'PD_HIGH_COMMAND',
			'DOC_HIGH_COMMAND',
		}, data.JobId)

		if char and data.SID and data.WorkplaceId and data.GradeId and (hasPerms or isSystemAdmin) then
			local added = Jobs:GiveJob(data.SID, data.JobId, data.WorkplaceId, data.GradeId, true)
			cb(added)

			if added then
				Database.Game:updateOne({
					collection = 'characters',
					query = {
						SID = data.SID,
					},
					update = {
						['$push'] = {
							MDTHistory = {
								Time = (os.time() * 1000),
								Char = char:GetData('SID'),
								Log = string.format(
									'%s Hired Them To %s',
									char:GetData('First') .. ' ' .. char:GetData('Last'),
									json.encode(data)
								),
							},
						},
					},
				})
			end
		else
			cb(false)
		end
	end)

	Callbacks:RegisterServerCallback('MDT:Fire', function(source, data, cb)
		local char = Fetch:Source(source):GetData('Character')

		local isSystemAdmin = char:GetData('MDTSystemAdmin')
		local hasPerms, loggedInJob = CheckMDTPermissions(source, {
			'MDT_FIRE',
			'PD_HIGH_COMMAND',
			'DOC_HIGH_COMMAND',
		}, data.JobId)

		if char and data and data.SID and (hasPerms or isSystemAdmin) then
			local charData = MDT.People:View(data.SID)
			if charData then
				local canRemove = false
				if isSystemAdmin then
					canRemove = true
				else
					local plyrJob = Jobs.Permissions:HasJob(source, loggedInJob)
					for k, v in ipairs(charData.Jobs) do
						if v.Id == data.JobId then
							if plyrJob.Grade.Level > v.Grade.Level then
								canRemove = true
							end
							break
						end
					end
				end

				if canRemove then
					local removed = Jobs:RemoveJob(data.SID, data.JobId)
					cb(removed)

					if removed then
						local update = {
							['$push'] = {
								MDTHistory = {
									Time = (os.time() * 1000),
									Char = char:GetData('SID'),
									Log = string.format(
										'%s Fired Them From Job %s',
										char:GetData('First') .. ' ' .. char:GetData('Last'),
										data.JobId
									),
								},
							},
						}

						if (data.JobId == 'police' or data.JobId == 'ems') then
							update['$set'] = {
								Callsign = false,
							}
						end

						Database.Game:updateOne({
							collection = 'characters',
							query = {
								SID = data.SID,
							},
							update = update,
						}, function(success, results)
							if success then
								if (data.JobId == 'police' or data.JobId == 'ems') then
									local char = Fetch:SID(data.SID)
									if char then
										char:SetData('Callsign', false)
									end
								end
							end
						end)
					end
				else
					cb(false)
				end
			end
		else
			cb(false)
		end
	end)

	Callbacks:RegisterServerCallback('MDT:ManageEmployment', function(source, data, cb)
		local char = Fetch:Source(source):GetData('Character')

		local isSystemAdmin = char:GetData('MDTSystemAdmin')
		local hasPerms, loggedInJob = CheckMDTPermissions(source, {
			'MDT_FIRE',
			'PD_HIGH_COMMAND',
			'DOC_HIGH_COMMAND',
		}, data.JobId)

		local newJobData = Jobs:DoesExist(data.data.Id, data.data.Workplace.Id, data.data.Grade.Id)

		if char and data and data.SID and (hasPerms or isSystemAdmin) and newJobData then
			local charData = MDT.People:View(data.SID)
			if charData then
				local canDoItBitch = false
				if isSystemAdmin then
					canDoItBitch = true
				else
					local plyrJob = Jobs.Permissions:HasJob(source, loggedInJob)
					for k, v in ipairs(charData.Jobs) do
						if v.Id == data.JobId then
							if plyrJob.Grade.Level > v.Grade.Level and plyrJob.Grade.Level > newJobData.Grade.Level then
								canDoItBitch = true
							end
							break
						end
					end
				end

				if canDoItBitch then
					local updated = Jobs:GiveJob(data.SID, newJobData.Id, newJobData.Workplace.Id, newJobData.Grade.Id)

					cb(updated)

					if updated then
						Database.Game:updateOne({
							collection = 'characters',
							query = {
								SID = data.SID,
							},
							update = {
								['$push'] = {
									MDTHistory = {
										Time = (os.time() * 1000),
										Char = char:GetData('SID'),
										Log = string.format(
											'%s Promoted Them To %s',
											char:GetData('First') .. ' ' .. char:GetData('Last'),
											json.encode(newJobData)
										),
									},
								},
							},
						})
					end
				else
					cb(false)
				end
			end
		else
			cb(false)
		end
	end)

    Callbacks:RegisterServerCallback('MDT:Update:jobPermissions', function(source, data, cb)
		local char = Fetch:Source(source):GetData('Character')
		local isSystemAdmin = char:GetData('MDTSystemAdmin')
		local hasPerms, loggedInJob = CheckMDTPermissions(source, {
			'PD_HIGH_COMMAND',
			'SAFD_HIGH_COMMAND',
			'DOC_HIGH_COMMAND',
		}, data.JobId)

		local targetData = Jobs:DoesExist(data.JobId, data.WorkplaceId, data.GradeId)

		if char and data and data.UpdatedPermissions and (hasPerms or isSystemAdmin) and targetData then
            local plyrJob = Jobs.Permissions:HasJob(source, loggedInJob)
            if isSystemAdmin or (plyrJob and plyrJob.Grade.Level > targetData.Grade.Level) then
                cb(
                    Jobs.Management.Grades:Edit(data.JobId, data.WorkplaceId, data.GradeId, {
                        Permissions = data.UpdatedPermissions,
                    })
                )
            else
                cb(false)
            end
		else
			cb(false)
		end
	end)

	Callbacks:RegisterServerCallback('MDT:Suspend', function(source, data, cb)
		local char = Fetch:Source(source):GetData('Character')

		local isSystemAdmin = char:GetData('MDTSystemAdmin')
		local hasPerms, loggedInJob = CheckMDTPermissions(source, {
			'MDT_FIRE',
			'PD_HIGH_COMMAND',
			'DOC_HIGH_COMMAND',
		}, data.JobId)

		if char and data and data.SID and (hasPerms or isSystemAdmin) then
			local charData = MDT.People:View(data.SID)
			if charData then
				local canRemove = false
				if isSystemAdmin then
					canRemove = true
				else
					local plyrJob = Jobs.Permissions:HasJob(source, loggedInJob)
					for k, v in ipairs(charData.Jobs) do
						if v.Id == data.JobId then
							if plyrJob.Grade.Level > v.Grade.Level then
								canRemove = true
							end
							break
						end
					end
				end

				if canRemove and data.Length and type(data.Length) == 'number' and data.Length > 0 and data.Length < 99 then
					local suspendData = {
						Actioned = {
							First = char:GetData('First'),
							Last = char:GetData('Last'),
							SID = char:GetData('SID'),
							Callsign = char:GetData('Callsign')
						},
						Length = data.Length,
						Expires = os.time() + (60 * 60 * 24 * data.Length),
					}

					Database.Game:updateOne({
						collection = 'characters',
						query = {
							SID = data.SID,
						},
						update = {
							['$push'] = {
								MDTHistory = {
									Time = (os.time() * 1000),
									Char = char:GetData('SID'),
									Log = string.format(
										'%s Suspended Them From Job %s for %s Days',
										char:GetData('First') .. ' ' .. char:GetData('Last'),
										data.JobId,
										data.Length
									),
								},
							},
							['$set'] = {
								[string.format('MDTSuspension.%s', data.JobId)] = suspendData
							}
						},
					}, function(success, results)
						if success then
							local char = Fetch:SID(data.SID)
							if char then
								local suspensionShit = char:GetData('MDTSuspension') or {}

								suspensionShit[data.JobId] = suspendData
								char:SetData('MDTSuspension', suspensionShit)

								Jobs.Duty:Off(char:GetData('Source'), data.JobId)
							end

							cb(true)
						else
							cb(false)
						end
					end)
				else
					cb(false)
				end
			end
		else
			cb(false)
		end
	end)

	Callbacks:RegisterServerCallback('MDT:Unsuspend', function(source, data, cb)
		local char = Fetch:Source(source):GetData('Character')

		local isSystemAdmin = char:GetData('MDTSystemAdmin')
		local hasPerms, loggedInJob = CheckMDTPermissions(source, {
			'MDT_FIRE',
			'PD_HIGH_COMMAND',
			'DOC_HIGH_COMMAND',
		}, data.JobId)

		if char and data and data.SID and (hasPerms or isSystemAdmin) then
			local charData = MDT.People:View(data.SID)
			if charData then
				local canRemove = false
				if isSystemAdmin then
					canRemove = true
				else
					local plyrJob = Jobs.Permissions:HasJob(source, loggedInJob)
					for k, v in ipairs(charData.Jobs) do
						if v.Id == data.JobId then
							if plyrJob.Grade.Level > v.Grade.Level then
								canRemove = true
							end
							break
						end
					end
				end

				if canRemove then
					Database.Game:updateOne({
						collection = 'characters',
						query = {
							SID = data.SID,
						},
						update = {
							['$push'] = {
								MDTHistory = {
									Time = (os.time() * 1000),
									Char = char:GetData('SID'),
									Log = string.format(
										'%s Revoked Suspension From Job %s',
										char:GetData('First') .. ' ' .. char:GetData('Last'),
										data.JobId
									),
								},
							},
							['$unset'] = {
								[string.format('MDTSuspension.%s', data.JobId)] = true
							}
						},
					}, function(success, results)
						if success then
							local char = Fetch:SID(data.SID)
							if char then
								local suspensionShit = char:GetData('MDTSuspension') or {}
								suspensionShit[data.JobId] = nil
								char:SetData('MDTSuspension', suspensionShit)
							end

							cb(true)
						else
							cb(false)
						end
					end)
				else
					cb(false)
				end
			end
		else
			cb(false)
		end
	end)
end)
