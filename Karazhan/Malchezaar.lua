﻿------------------------------
--      Are you local?    --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Prince Malchezaar"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local started

----------------------------
--      Localization     --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Malchezaar",

	enfeeble_cmd = "enfeeble",
	enfeeble_name = "Enfeeble",
	enfeeble_desc = "Shows counter bar for enfeeble and Dark Nova.",

	infernals_cmd = "infernals",
	infernals_name = "Infernals",
	infernals_desc = "Show cooldown timer for Infernal summons.",

	engage_message = "Malchezaar engaged, Infernal in 2min!",

	enfeeble_trigger = "afflicted by Enfeeble",
	enfeeble_bar = "Enfeeble",

	darknova_bar = "Dark Nova Incoming!",
	darknova_message = "Dark Nova in 3 sec!",

	infernal_bar = "Incoming Infernal",
	infernal_message = "Infernal! Next in 2 min!",
} end )

----------------------------------
--    Module Declaration   --
----------------------------------

BigWigsMalchezaar = BigWigs:NewModule(boss)
BigWigsMalchezaar.zonename = AceLibrary("Babble-Zone-2.2")["Karazhan"]
BigWigsMalchezaar.enabletrigger = boss
BigWigsMalchezaar.toggleoptions = {"infernals", "bosskill"}
BigWigsMalchezaar.revision = tonumber(string.sub("$Revision$", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMalchezaar:OnEnable()
	started = nil

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "EventBucket")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "EventBucket")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "EventBucket")

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "MalchezaarEnfeeble", 2)
	self:TriggerEvent("BigWigs_ThrottleSync", "MalchezaarInfernal", 5)
end

------------------------------
--     Event Handlers    --
------------------------------

function BigWigsMalchezaar:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if msg:find("Infernal") then
		self:Sync("MalchezaarInfernal")
	end
end

-- Event bucket until we know what's really going on.
function BigWigsMalchezaar:EventBucket(msg)
	if msg:find(L["enfeeble_trigger"]) and self.db.profile.enfeeble then
		self:Sync("MalchezaarEnfeeble")
	end
end

function BigWigsMalchezaar:BigWigs_RecvSync(sync, rest, nick)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.infernals then
			self:Message(L["engage_message"], "Important")
			self:Bar(self, L["infernal_bar"], 120, "INV_Stone_05")
		end
	elseif sync == "MalchezaarEnfeeble" and self.db.profile.enfeeble then
		self:Message(L["darknova_message"], "Important")
		self:Bar(self, L["enfeeble_bar"], 7, "Spell_Shadow_CurseOfMannoroth")
		self:Bar(self, L["darknova_bar"], 3, "Spell_Fire_FelFire")
	elseif sync == "MalchezaarInfernal" and self.db.profile.infernals then
		self:Message(L["infernal_message"], "Important")
		self:Bar(self, L["infernal_bar"], 120, "INV_Stone_05")
	end
end
