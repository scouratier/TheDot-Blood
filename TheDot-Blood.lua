blood = LibStub("AceAddon-3.0"):NewAddon("blood", "AceConsole-3.0", "AceEvent-3.0")

lastUpdated = 0
updateInterval = 0.1

function MakeCode( r , g , b)
    return r/255 , g/255 , b/255
end

function blood:OnInitialize()
    -- Called when the addon is loaded
    self:Print("DOT LOADED: Blood-2.0.0")

    self.spells = {  }
    -- Get all the bound keys
    self.spells = GetBindings()
    --for k, v in pairs(self.spells) do 
      --self.Print( k, v )
    --end
end

function blood:OnEnable()
    square_size = 15
    local f = CreateFrame( "Frame" , "one" , UIParent )
    f:SetFrameStrata( "HIGH" )
    f:SetScript("OnUpdate", onUpdate)
    f:SetWidth( square_size * 2 )
    f:SetHeight( square_size )
    f:SetPoint( "TOPLEFT" , square_size * 2 , 0 )
    
    self.two = CreateFrame( "StatusBar" , nil , f )
    self.two:SetPoint( "TOPLEFT" )
    self.two:SetWidth( square_size )
    self.two:SetHeight( square_size )
    self.two:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.two:SetStatusBarColor( 1 , 1 , 1 )
    
    self.three = CreateFrame( "StatusBar" , nil , f )
    self.three:SetPoint( "TOPLEFT" , square_size , 0)
    self.three:SetWidth( square_size )
    self.three:SetHeight( square_size )
    self.three:SetStatusBarTexture("Interface\\AddOns\\thedot\\Images\\Gloss")
    self.three:SetStatusBarColor( 1 , 1 , 1 )
    
end

function blood:OnDisable()
    -- Called when the addon is disabled
end

function blood:Update()
    -- Start by reseting the dot state:
    self.two:SetStatusBarColor(0, 0, 0);
    self.three:SetStatusBarColor(0, 0, 0);

    nextCast = 0

    local rank = 0
    local rp = 0
    local spellName
    local red = 0
    local green = 0
    local blue = 0

    -- are we in combat
    if InCombatLockdown() == true or UnitAffectingCombat("focus") == true then
        runeOneStart, runeOneDuration, runeOne = GetRuneCooldown(1)
        runeTwoStart, runeTwoDuration, runeTwo = GetRuneCooldown(2)
        runeThreeStart, runeThreeDuration, runeThree = GetRuneCooldown(3)
        runeFourStart, runeFourDuration, runeFour = GetRuneCooldown(4)
        runeFiveStart, runeFiveDuration, runeFive = GetRuneCooldown(5)
        runeSixStart, runeSixDuration, runeSix = GetRuneCooldown(6)
        rp = UnitMana("player")
        th = UnitHealth("target")
        thm = UnitHealthMax("target")
        thp = th*100/thm

        local bp, bprank, bpicon, bpcount, bpdebuffType, bpduration, bpexpirationTime, bpisMine, bpisStealable  = UnitDebuff("target","Blood Plague")

        hs, hscooldown = canCastNow("Heart Strike")
        if hs == true then
            nextCast = spells["Heart Strike"]
        end

        -- RP dump
        dc, dccooldown = canCastNow("Death Strike")
        if dc == true and rp > 80 then
            nextCast = spells["Death Strike"]
        end

        -- Don't store charges
        bbcharges, bbmaxCharges, bbstart, bbduration = GetSpellCharges("Blood Boil")
        bbtime = bbduration - (GetTime() - bbstart)
        if bbcharges == bbmaxCharges then
            bb, bbcooldown = canCastNow("Blood Boil")
            if bb == true then
                nextCast = spells["Blood Boil"]
            end
        end

        if bbmaxCharges - bbcharges <= 1 then
            if bbtime < 1 then
                bb, bbcooldown = canCastNow("Blood Boil")
                if bb == true then
                    nextCast = spells["Blood Boil"]
                end
            end
        end

        crimbuff, crimrank, crimicon, crimcount = UnitBuff( "player" , "Crimson Scourge")
        if crimbuff ~= nil then

        end

        storm, stormcooldown = canCastNow("Bonestorm")
        if storm == true then
            nextCast = spells["Bonestorm"]
        end

        bsbuff, bsrank, bsicon, bscount = UnitBuff( "player" , "Bone Shield")
        if bsbuff == nil then
            mr, mrcooldown = canCastNow("Marrowrend")
            if mr == true then
                nextCast = spells["Marrowrend"]
            end
        else
            if bscount < 5 then
                mr, mrcooldown = canCastNow("Marrowrend")
                if mr == true then
                    nextCast = spells["Marrowrend"]
                end
            end
        end

        if bp ~= nil and bpisMine == "player" then
            if bpexpirationTime then
                bpexpirein = bpexpirationTime - GetTime();
            end
            if bpexpirein > 0 and bpexpirein < 1 then
                bb, bbcooldown = canCastNow("Blood Boil")
                if bb == true then
                    nextCast = spells["Blood Boil"]
                end
            end
        else
            if bp == nil then
                bb, bbcooldown = canCastNow("Blood Boil")
                --self:Print("Target does not have Blood Plague", bb)
                if bb == true then
                    --self:Print("Trying to cast Blood Boil")
                    nextCast = spells["Blood Boil"]
                end
            end
        end 

        dancer, dancercooldown = canCastNow("Dancing Rune Weapon")
        if dancer == true then
            nextCast = spells["Dancing Rune Weapon"]
        end

        bloodfury, bfurycooldown = canCastNow("Blood Fury")
        if bloodfury == true then
            nextCast = spells["Blood Fury"]
        end

    end

    self.two:SetStatusBarColor(nextCast/255, green/255, blue/255)
    red = 0
    green = 0
    blue = 0
    self.three:SetStatusBarColor( red/255, 127/255, blue/255 );
end

function onUpdate(self, elapsed)
    --self.lastUpdated = self.lastUpdated + elapsed
    lastUpdated = lastUpdated + elapsed
    --if (self.lastUpdated > self.update_interval) then
    if (lastUpdated > updateInterval) then
        blood:Update()
        lastUpdated = 0
    end
end