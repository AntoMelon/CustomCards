-- Ferocious Scapegoat
-- Scripted by AntoMelon
local s,id=GetID()
function s.initial_effect(c)
    -- Summon Token
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetCondition(s.tkcon)
	e1:SetCost(s.tkcost)
	e1:SetOperation(s.tkop)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)

	--Send card from field to grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tgcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

s.listed_series={0xd001}
local token_id=73915053

function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,token_id,0,TYPES_TOKEN,-2,0,0,RACE_BEAST,ATTRIBUTE_EARTH)
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() and Duel.GetFlagEffect(0,id)==0 end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local token=Duel.CreateToken(tp,token_id)
    Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    Duel.SpecialSummonComplete()
end


function s.tokenfilter(c,tp)
	return c:IsFaceup() and (c:IsType(TYPE_TOKEN) or c:IsOriginalType(TYPE_TOKEN) ) and c:IsControler(tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.NOT(Card.IsSummonPlayer),1,nil,tp)
	and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsOriginalType,TYPE_TOKEN),tp,LOCATION_MZONE,0,1,nil)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,s.tokenfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.SendtoGrave(g,REASON_EFFECT)
		end

		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e0:SetDescription(aux.Stringid(id,2))
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		if Duel.GetTurnPlayer()==tp then
			e0:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e0:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		e0:SetTargetRange(1,0)
		e0:SetTarget(s.splimit)
		Duel.RegisterEffect(e0,tp)
	end
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not (c:IsSetCard(0xd001) or c:IsType(TYPE_TOKEN) or c:IsOriginalType(TYPE_TOKEN) )
end