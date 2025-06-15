-- Camoufiend General
-- Scripted by AntoMelon
local s,id=GetID()
function s.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,3,s.lcheck)

    --Banish a card when summoned
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.rmvtg)
	e1:SetOperation(s.rmvop)
	c:RegisterEffect(e1)

    --Negate the activation of a monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

    --Special Summon from banishment
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
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

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_NORMAL,lc,sumtype,tp)
end

function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.negcostfilter(c,g)
	return g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep~=tp and re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_ONFIELD,0,1,nil,lg) end
         --Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,lg) end
	local tc=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_ONFIELD,0,1,1,nil,lg):GetFirst()
    --Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,lg)
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spnegfilter(c)
	return c:IsSpellTrap() and c:IsFaceup() and not c:IsDisabled()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
            local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spnegfilter),tp,0,LOCATION_ONFIELD,nil,e,tp)
            if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                for tc in aux.Next(g) do
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_DISABLE)
                    e1:SetReset(RESETS_STANDARD_PHASE_END)
                    tc:RegisterEffect(e1)
                    local e2=Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_DISABLE_EFFECT)
                    e2:SetReset(RESETS_STANDARD_PHASE_END)
                    tc:RegisterEffect(e2)
                    if tc:IsType(TYPE_TRAPMONSTER) then
                        local e3=Effect.CreateEffect(c)
                        e3:SetType(EFFECT_TYPE_SINGLE)
                        e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                        e3:SetReset(RESETS_STANDARD_PHASE_END)
                        tc:RegisterEffect(e3)
                    end
                end
            end
        end
	end
end