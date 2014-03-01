PLUGIN.Title = "FixYourName"
PLUGIN.Description = "Disables Weird Characters in Usernames, preventing them from preventing bans."
PLUGIN.Author = "XoXFaby"
 
function PLUGIN:Init()
	local b, res = config.Read( "FixYourName" )
	self.Config = res or {}
	self:LoadDefaultConfig()
	self.Config.Language = loadLocalization(self.Config.Language)
	config.Save( "FixYourName" )	
	
	
	self.Config.BannedNames = {}
	for i in string.gmatch(self.Config.Names, "[^%;]+") do
		self.Config.BannedNames[#self.Config.BannedNames + 1] = i
	end
end

function loadLocalization(setting)

	LocalTxt = {}
	
	LocalTxt["english"] = {}
	LocalTxt["english"].kickChatColor = " has been kicked ( Color code ) "
	LocalTxt["english"].kickNoticeColor = "Kicked: Color code"
	LocalTxt["english"].kickChatDuplicate = " has been kicked ( Name already in use ) "
	LocalTxt["english"].kickNoticeDuplicate = "Kicked: Name already in use"
	LocalTxt["english"].kickChatCharacter = " has been kicked ( Name contains illegal character ) "
	LocalTxt["english"].kickNoticeCharacter = "Kicked: Name contains illegal character"	
	
	LocalTxt["german"] = {}
	LocalTxt["german"].kickChatColor = " wurde gekickt ( Farb-code ) "
	LocalTxt["german"].kickNoticeColor = "Gekickt: Farb-code"
	LocalTxt["german"].kickChatDuplicate = " wurde gekickt ( Name wird schon verwendet )  "
	LocalTxt["german"].kickNoticeDuplicate = "Gekickt: Name wird schon verwendet "
	LocalTxt["german"].kickChatCharacter = " wurde gekickt ( Unerlaubtes symbol ) "
	LocalTxt["german"].kickNoticeCharacter = "Gekickt: Unerlaubtes symbol"
	LocalTxt["deutsch"] = LocalTxt["german"]
	
	LocalTxt["dutch"] = {}
    LocalTxt["dutch"].kickChatColor = " is gekicked ( Naam bevat kleurcode ) "
    LocalTxt["dutch"].kickNoticeColor = "Gekicked: Naam bevat kleurcode"
    LocalTxt["dutch"].kickChatDuplicate = " is gekicked ( Naam al in gebruik )  "
    LocalTxt["dutch"].kickNoticeDuplicate = "Gekicked: Naam al in gebruik "
    LocalTxt["dutch"].kickChatCharacter = " is gekicked ( Naam bevat verboden karakters ) "
    LocalTxt["dutch"].kickNoticeCharacter = "Gekicked: Naam bevat verboden karakters"
    LocalTxt["nederlands"] = LocalTxt["dutch"]
	
	LocalTxt["portuguese"] = {}
	LocalTxt["portuguese"].kickChatColor = " foi kickado ( Color code ) "
	LocalTxt["portuguese"].kickNoticeColor = "kickado: Color code"
	LocalTxt["portuguese"].kickChatDuplicate = " foi kickado ( Nome ja esta em uso "
	LocalTxt["portuguese"].kickNoticeDuplicate = "kickado: Nome ja esta em uso"
	LocalTxt["portuguese"].kickChatCharacter = " foi kickado ( Nome contem caracteres ilegais ) "
	LocalTxt["portuguese"].kickNoticeCharacter = "kickado: Nome contem caracteres ilegais"
	
	LocalTxt["pt-br"] = {}
	LocalTxt["pt-br"].kickChatColor = " foi kickado ( usando codigo de cor ) "
	LocalTxt["pt-br"].kickNoticeColor = "kickado: usando codigo de cor"
	LocalTxt["pt-br"].kickChatDuplicate = " foi kickado ( Este nome ja esta em uso )"
	LocalTxt["pt-br"].kickNoticeDuplicate = "Kickado: Este nome ja esta em uso"
	LocalTxt["pt-br"].kickChatCharacter = " foi kickado ( Nome contem caracteres ilegais ) "
	LocalTxt["pt-br"].kickNoticeCharacter = "Kickado: Nome contem caracteres ilegais"
	
	LocalTxt["russian"] = {}
	LocalTxt["russian"].kickChatColor = " был отключён (цветной ник)"
	LocalTxt["russian"].kickNoticeColor = "Отказано в подключении: цветной ник"
	LocalTxt["russian"].kickChatDuplicate = " был отключён (имя уже используется)"
	LocalTxt["russian"].kickNoticeDuplicate = "Отказано в подключении: имя уже используется"
	LocalTxt["russian"].kickChatCharacter = " был отключён (имя содержит запрещённые символы) "
	LocalTxt["russian"].kickNoticeCharacter = "Отказано в подключении: имя содержит запрещённые символы"
	
	LocalTxt.Allowed = { "english", "german", "deutsch", "dutch", "nederlands", "portuguese", "pt-br", "russian" }
	
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
	self.Config.Language = self.Config.Language or "English"
	self.Config.Languages = "english, german, deutsch, dutch, nederlands, portuguese, pt-br"
	self.Config.Characters = self.Config.Characters or "abcdefghijklmnopqrstuvwxyz1234567890 [](){}!@#$%^&*_-=+.|"
	self.Config.Names = self.Config.Names or "Admin;Server;Rust;Oxide;Oxmin;Facepunch"
	self.Config.ReportToChat = self.Config.ReportToChat or true
	self.Config.AllowColorCodes = self.Config.AllowColorCodes or false
	self.Config.AllowDuplicateNames = self.Config.AllowDuplicateNames or false
	self.Config.AllowDuplicateNamesCaseSensitive = self.Config.AllowDuplicateNamesCaseSensitive or false
	self.Config.AllowBannedCharacters = self.Config.AllowBannedCharacters or false
	self.Config.AllowBannedNames = self.Config.AllowBannedNames or false
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
	local nameBanned = false
	
	
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
			if ( ( name:lower() == v.displayName:lower() and not AllowDuplicateNamesCaseSensitive ) or name == v.displayName ) and netuser ~= v then nameDuplicate = true; duplicateUser = v end
		end
	end
	
	if not self.Config.AllowBannedNames then
		for k,v in ipairs(self.Config.BannedNames) do
			if name:lower() == v:lower() then nameBanned = true end
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
