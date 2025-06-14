-- Snowdust Blizzard Caster
-- Script by AntoMelon
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),8,2)
	c:EnableReviveLimit()
end