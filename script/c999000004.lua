-- Scapegoat Frenzy
-- Scripted by AntoMelon
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)

	--Activate while in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.lkcon)
	e3:SetOperation(s.lkactivate)

	c:RegisterEffect(e3)
end
s.listed_series={0xd001}

function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(0xd001) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end

function s.lkfilter(c,tp)
	return c:IsFaceup() and (c:IsType(TYPE_TOKEN) or c:IsOriginalType(TYPE_TOKEN) ) and c:IsControler(tp)
end
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lkfilter,1,nil,tp)
        and ( re and re:IsMonsterEffect() and re:GetOwner():IsSetCard(0xd001)
        and ((re:IsActivated() and tp==Duel.GetChainInfo(0,CHAININFO_TRIGGERING_PLAYER)) or re:GetHandlerPlayer()==tp) )
end
function s.lkactivate(e,tp,eg,ep,ev,re,r,rp)
	local token_id=999000001
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,token_id,0,TYPES_TOKEN,-2,0,0,RACE_BEAST,ATTRIBUTE_EARTH) then
        local token=Duel.CreateToken(tp,token_id)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        Duel.SpecialSummonComplete()

        if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)

            local g=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil,c)
            if #g>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local sg=g:Select(tp,1,1,nil)
                Duel.LinkSummon(tp,sg:GetFirst(),c)
            end
        end
    end
end