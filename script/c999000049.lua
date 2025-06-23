-- Camoufiend Commander
-- Script by AntoMelon
local s,id=GetID()
function s.initial_effect(c)
    --xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_NORMAL),4,2)
	c:EnableReviveLimit()

    -- special or banish cards on summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.sprmtg)
    e1:SetOperation(s.sprmop)
    c:RegisterEffect(e1)

    --Banish S/T sent to your opponent's GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetTarget(s.rmtg)
	c:RegisterEffect(e2)

    --Special Summon from banishment
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0xd003}

function s.sprmfilter(c,e,tp,sp_chk)
	return c:IsType(TYPE_NORMAL) and c:IsMonster()
	   and (c:IsAbleToRemove() or (sp_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.sprmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	   local sp_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	   return Duel.IsExistingMatchingCard(s.sprmfilter,tp,LOCATION_DECK,0,1,nil,e,tp,sp_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sprmop(e,tp,eg,ep,ev,re,r,rp)
	local sp_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sprmfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,sp_chk):GetFirst()
	if not tc then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsAbleToRemove() then
		local op=Duel.SelectEffect(tp,
			{tc,aux.Stringid(id,0)},
			{tc,aux.Stringid(id,1)})
		if op==1 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif op==2 then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif tc:IsAbleToRemove() then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end 
end

function s.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and c:IsOriginalType(TYPE_SPELL+TYPE_TRAP) and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xd003) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
            local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
            if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local sc=sg:Select(tp,1,1,nil)
                if #sc==0 then return end
                Duel.BreakEffect()
                Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
            end
        end
	end
end