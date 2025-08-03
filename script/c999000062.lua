-- Neo-Roboyarou
-- Scripted by AntoMelon
local s,id=GetID()
function s.initial_effect(c)
    -- set or send "Robobonds on Summon"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- Fusion Summon
    local params={fusfilter=s.fusfilter,
					nil,
					extrafil=s.fextra,
					extratg=s.extratg,
					gc=Fusion.ForcedHandler}
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(Fusion.SummonEffTG(params))
	e3:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e3)
end
s.listed_series={0xd005}

function s.filter(c)
	return c:IsSetCard(0xd005) and c:IsSpellTrap() and (c:IsSSetable() or c:IsAbleToGrave())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc:IsSSetable() and tc:IsAbleToGrave() then
        local op=Duel.SelectEffect(tp,
			{tc,aux.Stringid(id,1)},
			{tc,aux.Stringid(id,2)})
		if op==1 and Duel.SSet(tp,tc)>0 then
			--Can be activated this turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		elseif op==2 then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
    elseif tc:IsSSetable() and Duel.SSet(tp,tc)>0 then
        --Can be activated this turn
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,3))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e1)
    elseif tc:IsAbleToGrave() then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

function s.fusfilter(c,tp)
    return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
function s.fextra(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end