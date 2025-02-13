blood = LibStub("AceAddon-3.0"):NewAddon("blood", "AceConsole-3.0", "AceEvent-3.0")

lastUpdated = 0
updateInterval = 0.1

function MakeCode(r, g, b)
	return r / 255, g / 255, b / 255
end

function blood:OnInitialize()
	-- Called when the addon is loaded
	self:Print("DOT LOADED: Blood-2.0.0")

	self.spells = {}
	-- Get all the bound keys
	self.spells = GetBindings()
	for k, v in pairs(self.spells) do
		self.Print(k, v)
	end
end

function blood:OnEnable()
	square_size = 15
	local f = CreateFrame("Frame", "one", UIParent)
	f:SetFrameStrata("HIGH")
	f:SetScript("OnUpdate", onUpdate)
	f:SetWidth(square_size * 2)
	f:SetHeight(square_size)
	f:SetPoint("TOPLEFT", square_size * 2, 0)

	self.two = CreateFrame("StatusBar", nil, f)
	self.two:SetPoint("TOPLEFT")
	self.two:SetWidth(square_size)
	self.two:SetHeight(square_size)
	self.two:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
	self.two:SetStatusBarColor(1, 1, 1)

	self.three = CreateFrame("StatusBar", nil, f)
	self.three:SetPoint("TOPLEFT", square_size, 0)
	self.three:SetWidth(square_size)
	self.three:SetHeight(square_size)
	self.three:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
	self.three:SetStatusBarColor(1, 1, 1)
end

function blood:OnDisable()
	-- Called when the addon is disabled
end

function bool_to_number(value)
	return value and 1 or 0
end

function blood:Update()
	-- Start by reseting the dot state:
	self.two:SetStatusBarColor(0, 0, 0)
	self.three:SetStatusBarColor(0, 0, 0)

	local nextCast = 0

	local rank = 0
	local rp = 0
	local spellName
	local red = 0
	local green = 0
	local blue = 0

	fc, fccount, fcexp = isUnitBuffed("player", "Fleshcraft")
	if fc == false then
		nextCast = ifPossible("Fleshcraft", nextCast)
	end

	-- are we in combat
	if InCombatLockdown() == true or UnitAffectingCombat("focus") == true then
		local runeOneStart, runeOneDuration, runeOne = GetRuneCooldown(1)
		local runeTwoStart, runeTwoDuration, runeTwo = GetRuneCooldown(2)
		local runeThreeStart, runeThreeDuration, runeThree = GetRuneCooldown(3)
		local runeFourStart, runeFourDuration, runeFour = GetRuneCooldown(4)
		local runeFiveStart, runeFiveDuration, runeFive = GetRuneCooldown(5)
		local runeSixStart, runeSixDuration, runeSix = GetRuneCooldown(6)
		local rp = UnitPower("player")
		local th = UnitHealth("target")
		local playerHealth = UnitHealth("player")
		local playerMaxHealth = UnitHealthMax("player")
		local playerHealthPercent = playerHealth * 100 / playerMaxHealth
		local thm = UnitHealthMax("target")
		local thp = th * 100 / thm

		local coagulating_blood, cb_count, cb_expire = isUnitBuffed("player", "Coagulating Blood")
		if cb_count > 0 then
		end

		--local bp, bpicon, bpcount, bpdebuffType, bpduration, bpexpirationTime, bpisMine, bpisStealable  = AuraUtil.FindAuraByName("Blood Plague","target","PLAYER")
		local bp, bpcount, bpexpirationTime, bpisMine = isUnitDeBuffed("target", "Blood Plague")

		nextCast = ifPossible("Heart Strike", nextCast)
		if rp > 80 then
			nextCast = ifPossible("Death Strike", nextCast)
		end

		-- Don't store charges
		local blooboilInfo = C_Spell.GetSpellCharges("Blood Boil")
		if blooboilInfo ~= nil then
			local bbtime = blooboilInfo.cooldownDuration - (GetTime() - blooboilInfo.cooldownStartTime)

			if blooboilInfo.currentCharges == blooboilInfo.maxCharges then
				if C_Spell.IsSpellInRange("Heart Strike") then
					nextCast = ifPossible("Blood Boil", nextCast)
				end
			end

			if blooboilInfo.currentCharges - blooboilInfo.maxCharges <= 1 then
				if bbtime < 1 then
					if C_Spell.IsSpellInRange("Heart Strike") then
						nextCast = ifPossible("Blood Boil", nextCast)
					end
				end
			end
		end

		local dndInfo = C_Spell.GetSpellCharges("Death and Decay")
		if C_Spell.IsSpellInRange("Heart Strike") then
			if dndInfo.currentCharges == dndInfo.maxCharges then
				nextCast = ifPossible("Death and Decay", nextCast)
			end
		end

		if C_Spell.IsSpellInRange("Heart Strike") == true then
			nextCast = ifPossible("Soul Reaper", nextCast)
			nextCast = ifPossible("Raise Dead", nextCast)
			nextCast = ifPossible("Blood Fury", nextCast)
			nextCast = ifPossible("Hyper Organic Light Originator", nextCast)
			nextCast = ifPossible("Light's Judgment", nextCast)
			nextCast = ifPossible("Haymaker", nextCast)
			nextCast = ifPossible("Blinding Sleet", nextCast)
			nextCast = ifPossible("Dancing Rune Weapon", nextCast)
			nextCast = ifPossible("Abomination Limb", nextCast)
			nextCast = ifPossible("Consumption", nextCast)
			nextCast = ifPossible("Reaper's Mark", nextCast)
			nextCast = ifPossible("Icebound Fortitude", nextCast)

			if rp > 80 then
				nextCast = ifPossible("Bonestorm", nextCast)
			end
		end
		local runesReady = bool_to_number(runeOne)
			+ bool_to_number(runeTwo)
			+ bool_to_number(runeThree)
			+ bool_to_number(runeFour)
			+ bool_to_number(runeFive)
			+ bool_to_number(runeSix)

		local exterminate, ecount, eexpire = isUnitBuffed("player", "Exterminate")
		if exterminate == true then
			nextCast = ifPossible("Marrowrend", nextCast)
		end

		if playerHealthPercent < 60 then
			nextCast = ifPossible("Death Strike", nextCast)
		end

		if dndInfo.currentCharges == dndInfo.maxCharges then
			if C_Spell.IsSpellInRange("Heart Strike") then
				nextCast = ifPossible("Death and Decay", nextCast)
			end
		end

		if runesReady < 4 then
			nextCast = ifPossible("Blood Tap", nextCast)
		end

		if rp > 70 then
			nextCast = ifPossible("Death Strike", nextCast)
		end

		local boneshield, bscount, bsexpire = isUnitBuffed("player", "Bone Shield")
		if boneshield == false then
			nextCast = ifPossible("Marrowrend", nextCast)
		else
			if bscount < 5 then
				nextCast = ifPossible("Marrowrend", nextCast)
			end
		end

		if bp == true and bpisMine == true then
			if bpexpirationTime then
				bpexpirein = bpexpirationTime - GetTime()
			end
			if bpexpirein > 0 and bpexpirein < 1 then
				if C_Spell.IsSpellInRange("Heart Strike") == true then
					nextCast = ifPossible("Blood Boil", nextCast)
				end
			end
		else
			if bp == false then
				if C_Spell.IsSpellInRange("Heart Strike") == true then
					nextCast = ifPossible("Blood Boil", nextCast)
				end
			end
		end

		if playerHealthPercent < 30 then
			nextCast = ifPossible("Death Strike", nextCast)
		end
	end

	--self:Print(nextCast)
	self.two:SetStatusBarColor(nextCast / 255, green / 255, blue / 255)
	red = 0
	green = 0
	blue = 0
	self.three:SetStatusBarColor(red / 255, 127 / 255, blue / 255)
end

function onUpdate(self, elapsed)
	--self.lastUpdated = self.lastUpdated + elapsed
	lastUpdated = lastUpdated + elapsed
	--if (self.lastUpdated > self.update_interval) then
	if lastUpdated > updateInterval then
		blood:Update()
		lastUpdated = 0
	end
end
