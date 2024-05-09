local mod	= DBM:NewMod(2571, "DBM-Party-WarWithin", 2, 1267)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20240505022958")
mod:SetCreatureID(207946)
mod:SetEncounterID(2847)
--mod:SetHotfixNoticeRev(20220322000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 424419 447270 424414",
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED 447443 447439 424419",
	"SPELL_AURA_REMOVED 447443"
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED"
--	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--NOTE, the abilities of sub bosses are all in trash mod due to fact that you can (and should) pull them separately from boss
--TODO, track Strength in Numbers by purposely pulling boss wrong?
--[[
(ability.id = 424419 or ability.id = 447270 or ability.id = 424414) and type = "begincast"
 or ability.id = 447443 and type = "applybuff"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Captain Dailcry
mod:AddTimerLine(DBM:EJ_GetSectionInfo(27821))
local warnSavageMauling						= mod:NewTargetNoFilterAnnounce(447439, 3)

local specWarnBattleCry						= mod:NewSpecialWarningInterruptCount(424419, nil, nil, nil, 1, 2)
local specWarnBattleCryDispel				= mod:NewSpecialWarningDispel(424419, "RemoveEnrage", nil, nil, 1, 2)
local specWarnHurlSpear						= mod:NewSpecialWarningDodgeCount(447272, nil, nil, nil, 2, 2)
local specWarnPierceArmor					= mod:NewSpecialWarningDefensive(424414, nil, nil, nil, 1, 2)
--local specWarnGTFO						= mod:NewSpecialWarningGTFO(372820, nil, nil, nil, 1, 8)

local timerSavageMaulingCD					= mod:NewAITimer(33.9, 447439, nil, nil, nil, 3)
local timerBattleCryCD						= mod:NewCDCountTimer(18.2, 424419, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerHurlSpearCD						= mod:NewAITimer(33.9, 447272, nil, nil, nil, 3)
local timerPierceArmorCD					= mod:NewAITimer(18.2, 424414, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)

mod:AddInfoFrameOption(447443)

mod.vb.savageCount = 0
mod.vb.battleCryCount = 0
mod.vb.spearCount = 0
mod.vb.pierceCount = 0

function mod:OnCombatStart(delay)
	self.vb.savageCount = 0
	self.vb.battleCryCount = 0
	self.vb.spearCount = 0
	self.vb.pierceCount = 0
	timerSavageMaulingCD:Start(1-delay)
	timerBattleCryCD:Start(12.9-delay, 1)
	timerHurlSpearCD:Start(1-delay)
	timerPierceArmorCD:Start(1-delay)
	--Allow trash mod to enable in combat in case you DO pull boss with any of the 3 sub bosses still active
	local trashMod = DBM:GetModByName("SacredFlameTrash")
	if trashMod then
		trashMod.isTrashModBossFightAllowed = true
	end
end

function mod:OnCombatEnd()
	local trashMod = DBM:GetModByName("SacredFlameTrash")
	if trashMod then
		trashMod.isTrashModBossFightAllowed = false
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 424419 then
		self.vb.battleCryCount = self.vb.battleCryCount + 1
		specWarnBattleCry:Show(args.sourceName, self.vb.battleCryCount)
		specWarnBattleCry:Play("kickcast")
		timerBattleCryCD:Start(nil, self.vb.battleCryCount+1)
	elseif spellId == 447270 then
		self.vb.spearCount = self.vb.spearCount + 1
		specWarnHurlSpear:Show(self.vb.spearCount)
		specWarnHurlSpear:Play("watchstep")
		timerHurlSpearCD:Start()
	elseif spellId == 424414 then
		self.vb.pierceCount = self.vb.pierceCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnPierceArmor:Show()
			specWarnPierceArmor:Play("defensive")
		end
		timerPierceArmorCD:Start()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 372858 then

	end
end
--]]

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 447443 then
		self.vb.savageCount = self.vb.savageCount + 1
		timerSavageMaulingCD:Start()
		if self.Options.InfoFrame then
			DBM.InfoFrame:SetHeader(args.spellName)
			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
		end
	elseif spellId == 447439 then
		warnSavageMauling:Show(args.destName)
	elseif spellId == 424419 then
		specWarnBattleCryDispel:Show(args.destName)
		specWarnBattleCryDispel:Play("enrage")
	end
end
--mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 447443 then
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 372820 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--[[
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 211291 then--sergeant-shaynemail

	elseif cid == 211289 then--taener-duelmal

	elseif cid == 211290 then--elaena-emberlanz

	end
end
--]]

--[[
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 74859 then

	end
end
--]]
