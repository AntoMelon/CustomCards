-- Camoufiend Protector
-- Scripted by AntoMelon
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon 1 "Camoufiend" Monster from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={0xd003}

function s.spfilter(c,e,tp,rmvc)
	return c:IsSetCard(0xd003) and Duel.GetLocationCountFromEx(tp,tp,rmvc,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
        local c=e:GetHandler()
		--Other Normal cannot be destroyed by battle
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(s.indtg)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        e1:SetValue(1)
        sc:RegisterEffect(e1)
        --Other Normal are unaffected
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_IMMUNE_EFFECT)
        sc:RegisterEffect(e2)
		--BReturn to the ED during the End Phase
        local fid=c:GetFieldID()
		sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sc)
		e3:SetCondition(s.tdcon)
		e3:SetOperation(s.tdop)
		Duel.RegisterEffect(e3,tp)
	end
	Duel.SpecialSummonComplete()
end
function s.indtg(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_NORMAL)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end