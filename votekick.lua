PLUGIN.Title = "Votekick"
PLUGIN.Description = "Let users vote people to kick."
PLUGIN.Author = "XoXFaby"
 
function PLUGIN:Init()
	
	self.MinimumPlayers = 3 -- Minimum amount of players at which vote kicks will be allowed.
	self.TimeToVote = 60 -- How long does can each vote last. In seconds.
	self.AnnounceVotes = true

	self.VoteInProgress = false
	self.VoteUser = ""
	self.HasVoted = {}
	self.StartTime = 0
	self.KickVotes = 0
		  
	oxminPlugin = cs.findplugin("oxmin")
	
	self:AddChatCommand( "votekick", self.voteStart )
	self:AddChatCommand( "yes", self.voteYes )
	self:AddChatCommand( "no", self.voteNo )
end
	
function PLUGIN:getTime()
	local GetTime = static_property_get( UnityEngine.Time, "realtimeSinceStartup" )
	return GetTime()
end

function PLUGIN:finishVote(voteInProgress, startTime, currentTime, timeToVote, voteUser, kickVotes)
		rust.BroadcastChat( voteInProgress )
		rust.BroadcastChat( startTime )
		rust.BroadcastChat( currentTime ) 
		rust.BroadcastChat( timeToVote )
		rust.BroadcastChat( voteUser )
		rust.BroadcastChat( kickVotes )
	if not voteInProgress then return false	
	elseif currentTime - startTime < timeToVote then return true
	else
		if kickVotes >= #rust.GetAllNetUsers() / 2 then
			rust.BroadcastChat( "Vote to kick " .. voteUser.displayName .. " has passed."	)
			rust.Notice( voteUser, "You have been voted out of the server." )
			voteUser:Kick( NetError.Facepunch_Kick_RCON, true )
			return false 
		else		
			rust.BroadcastChat( "Vote to kick " .. voteUser.displayName .. " has not passed."	)
			return false 
		end
	end
end
	
function PLUGIN:voteStart( netuser, cmd, args )
	
	if self.VoteInProgress then
		rust.Notice( netuser, "A vote is already in progress." )
		return; 
	elseif #rust.GetAllNetUsers() < self.MinimumPlayers then 
		rust.Notice( netuser, "Not enough players online." )
		return;
	elseif (not args[1]) then
		rust.Notice( netuser, "Syntax: /votekick name" )
		return;
	else
		local b, targetuser = rust.FindNetUsersByName( args[1] )
		if (not b) then
			if (targetuser == 0) then
				rust.Notice( netuser, "No players found with that name!" )
			else
				rust.Notice( netuser, "Multiple players found with that name!" )
			end
			return;
		else
			local targetname = rust.QuoteSafe( targetuser.displayName )
		
			--if oxminPlugin:hasFlag( targetuser, oxmin.strtoflag["cankick"] ) or oxminPlugin:hasFlag( targetuser, strtoflag["canban"] ) then 
			--	rust.Notice( netuser, "This user can not be kicked." )
			--	return
			--else
	
				self.HasVoted = { netuser }
				self.KickVotes = 1
				self.StartTime = self.getTime()
	
				rust.BroadcastChat( "A vote has been started to kick " .. targetname .. ". Type /yes or /no to vote. " .. #rust.GetAllNetUsers() / 2 .. " votes are required." )
				rust.Notice( netuser, "Vote against " .. targetname .. " has been started." )
				self.VoteUser = targetuser
				self.VoteInProgress = true
			--end
		end
	end
end

function PLUGIN:hasVoted( netuser, voteUsers )
	local voted = false
	voteUsers = voteUsers or {}
	for k,v in ipairs(self.HasVoted) do
		if netuser == v then voted = true end
	end
	return voted
end

function PLUGIN:voteYes( netuser, cmd, args )
	if self.hasVoted(netuser, self.HasVoted) then return; end
	
	self.KickVotes = self.KickVotes + 1
	self.HasVoted[#self.HasVoted + 1] = netuser 
	rust.BroadcastChat( netuser.displayName .. " voted Yes. " .. #rust.GetAllNetUsers() / 2  - self.KickVotes .. " more votes required." )
	
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
	
end

function PLUGIN:voteNo( netuser, cmd, args )
	if self.hasVoted(netuser) then return; end
	
	self.HasVoted[#self.HasVoted + 1] = netuser
	
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

-- This is dirty but I want the function to be called as often as possible.

function PLUGIN:OnAirdrop()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnBlueprintUse()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnDoorToggle()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnItemAdded()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnItemRemoved()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnResearchItem()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnRunCommand()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnSpawnPlayer()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnStartCrafting()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnStructureDecay()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnTakeDamage()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnUserConnect()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end

function PLUGIN:OnZombieKilled()
	self.VoteInProgress = self.finishVote(self.VoteInProgress, self.StartTime, self.getTime(), self.TimeToVote, self.VoteUser, self.KickVotes)
end



