PLUGIN.Title = "FixYourName"
PLUGIN.Description = "Disables Weird Characters in Usernames, preventing them from preventing bans."
PLUGIN.Author = "XoXFaby"
 
function PLUGIN:Init()
	local b, res = config.Read( "FixYourName" )
	self.Config = res or {}
	if (not b) then
		self:LoadDefaultConfig()
		if (res) then config.Save( "FixYourName" ) end
		print("Creating default FixYourName config")
	end
	
	self.Config.Language = loadLocalization(self.Config.Language)
end

function loadLocalization(setting)

	LocalTxt = {}
	
	LocalTxt["english"] = {}
	LocalTxt["english"].kickChatColor = " has been kicked ( Color code ) "
	LocalTxt["english"].kickNoticeColor = "Kicked: Color code"
	LocalTxt["english"].kickChatCharacter = " has been kicked ( Name already in use  "
	LocalTxt["english"].kickNoticeCharacter = "Kicked: Name already in use"
	LocalTxt["english"].kickChatDuplicate = " has been kicked ( Name contains illegal character ) "
	LocalTxt["english"].kickNoticeDuplicate = "Kicked: Name contains illegal character"
	
	LocalTxt.Allowed = { "english" }
	
	local validLanguage = false
	for k,v in ipairs(LocalTxt.Allowed) do
		if v == setting:lower() then validLanguage = true end
	end
	if not validLanguage then
		print("Language not valid, defaulting to English.")
		return "english"
	else 
		return setting
	end
end

function PLUGIN:LoadDefaultConfig()
	self.Config.Language = "English"
	self.Config.Characters = "abcdefghijklmnopqrstuvwxyz1234567890 [](){}!@#$%^&*_-=+.|"
	self.Config.ReportToChat = true
	self.Config.AllowColorCodes = false
	self.Config.AllowDuplicateNames = false
	self.Config.AllowDuplicateNamesCaseSensitive = true
	self.Config.AllowBannedCharacters = false
	self.Config.Language = "English"
end

function isNumCode( num )
	if tonumber(num) ~= nil or num:lower() == "a" or num:lower() == "b" or num:lower() == "c" or num:lower() == "d" or num:lower() == "e" or num:lower() == "f" or num:lower() == "-" then
		return true
	else
		return false
	end
end

function PLUGIN:OnUserConnect( netuser )
	
	local name = netuser.displayName
	local nameChar = false
	local nameColor = false
	local nameDuplicate = false
	local duplicateUser = ""
	
	
	if not self.Config.AllowBannedCharacters then
		for i = 1, name:len() do
			local allowedChar = false
			for j = 1, self.Config.Characters:len() do
				if name:sub(i,i):lower() == self.Config.Characters:sub(j,j) then
					allowedChar = true
				end
			end
			if allowedChar == false then
				nameChar = true
				break
			end
		end
	end
		
	if not self.Config.AllowColorCodes then
		for i = 1, name:len() - 8 do
			if name:sub(i,i) == "[" and name:sub(i+1, i+1) and name:sub(i+2, i+2) and name:sub(i+3, i+3) and name:sub(i+4, i+4) and name:sub(i+5, i+5) and name:sub(i+6, i+6) and name:sub(i+7,i+7) == "]" then
				nameColor = true
			end
		end
	end
		
	if not self.Config.AllowDuplicateNames then
		for k,v in ipairs(rust.GetAllNetUsers()) do
			if ( ( netuser.displayName:lower() == v.displayName:lower() and not AllowDuplicateNamesCaseSensitive  ) or netuser.displayName == v.displayName ) and netuser ~= v then nameDuplicate = true; duplicateUser = v end
		end
	end
	
	if nameColor then
		rust.Notice( netuser, LocalTxt[self.Config.Language:lower()].kickNoticeColor )
		if self.Config.ReportToChat then rust.BroadcastChat( name .. LocalTxt[self.Config.Language:lower()].kickChatColor ) end
		netuser:Kick( NetError.Facepunch_Kick_RCON, true )
	elseif nameDuplicate then
		rust.Notice( netuser, LocalTxt[self.Config.Language:lower()].kickNoticeDuplicate )
		if self.Config.ReportToChat then rust.BroadcastChat( name .. LocalTxt[self.Config.Language:lower()].kickChatDuplicate ) end
		netuser:Kick( NetError.Facepunch_Kick_RCON, true )
	elseif nameChar then
		rust.Notice( netuser, LocalTxt[self.Config.Language:lower()].kickNoticeCharacter )
		if self.Config.ReportToChat then rust.BroadcastChat( name .. LocalTxt[self.Config.Language:lower()].kickChatCharacter) end
		netuser:Kick( NetError.Facepunch_Kick_RCON, true )
	end
end
