local assets =
{
	Asset("ANIM", "anim/coffeebeans.zip"),
	
	Asset("IMAGE", "images/inventoryimages/kyno_foodimages.tex"),
	Asset("ATLAS", "images/inventoryimages/kyno_foodimages.xml"),
	Asset("ATLAS_BUILD", "images/inventoryimages/kyno_foodimages.xml", 256),
}

local prefabs = 
{
	"kyno_coffeebeans_cooked",
	"spoiled_food",
}

local function OnEatBeans(inst, eater)
    if not eater.components.health or eater.components.health:IsDead() or eater:HasTag("playerghost") then
        return
    elseif eater.components.debuffable and eater.components.debuffable:IsEnabled() then
        eater.coffeebuff_duration = 30
        eater.components.debuffable:AddDebuff("kyno_coffeebuff", "kyno_coffeebuff")
    else
        eater.components.locomotor:SetExternalSpeedMultiplier(eater, "kyno_coffeebuff", 1.83)
        eater:DoTaskInTime(30, function()
            eater.components.locomotor:RemoveExternalSpeedMultiplier(eater, "kyno_coffeebuff")
        end)
    end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst)

	inst.AnimState:SetBank("coffeebeans")
	inst.AnimState:SetBuild("coffeebeans")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("veggie")
	inst:AddTag("cookable")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("bait")
	inst:AddComponent("tradable")

   	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 0
	inst.components.edible.hungervalue = 9.375
	inst.components.edible.sanityvalue = 0
	inst.components.edible.foodtype = FOODTYPE.VEGGIE

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kyno_foodimages.xml"
	inst.components.inventoryitem.imagename = "kyno_coffeebeans"

	inst:AddComponent("cookable")
	inst.components.cookable.product = "kyno_coffeebeans_cooked"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	MakeHauntableLaunchAndPerish(inst)

	return inst
end

local function fn_cooked()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst)

	inst.AnimState:SetBank("coffeebeans")
	inst.AnimState:SetBuild("coffeebeans")
	inst.AnimState:PlayAnimation("cooked")
	
	inst:AddTag("veggie")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("bait")
	inst:AddComponent("tradable")

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 0
	inst.components.edible.hungervalue = 9.375
	inst.components.edible.sanityvalue = -5
	inst.components.edible.foodtype = FOODTYPE.VEGGIE
	inst.components.edible:SetOnEatenFn(OnEatBeans)
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kyno_foodimages.xml"
	inst.components.inventoryitem.imagename = "kyno_coffeebeans_cooked"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	MakeHauntableLaunchAndPerish(inst)

	return inst
end

return Prefab("kyno_coffeebeans", fn, assets),
Prefab("kyno_coffeebeans_cooked", fn_cooked, assets)