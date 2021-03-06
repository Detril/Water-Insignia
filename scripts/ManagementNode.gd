
extends Node

# Constants
const SLOT_SIZE = 64

# Global Variables
var last_selected_apunit = -1
var last_selected_bunit = -1
var last_selected_party = -1
var last_selected_barracks = -1
var populated_storage = 0
var last_selected_repair = -1
var last_selected_type = -1 # 0 = ap, 1 = barracks


var item_swap_mode = 0 # 0 = barracks, 1 = storage
var item_info_mode = 0 # 0 = deactivated, 1 = activated

var wpn_amount = 0
var item_amount = 0

# Global Node References

# Unit Management Nodes (um)
onready var um_ap = get_node("UnitManagement/ActiveParty")
onready var um_b = get_node("UnitManagement/Barracks")
onready var um_s = get_node("UnitManagement/Swap")
onready var um_r = get_node("UnitManagement/Return")
onready var um_aps = get_node("UnitManagement/ActivePartyStatus")
onready var um_bs = get_node("UnitManagement/BarracksStatus")

# Item Management Nodes (im)
onready var im_ap = get_node("ItemManagement/ActiveParty")
onready var im_apw = get_node("ItemManagement/ActivePartyWeapons")
onready var im_api = get_node("ItemManagement/ActivePartyItems")
onready var im_stw = get_node("ItemManagement/StorageWeapons")
onready var im_sti = get_node("ItemManagement/StorageItems")
onready var im_b = get_node("ItemManagement/Barracks")
onready var im_bw = get_node("ItemManagement/BarracksWeapons")
onready var im_bi = get_node("ItemManagement/BarracksItems")
onready var im_si = get_node("ItemManagement/SwapItems")
onready var im_sw = get_node("ItemManagement/SwapWeapons")
onready var im_r = get_node("ItemManagement/Return")
onready var im_apws = get_node("ItemManagement/APWStatus")
onready var im_apis = get_node("ItemManagement/APIStatus")
onready var im_bws = get_node("ItemManagement/BWStatus")
onready var im_bis = get_node("ItemManagement/BIStatus")

# Repair Menu Nodes (rm)
onready var rm_ap = get_node("RepairMenu/ActiveParty")
onready var rm_b = get_node("RepairMenu/Barracks")
onready var rm_w = get_node("RepairMenu/Weapons")
onready var rm_rw = get_node("RepairMenu/RepairWeapon")
onready var rm_ra = get_node("RepairMenu/RepairAll")
onready var rm_rs = get_node("RepairMenu/RepairStatus")
onready var rm_cq = get_node("RepairMenu/CurrentQuesha")

# Shop Menu Nodes (sm)
onready var sm_sw = get_node("ShopManagement/ShopWeapons")
onready var sm_si = get_node("ShopManagement/ShopItems")
onready var sm_sws = get_node("ShopManagement/SWStatus")
onready var sm_sis = get_node("ShopManagement/SIStatus")

onready var sm_stw = get_node("SellManagement/StorageWeapons")
onready var sm_sti = get_node("SellManagement/StorageItems")
onready var sm_stws = get_node("SellManagement/STWStatus")
onready var sm_stis = get_node("SellManagement/STIStatus")

onready var sm_cqb = get_node("ShopManagement/CurrentQuesha")
onready var sm_cqs = get_node("SellManagement/CurrentQuesha")

# Stage Selection Nodes
onready var ss_ps = get_node("SelectStage/PreviousStage")
onready var ss_ns = get_node("SelectStage/NextStage")

# Other Nodes
onready var sfx = get_node("SoundEffects")
onready var bonfire = get_node("AnimatedSprite")

# Databases
var char_database
var wpn_database
var item_database

# Database-related variables

# Estas variáveis não representam o tamanho real da database,
# e sim o tamanho relevante para o Shop exibir a cada momento.
# Temos que trocar por um vetor com numeros, e pega o relevante
# para o andar.

var wpn_shop_availability = [
# We use the modulo operator to determine
# which weapons will be availabe at which
# stages.

# Stages 0 and 1
[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ],

# Stages 2 and 3
[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ],

# Stage 4
[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]

]

var item_shop_availability = [
# We use the modulo operator to determine
# which weapons will be availabe at which
# stages.

# Stages 0 and 1
[ 0, 2, 4, 5, 6 ],

# Stages 2 and 3
[ 0, 2, 4, 5, 6, 7, 8, 9 ],

[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

]

var w_db_size
var i_db_size

# Other Variables / Transitioning data
var screen_size
var window_size

var active_units = []
var barracks_units = []

var storage_weapons = []
var storage_items = []

var current_screen 

# Classes (possibly will not need those in final version, maybe weapon or item for shop, but probably not)

class Unit:
	var id
	var name
	var level
	var wpn_vector = []
	var item_vector = []


class weapon:
	var id
	var name
	var durability
	var type # Weapon type - sword, axe, spear or natural

	# GETTERS
	func get_id():
		return id

	func get_name():
		return name

	func get_durability():
		return durability

	func get_type():
		return type

	# SETTERS
	func set_durability(durability):
		self.durability = durability

	func decrease_durability():
		self.durability -= 1

class item:
	var id
	var name 
	var type # Item's type - HP and/or Effect
	var hp # How much the HP will be affected by the item
	var status # Item's status effect (poison, speed up, ...)
	var durability # Item's total amount
	var amount

	func _init(name, total, database):
		self.id = database.get_item_id(name)
		self.name = name
		self.type = database.get_item_type(id)
		self.hp = database.get_item_hp(id)
		self.status = database.get_item_status(id)
		self.durability = database.get_item_stack(id)
		self.amount = self.durability
	
	func get_id():
		return id

	func get_name():
		return name

	func get_type():
		return type

	func get_hp():
		return hp

	func get_status():
		return status

	func get_max_amount():
		return durability

	func get_amount():
		return amount

	# SETTERS
	func set_amount(amount):
		self.amount = amount

func _ready():
	# Get screen and window sizes, and get databases
	screen_size = OS.get_screen_size()
	window_size = OS.get_window_size()

	char_database = get_node("/root/character_database")
	wpn_database = get_node("/root/weapon_database")
	item_database = get_node("/root/item_database")
	
	var scale = window_size/Vector2(600, 600) # Makes bg screen size
	var pos = (Vector2(600, 600)*scale)/2 # Centralizes bg on screen

	get_node("BackGround").set_scale(scale)
	get_node("BackGround").set_pos(pos)
	
	# Settings for ItemLists
	um_ap.set_max_columns(3)
	um_b.set_max_columns(3)
	im_ap.set_max_columns(3)
	im_b.set_max_columns(3)
	rm_ap.set_max_columns(3)
	rm_b.set_max_columns(3)
	im_apw.set_max_columns(4)
	im_api.set_max_columns(4)
	im_bw.set_max_columns(4)
	im_bi.set_max_columns(4)
	im_stw.set_max_columns(4)
	im_sti.set_max_columns(4)
	rm_w.set_max_columns(4)
	sm_sw.set_max_columns(7)
	sm_si.set_max_columns(7)
	sm_stw.set_max_columns(7)
	sm_sti.set_max_columns(7)
	
	# Populating character lists for active units and barracks
	# Those are instanced here, because for every action taken on
	# the ItemLists, the same action is taken on the actual character
	# arrays, for some operations are index-based
	for unit in active_units:
		um_ap.add_item(char_database.get_char_name(unit.id).capitalize(), load(str(char_database.get_char_folder(unit.id),char_database.get_char_name(unit.id),"0001.tex")), 1)
		im_ap.add_item(char_database.get_char_name(unit.id).capitalize(), load(str(char_database.get_char_folder(unit.id),char_database.get_char_name(unit.id),"0001.tex")), 1)
		rm_ap.add_item(char_database.get_char_name(unit.id).capitalize(), load(str(char_database.get_char_folder(unit.id),char_database.get_char_name(unit.id),"0001.tex")), 1)
	
	for unit in barracks_units:
		um_b.add_item(char_database.get_char_name(unit.id).capitalize(), load(str(char_database.get_char_folder(unit.id),char_database.get_char_name(unit.id),"0001.tex")), 1)
		im_b.add_item(char_database.get_char_name(unit.id).capitalize(), load(str(char_database.get_char_folder(unit.id),char_database.get_char_name(unit.id),"0001.tex")), 1)
		rm_b.add_item(char_database.get_char_name(unit.id).capitalize(), load(str(char_database.get_char_folder(unit.id),char_database.get_char_name(unit.id),"0001.tex")), 1)

	# Populating the shop. Once we have the stage system
	# going on, we can think about changing what the shop
	# sells depending on the stage.
	# Se for para fazer dependendo da fase, vamos precisar de
	# uma database, um vetor para instanciar as armas a serem compradas,
	# e mudar como populamos as statusboxes no script dos statusbox
	
	for i in wpn_shop_availability[floor(get_parent().stage / 2)]:
		if (wpn_database.get_lock(i) != 1):
			sm_sw.add_item("", load(str("res://resources/sprites/weapons/",wpn_database.get_wpn_name(i),".tex")), 1)
			sm_sw.set_item_tooltip(sm_sw.get_item_count() - 1, wpn_database.get_wpn_name(i))
	
#	w_db_size = 5
#	var iter = 0
#	while (iter <= w_db_size):
#		if (wpn_database.get_lock(iter) != 1):
#			sm_sw.add_item("", load(str("res://resources/sprites/weapons/",wpn_database.get_wpn_name(iter),".tex")), 1)
#			sm_sw.set_item_tooltip(sm_sw.get_item_count() - 1, wpn_database.get_wpn_name(iter))
#		iter += 1
	
	for i in item_shop_availability[floor(get_parent().stage / 2)]:
		sm_si.add_item("", load(str("res://resources/sprites/items/",item_database.get_item_name(i),".tex")), 1)
		sm_si.set_item_tooltip(sm_si.get_item_count() - 1, item_database.get_item_name(i))
#	i_db_size = 8
#	iter = 0
#	while (iter <= i_db_size):
#		sm_si.add_item("", load(str("res://resources/sprites/items/",item_database.get_item_name(iter),".tex")), 1)
#		sm_si.set_item_tooltip(sm_si.get_item_count() - 1, item_database.get_item_name(iter))
#		iter += 1
		
	# Fix sizes and positions of some nodes
	size_update()
	
	# Blocks "ready" button if game just begun, or if came
	# back from a party wipe
	if (get_parent().victory == 0):
		get_node("Selection/Play").set_disabled(true)
	else:
		get_node("Selection/Play").set_disabled(false)
	
	# Begin fixed process
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	# Update Unit Management
	Update_UM()
	
	# Update Item Management
	Update_IM()
	
	# Update Repair Menu
	Update_RM()
	
	# Update Shop Menu
	Update_SM()
	
# ######################################### #
# ##### INTERFACE MANAGEMENT FUNCTIONS #### # 
# ######################################### #

func size_update():
	OS.set_window_resizable(0)
	set_size(window_size)
	get_node("Selection").set_size(window_size)
	get_node("PartyMenu").set_size(window_size)
	
	um_ap.set_size(Vector2(window_size.x/3, window_size.y/3))
	um_b.set_size(Vector2(window_size.x/3, window_size.y/3))
	um_b.set_pos((Vector2(window_size.x - 40 - um_b.get_size().x, 40)))
	um_aps.adjust_size("Unit Status", window_size.x/3, window_size.y/3 - 40, um_aps.get_pos().x + 40, 270)
	um_bs.adjust_size("Unit Status", window_size.x/3, window_size.y/3 - 40, window_size.x - 40 - um_b.get_size().x, 270)

	im_ap.set_size(Vector2(window_size.x/3, window_size.y/3))
	im_b.set_size(Vector2(window_size.x/3, window_size.y/3))
	im_b.set_pos((Vector2(window_size.x - 40 - im_b.get_size().x, 40)))

	im_apw.set_size(Vector2(300, 73))
	im_apw.set_pos(Vector2(40, 300))
	im_api.set_size(Vector2(300, 73))
	im_api.set_pos(Vector2(40, 400))
	im_bw.set_size(Vector2(300, 73))
	im_bw.set_pos(Vector2(im_b.get_pos().x, 300))
	im_bi.set_size(Vector2(300, 73))
	im_bi.set_pos(Vector2(im_b.get_pos().x, 400))
	
	im_stw.set_size(Vector2(window_size.x/3, window_size.y/3))
	im_stw.set_pos((Vector2(window_size.x - 40 - im_stw.get_size().x, 40)))
	im_sti.set_size(Vector2(window_size.x/3, window_size.y/3))
	im_sti.set_pos((Vector2(im_b.get_pos().x, im_b.get_pos().y + 220)))
	
	im_apws.adjust_size("Item Status", 120, 90, im_apw.get_pos().x + 325, im_apw.get_pos().y - 8)
	im_apis.adjust_size("Item Status", 120, 90, im_api.get_pos().x + 325, im_api.get_pos().y - 8)
	im_bws.adjust_size("Item Status", 120, 90, im_bw.get_pos().x - 145, im_apw.get_pos().y - 8)
	im_bis.adjust_size("Item Status", 120, 90, im_bi.get_pos().x - 145, im_api.get_pos().y - 8)
	
	get_node("RepairMenu/ActiveParty").set_size(Vector2(window_size.x/3, window_size.y/3))
	get_node("RepairMenu/Barracks").set_size(Vector2(window_size.x/3, window_size.y/2))
	get_node("RepairMenu/Barracks").set_pos(Vector2(40, get_node("RepairMenu/ActiveParty").get_size().y + 50))
	get_node("RepairMenu/Weapons").set_size(Vector2(300, 73))
	get_node("RepairMenu/Weapons").set_pos(Vector2(window_size.x - get_node("RepairMenu/Weapons").get_size().x - 40, 40))
	rm_rs.adjust_size("Repair Status", 300, 100, rm_w.get_pos().x, 130)
	
	get_node("ShopMenu").set_size(Vector2(window_size.x/2, window_size.y))
	
	sm_sw.set_size(Vector2(window_size.x/2, window_size.y/2.5))
	sm_sw.set_pos((Vector2(sm_sw.get_pos().x + 15, sm_sw.get_pos().y + 10)))
	sm_si.set_size(Vector2(window_size.x/2, window_size.y/2.5))
	sm_si.set_pos((Vector2(sm_si.get_pos().x + 15, sm_si.get_pos().y + 260)))
	
	sm_sws.adjust_size("Shop Status", 300, 100, sm_sw.get_pos().x + 525, sm_sw.get_pos().y)
	sm_sis.adjust_size("Shop Status", 300, 100, sm_si.get_pos().x + 525, sm_si.get_pos().y)
	get_node("ShopManagement/Plus1").set_pos(Vector2(sm_sws.get_pos().x + 10, sm_sws.get_pos().y + 120))
	get_node("ShopManagement/Amount1").set_pos(Vector2(sm_sws.get_pos().x + 100, sm_sws.get_pos().y + 110))
	get_node("ShopManagement/Minus1").set_pos(Vector2(sm_sws.get_pos().x + 210, sm_sws.get_pos().y + 120))
	get_node("ShopManagement/Plus2").set_pos(Vector2(sm_sis.get_pos().x + 10, sm_sis.get_pos().y + 120))
	get_node("ShopManagement/Amount2").set_pos(Vector2(sm_sis.get_pos().x + 100, sm_sis.get_pos().y + 110))
	get_node("ShopManagement/Minus2").set_pos(Vector2(sm_sis.get_pos().x + 210, sm_sis.get_pos().y + 120))
	
	sm_stw.set_size(Vector2(window_size.x/2, window_size.y/2.5))
	sm_stw.set_pos((Vector2(sm_stw.get_pos().x + 15, sm_stw.get_pos().y + 10)))
	sm_sti.set_size(Vector2(window_size.x/2, window_size.y/2.5))
	sm_sti.set_pos((Vector2(sm_sti.get_pos().x + 15, sm_sti.get_pos().y + 260)))
	
	sm_stws.adjust_size("Shop Status", 300, 100, sm_stw.get_pos().x + 525, sm_stw.get_pos().y)
	sm_stis.adjust_size("Shop Status", 300, 100, sm_sti.get_pos().x + 525, sm_sti.get_pos().y)
	
	get_node("SelectStage/PreviousLook").set_pos(Vector2(get_node("SelectStage/PreviousStage").get_pos().x + 110, get_node("SelectStage/PreviousStage").get_pos().y - 100))
	get_node("SelectStage/PreviousLook").set_scale(Vector2(0.4, 0.4))
	get_node("SelectStage/PreviousText").set_pos(Vector2(get_node("SelectStage/PreviousLook").get_pos().x - 45, get_node("SelectStage/PreviousLook").get_pos().y - 150))
	get_node("SelectStage/NextLook").set_pos(Vector2(get_node("SelectStage/NextStage").get_pos().x + 110, get_node("SelectStage/NextStage").get_pos().y - 100))
	get_node("SelectStage/NextLook").set_scale(Vector2(0.4, 0.4))
	get_node("SelectStage/NextText").set_pos(Vector2(get_node("SelectStage/NextLook").get_pos().x - 45, get_node("SelectStage/PreviousLook").get_pos().y - 150))
	get_node("SelectStage/PartyIndicator").set_pos(Vector2(get_node("SelectStage/PreviousLook").get_pos().x + 215, get_node("SelectStage/NextLook").get_pos().y))
	get_node("SelectStage/PartyIndicator").set_scale(Vector2(2, 2))
	
# This function coordinates the state of the swap button,
# as well as the status boxes in the Unit Management screen
func Update_UM():
	if (um_ap.get_selected_items().size() != 0 or um_b.get_selected_items().size() != 0):
		if (um_ap.get_selected_items().size() != 0 and um_b.get_selected_items().size() != 0):
			# Ambos selecionados, exibe informações nas status boxes
			if (last_selected_apunit != um_ap.get_selected_items()[0]):
				um_aps.neutralize_node("Unit Status")
				um_aps.instance_animation(active_units[um_ap.get_selected_items()[0]].id, 2.5)
				last_selected_apunit = um_ap.get_selected_items()[0]
				um_aps.get_node("Name").set_text(char_database.get_char_name(active_units[um_ap.get_selected_items()[0]].id).capitalize())
				#um_aps.get_node("Class").set_text("Class PH")
				um_aps.get_node("Attack").set_text(str("ATK: ", char_database.get_attack(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("Defense").set_text(str("DEF: ", char_database.get_defense(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("SpecialAttack").set_text(str("SPATK: ", char_database.get_sp_attack(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("SpecialDefense").set_text(str("SPDEF: ", char_database.get_sp_defense(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("Dexterity").set_text(str("DEX: ", char_database.get_dexterity(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("Speed").set_text(str("SPD: ", char_database.get_speed(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("Luck").set_text(str("LUK: ", char_database.get_luck(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
			if (last_selected_bunit != um_b.get_selected_items()[0]):
				um_bs.neutralize_node("Unit Status")
				um_bs.instance_animation(barracks_units[um_b.get_selected_items()[0]].id, 2.5)
				last_selected_bunit = um_b.get_selected_items()[0]
				um_bs.get_node("Name").set_text(char_database.get_char_name(barracks_units[um_b.get_selected_items()[0]].id).capitalize())
				#um_bs.get_node("Class").set_text("Class PH")
				um_bs.get_node("Attack").set_text(str("ATK: ", char_database.get_attack(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("Defense").set_text(str("DEF: ", char_database.get_defense(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("SpecialAttack").set_text(str("SPATK: ", char_database.get_sp_attack(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("SpecialDefense").set_text(str("SPDEF: ", char_database.get_sp_defense(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("Dexterity").set_text(str("DEX: ", char_database.get_dexterity(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("Speed").set_text(str("SPD: ", char_database.get_speed(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("Luck").set_text(str("LUK: ", char_database.get_luck(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
			# Coordena estado do botão de swap
			um_s.set_disabled(false)
		elif (um_ap.get_selected_items().size() == 0):
			# Selecionado membro da barracks, exibe informações na status box
			if (last_selected_bunit != um_b.get_selected_items()[0]):
				um_bs.neutralize_node("Unit Status")
				um_bs.instance_animation(barracks_units[um_b.get_selected_items()[0]].id, 2.5)
				last_selected_bunit = um_b.get_selected_items()[0]
				um_bs.get_node("Name").set_text(char_database.get_char_name(barracks_units[um_b.get_selected_items()[0]].id).capitalize())
				#um_bs.get_node("Class").set_text("Class PH")
				um_bs.get_node("Attack").set_text(str("ATK: ", char_database.get_attack(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("Defense").set_text(str("DEF: ", char_database.get_defense(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("SpecialAttack").set_text(str("SPATK: ", char_database.get_sp_attack(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("SpecialDefense").set_text(str("SPDEF: ", char_database.get_sp_defense(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("Dexterity").set_text(str("DEX: ", char_database.get_dexterity(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("Speed").set_text(str("SPD: ", char_database.get_speed(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
				um_bs.get_node("Luck").set_text(str("LUK: ", char_database.get_luck(barracks_units[um_b.get_selected_items()[0]].id, barracks_units[um_b.get_selected_items()[0]].level)))
			# Neutralizando a status box das unidades ativas
			um_aps.neutralize_node("Unit Status")
			last_selected_apunit = -1
			
			# Coordena estado do botão de swap
			if (um_ap.get_item_count() != 4):
				um_s.set_disabled(false)
			else:
				um_s.set_disabled(true)
		else:
			# Selecionado membro da active party, exibe informações na status box
			if (last_selected_apunit != um_ap.get_selected_items()[0]):
				um_aps.neutralize_node("Unit Status")
				um_aps.instance_animation(active_units[um_ap.get_selected_items()[0]].id, 2.5)
				last_selected_apunit = um_ap.get_selected_items()[0]
				um_aps.get_node("Name").set_text(char_database.get_char_name(active_units[um_ap.get_selected_items()[0]].id).capitalize())
				#um_aps.get_node("Class").set_text("Class PH")
				um_aps.get_node("Attack").set_text(str("ATK: ", char_database.get_attack(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("Defense").set_text(str("DEF: ", char_database.get_defense(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("SpecialAttack").set_text(str("SPATK: ", char_database.get_sp_attack(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("SpecialDefense").set_text(str("SPDEF: ", char_database.get_sp_defense(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("Dexterity").set_text(str("DEX: ", char_database.get_dexterity(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("Speed").set_text(str("SPD: ", char_database.get_speed(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
				um_aps.get_node("Luck").set_text(str("LUK: ", char_database.get_luck(active_units[um_ap.get_selected_items()[0]].id, active_units[um_ap.get_selected_items()[0]].level)))
			# Neutralizando a status box das unidades das barracks
			um_bs.neutralize_node("Unit Status")
			last_selected_bunit = -1
			
			# Coordena estado do botão de swap
			if (um_ap.get_item_count() != 1):
				um_s.set_disabled(false)
			else:
				um_s.set_disabled(true)
	else:
		# Tira todas as informações, pois nenhum está selecionado
		um_aps.neutralize_node("Unit Status")
		last_selected_apunit = -1
		um_bs.neutralize_node("Unit Status")
		last_selected_bunit = -1
		
		# Coordena estado do botão de swap
		um_s.set_disabled(true)

func Update_IM():
	if (im_ap.get_selected_items().size() != 0):
		# Popula e mostra armas e items para party ativa
		if (last_selected_party != im_ap.get_selected_items()[0]):
			im_apw.clear()
			im_api.clear()
			for weapon in active_units[im_ap.get_selected_items()[0]].wpn_vector:
				im_apw.add_item("", load(str("res://resources/sprites/weapons/",weapon.name,".tex")), 1)
				im_apw.set_item_tooltip(im_apw.get_item_count() - 1, weapon.name)
				if (wpn_database.get_lock(weapon.id) == 1):
						im_apw.set_item_selectable(im_apw.get_item_count() - 1, false)
			for item in active_units[im_ap.get_selected_items()[0]].item_vector:
				im_api.add_item("", load(str("res://resources/sprites/items/",item.name,".tex")), 1)
				im_api.set_item_tooltip(im_api.get_item_count() - 1, item.name)
			last_selected_party = im_ap.get_selected_items()[0]
	else:
		im_apw.clear()
		im_api.clear()
		last_selected_party = -1
			
	# Checagens para o modo manage barracks items
	if (item_swap_mode == 0):
		if (im_b.get_selected_items().size() != 0):
			# Popula e mostra armas e items para barracks
			if (last_selected_barracks != im_b.get_selected_items()[0]):
				im_bw.clear()
				im_bi.clear()
				for weapon in barracks_units[im_b.get_selected_items()[0]].wpn_vector:
					im_bw.add_item("", load(str("res://resources/sprites/weapons/",weapon.name,".tex")), 1)
					im_bw.set_item_tooltip(im_bw.get_item_count() - 1, weapon.name)
					if (wpn_database.get_lock(weapon.id) == 1):
						im_bw.set_item_selectable(im_bw.get_item_count() - 1, false)
				for item in barracks_units[im_b.get_selected_items()[0]].item_vector:
					im_bi.add_item("", load(str("res://resources/sprites/items/",item.name,".tex")), 1)
					im_bi.set_item_tooltip(im_bi.get_item_count() - 1, item.name)
				last_selected_barracks = im_b.get_selected_items()[0]
		else:
			im_bw.clear()
			im_bi.clear()
			last_selected_barracks = -1
	
		# Condições do botão de swap para armas
		if (im_ap.get_selected_items().size() != 0 and im_b.get_selected_items().size() != 0):
			if (im_apw.get_selected_items().size() != 0 or im_bw.get_selected_items().size() != 0):
				if (im_apw.get_selected_items().size() == 0):
					# Mostra o status para a arma do barracks,
					# some com a da party ativa
					im_bws.update_statusbox(barracks_units[im_b.get_selected_items()[0]].wpn_vector[im_bw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
					im_apws.neutralize_node("Item Status")
					
					if (im_apw.get_item_count() != 4):
						im_sw.set_disabled(false)
					else:
						im_sw.set_disabled(true)
				if (im_bw.get_selected_items().size() == 0):
					# Mostra o status para a arma do barracks,
					# some com a da party ativa
					im_apws.update_statusbox(active_units[im_ap.get_selected_items()[0]].wpn_vector[im_apw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
					im_bws.neutralize_node("Item Status")
					
					if (im_bw.get_item_count() != 4):
						im_sw.set_disabled(false)
					else:
						im_sw.set_disabled(true)
			else:
				im_apws.neutralize_node("Item Status")
				im_bws.neutralize_node("Item Status")
				
				im_sw.set_disabled(true)
			if (im_apw.get_selected_items().size() != 0 and im_bw.get_selected_items().size() != 0):
				im_apws.update_statusbox(active_units[im_ap.get_selected_items()[0]].wpn_vector[im_apw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
				im_bws.update_statusbox(barracks_units[im_b.get_selected_items()[0]].wpn_vector[im_bw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
				
				im_sw.set_disabled(false)
				
			# Condições do botão de swap para items
			# Observação: as condições da arma e dos itens poderiam ser
			# unificados em uma unica função, mas não o das unidades, que
			# é ligeiramente diferente
			if (im_api.get_selected_items().size() != 0 or im_bi.get_selected_items().size() != 0):
				if (im_api.get_selected_items().size() == 0):
					if (im_api.get_item_count() != 4):
						im_si.set_disabled(false)
					else:
						im_si.set_disabled(true)
				if (im_bi.get_selected_items().size() == 0):
					if (im_bi.get_item_count() != 4):
						im_si.set_disabled(false)
					else:
						im_si.set_disabled(true)
			else:
				im_si.set_disabled(true)
			if (im_api.get_selected_items().size() != 0 and im_bi.get_selected_items().size() != 0):
				im_si.set_disabled(false)
		else:
			im_sw.set_disabled(true)
			im_si.set_disabled(true)
			
		# Condições para a exibição de informações de armas
		if (im_apw.get_selected_items().size() != 0 or im_bw.get_selected_items().size() != 0):
			if (im_b.get_selected_items().size() != 0 and im_apw.get_selected_items().size() == 0):
				# Mostra o status para a arma do barracks,
				# some com a da party ativa
				im_bws.update_statusbox(barracks_units[im_b.get_selected_items()[0]].wpn_vector[im_bw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
				im_apws.neutralize_node("Item Status")

			if (im_ap.get_selected_items().size() != 0 and im_bw.get_selected_items().size() == 0):
				# Mostra o status para a arma da party ativa,
				# some com a do barracks
				im_apws.update_statusbox(active_units[im_ap.get_selected_items()[0]].wpn_vector[im_apw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
				im_bws.neutralize_node("Item Status")

		else:
			im_apws.neutralize_node("Item Status")
			im_bws.neutralize_node("Item Status")

		if (im_apw.get_selected_items().size() != 0 and im_bw.get_selected_items().size() != 0):
			im_apws.update_statusbox(active_units[im_ap.get_selected_items()[0]].wpn_vector[im_apw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
			im_bws.update_statusbox(barracks_units[im_b.get_selected_items()[0]].wpn_vector[im_bw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
		
		# Condições para a exibição de informações de items
		if (im_api.get_selected_items().size() != 0 or im_bi.get_selected_items().size() != 0):
			if (im_api.get_selected_items().size() == 0):
				# Mostra o status para o item do barracks,
				# some com o da party ativa
				im_bis.update_statusbox(barracks_units[im_b.get_selected_items()[0]].item_vector[im_bi.get_selected_items()[0]], "Item Status", "Item", item_database)
				im_apis.neutralize_node("Item Status")

			if (im_bi.get_selected_items().size() == 0):
				# Mostra o status para o item da party ativa,
				# some com o do barracks
				im_apis.update_statusbox(active_units[im_ap.get_selected_items()[0]].item_vector[im_api.get_selected_items()[0]], "Item Status", "Item", item_database)
				im_bis.neutralize_node("Item Status")

		else:
			im_apis.neutralize_node("Item Status")
			im_bis.neutralize_node("Item Status")

		if (im_api.get_selected_items().size() != 0 and im_bi.get_selected_items().size() != 0):
			im_apis.update_statusbox(active_units[im_ap.get_selected_items()[0]].item_vector[im_api.get_selected_items()[0]], "Item Status", "Item", item_database)
			im_bis.update_statusbox(barracks_units[im_b.get_selected_items()[0]].item_vector[im_bi.get_selected_items()[0]], "Item Status", "Item", item_database)
	
	# Checagens para o modo manage storage items
	else:
		if (populated_storage == 0):
			# Popula e mostra armas e items para storage
			for weapon in storage_weapons:
				im_stw.add_item("", load(str("res://resources/sprites/weapons/",weapon.name,".tex")), 1)
				im_stw.set_item_tooltip(im_stw.get_item_count() - 1, weapon.name)
			for item in storage_items:
				im_sti.add_item("", load(str("res://resources/sprites/items/",item.name,".tex")), 1)
				im_sti.set_item_tooltip(im_sti.get_item_count() - 1, item.name)
			populated_storage = 1
		# Condições do botão de swap...
		if (im_ap.get_selected_items().size() != 0):
			# ...para armas
			if (im_apw.get_selected_items().size() != 0 or im_stw.get_selected_items().size() != 0):
				if (im_apw.get_selected_items().size() == 0):
					if (im_apw.get_item_count() != 4):
						im_sw.set_disabled(false)
					else:
						im_sw.set_disabled(true)
				else:
					im_sw.set_disabled(false)
			else:
				im_sw.set_disabled(true)
			# ...para items
			if (im_api.get_selected_items().size() != 0 or im_sti.get_selected_items().size() != 0):
				if (im_api.get_selected_items().size() == 0):
					if (im_api.get_item_count() != 4):
						im_si.set_disabled(false)
					else:
						im_si.set_disabled(true)
				else:
					im_si.set_disabled(false)
			else:
				im_si.set_disabled(true)
		else:
			im_si.set_disabled(true)
		
		# Caso alguma hora queiramos customizar a statusbox do storage,
		# temos que fazer alterações aqui, e criar mais duas statusbox
		# proprias para isso, e fazer as mudanças em outros lugares, como
		# o botão de troca de modos, entre outras coisas
		
		# As partes que tem "b" aqui, referem-se ao fato de estarmos usando
		# as statusboxes das barracks para a storage também

		# Condições para a exibição de informações de armas
		if (im_apw.get_selected_items().size() != 0 or im_stw.get_selected_items().size() != 0):
			if (im_apw.get_selected_items().size() == 0):
				# Mostra o status para a arma do barracks,
				# some com a da party ativa
				im_bws.update_statusbox(storage_weapons[im_stw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
				im_apws.neutralize_node("Item Status")

			if (im_stw.get_selected_items().size() == 0):
				# Mostra o status para a arma da party ativa,
				# some com a do storage
				im_apws.update_statusbox(active_units[im_ap.get_selected_items()[0]].wpn_vector[im_apw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
				im_bws.neutralize_node("Item Status")

		else:
			im_apws.neutralize_node("Item Status")
			im_bws.neutralize_node("Item Status")

		if (im_apw.get_selected_items().size() != 0 and im_stw.get_selected_items().size() != 0):
			im_apws.update_statusbox(active_units[im_ap.get_selected_items()[0]].wpn_vector[im_apw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
			im_bws.update_statusbox(storage_weapons[im_stw.get_selected_items()[0]], "Item Status", "Weapon", wpn_database)
		
		# Condições para a exibição de informações de items
		if (im_api.get_selected_items().size() != 0 or im_sti.get_selected_items().size() != 0):
			if (im_api.get_selected_items().size() == 0):
				# Mostra o status para o item do storage,
				# some com o da party ativa
				im_bis.update_statusbox(storage_items[im_sti.get_selected_items()[0]], "Item Status", "Item", item_database)
				im_apis.neutralize_node("Item Status")

			if (im_sti.get_selected_items().size() == 0):
				# Mostra o status para o item da party ativa,
				# some com o do barracks
				im_apis.update_statusbox(active_units[im_ap.get_selected_items()[0]].item_vector[im_api.get_selected_items()[0]], "Item Status", "Item", item_database)
				im_bis.neutralize_node("Item Status")

		else:
			im_apis.neutralize_node("Item Status")
			im_bis.neutralize_node("Item Status")

		if (im_api.get_selected_items().size() != 0 and im_sti.get_selected_items().size() != 0):
			im_apis.update_statusbox(active_units[im_ap.get_selected_items()[0]].item_vector[im_api.get_selected_items()[0]], "Item Status", "Item", item_database)
			im_bis.update_statusbox(storage_items[im_sti.get_selected_items()[0]], "Item Status", "Item", item_database)

func Update_RM():
	if (rm_ap.get_selected_items().size() != 0 or rm_b.get_selected_items().size() != 0):
		if (rm_ap.get_selected_items().size() != 0):
			# Popula e mostra armas e items para party ativa,
			# dando clear na seleção do barracks, primeiramente
			if (last_selected_type == 1 or last_selected_repair != rm_ap.get_selected_items()[0]):
				for item in rm_b.get_selected_items():
					rm_b.unselect(item)
				rm_w.clear()
				for weapon in active_units[rm_ap.get_selected_items()[0]].wpn_vector:
					rm_w.add_item("", load(str("res://resources/sprites/weapons/",weapon.name,".tex")), 1)
					rm_w.set_item_tooltip(rm_ap.get_item_count() - 1, weapon.name)
					if (wpn_database.get_durability(weapon.id) < 0):
						rm_w.set_item_selectable(rm_w.get_item_count() - 1, false)
				last_selected_repair = rm_ap.get_selected_items()[0]
				last_selected_type = 0

		if (rm_b.get_selected_items().size() != 0):
			# Popula e mostra armas e items para barracks,
			# dando clear na seleção da party, primeiramente
			if (last_selected_type == 0 or last_selected_repair != rm_b.get_selected_items()[0]):
				for item in rm_ap.get_selected_items():
					rm_ap.unselect(item)
				rm_w.clear()
				for weapon in barracks_units[rm_b.get_selected_items()[0]].wpn_vector:
					rm_w.add_item("", load(str("res://resources/sprites/weapons/",weapon.name,".tex")), 1)
					rm_w.set_item_tooltip(rm_b.get_item_count() - 1, weapon.name)
					if (wpn_database.get_durability(weapon.id) < 0):
						rm_w.set_item_selectable(rm_w.get_item_count() - 1, false)
				last_selected_repair = rm_b.get_selected_items()[0]
				last_selected_type = 1
		
	else:
		# Nenhum selecionado, limpa a lista de armas
		last_selected_repair = -1
		last_selected_type = -1
		rm_w.clear()
	
	####################################################################
	# Deve estar dando problema para armas com durabilidade menor que 0
	# Certificar que ela sejam resetadas para -1 no fim de cada combate!
	# No caso, o repair all da problema
	####################################################################
		
	# Condições do botão repair weapon
	if (rm_w.get_selected_items().size() != 0):
		var weapon
		# A arma selecionada era de um membro da party ativa
		if (last_selected_type == 0):
			# Atualiza a RepairStatus
			weapon = active_units[rm_ap.get_selected_items()[0]].wpn_vector[rm_w.get_selected_items()[0]]
			rm_rs.update_statusbox(weapon, "Repair Status", null, wpn_database)
			
			# Checa se a durabilidade atual da arma selecionada
			# é menor do que sua durabilidade original
			if (weapon.durability < wpn_database.get_durability(weapon.id)) and (get_parent().quesha >= ceil((wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50)):
				rm_rw.set_disabled(false)
			else:
				rm_rw.set_disabled(true)
		else:
			# Atualiza a RepairStatus
			weapon = barracks_units[rm_b.get_selected_items()[0]].wpn_vector[rm_w.get_selected_items()[0]]
			rm_rs.update_statusbox(weapon, "Repair Status", null, wpn_database)
			
			# Checa se a durabilidade atual da arma selecionada
			# é menor do que sua durabilidade original
			if (weapon.durability < wpn_database.get_durability(weapon.id)) and (get_parent().quesha >= wpn_database.get_price(weapon.id)):
				rm_rw.set_disabled(false)
			else:
				rm_rw.set_disabled(true)
	else:
		rm_rs.neutralize_node("Repair Status")
		rm_rw.set_disabled(true)
	
	# Condições do botão repair all
	if (rm_ap.get_selected_items().size() != 0 or rm_b.get_selected_items().size() != 0):
		# Membro da party ativa selecionado, verificar para cada uma das armas
		if (rm_ap.get_selected_items().size() != 0):
			var min_cond = 0
			for weapon in active_units[rm_ap.get_selected_items()[0]].wpn_vector:
				if (weapon.durability < wpn_database.get_durability(weapon.id)):
					rm_ra.set_disabled(false)
					min_cond = 1
			var price = 0
			for weapon in active_units[rm_ap.get_selected_items()[0]].wpn_vector:
				price += ceil((wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50)
			if min_cond == 0 or get_parent().quesha < price:
				rm_ra.set_disabled(true)
		# Membro da barracks selecionado, verificar para cada uma das armas
		else:
			var min_cond = 0
			for weapon in barracks_units[rm_b.get_selected_items()[0]].wpn_vector:
				if (weapon.durability < wpn_database.get_durability(weapon.id)):
					rm_ra.set_disabled(false)
					min_cond = 1
			var price = 0
			for weapon in barracks_units[rm_b.get_selected_items()[0]].wpn_vector:
				price += (wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50
			if min_cond == 0 or get_parent().quesha < price:
				rm_ra.set_disabled(true)
	# Nenhum selecionado, desabilita o botão
	else:
		rm_ra.set_disabled(true)

func Update_SM():
	# ver se precisa resetar o amount toda vez que troca de arma/item
	# se precisar, vai precisar de mais uma last_selected para cada
	if (sm_sw.get_selected_items().size() != 0):
		sm_sws.update_statusbox(wpn_shop_availability[floor(get_parent().stage / 2)][sm_sw.get_selected_items()[0]], "Shop Status", "Weapon", wpn_database)
		get_node("ShopManagement/Plus1").show()
		get_node("ShopManagement/Amount1").set_text(str(wpn_amount))
		get_node("ShopManagement/Amount1").show()
		if (wpn_amount <= 0):
			get_node("ShopManagement/Minus1").set_disabled(true)
		else:
			get_node("ShopManagement/Minus1").set_disabled(false)
		get_node("ShopManagement/Minus1").show()
	else:
		sm_sws.neutralize_node("Shop Status")
		get_node("ShopManagement/Plus1").hide()
		wpn_amount = 0
		get_node("ShopManagement/Amount1").hide()
		get_node("ShopManagement/Minus1").hide()
	if (sm_si.get_selected_items().size() != 0):
		sm_sis.update_statusbox(item_shop_availability[floor(get_parent().stage / 2)][sm_si.get_selected_items()[0]], "Shop Status", "Item", item_database)
		get_node("ShopManagement/Plus2").show()
		get_node("ShopManagement/Amount2").set_text(str(item_amount))
		get_node("ShopManagement/Amount2").show()
		if (item_amount <= 0):
			get_node("ShopManagement/Minus2").set_disabled(true)
		else:
			get_node("ShopManagement/Minus2").set_disabled(false)
		get_node("ShopManagement/Minus2").show()
	else:
		sm_sis.neutralize_node("Shop Status")
		get_node("ShopManagement/Plus2").hide()
		item_amount = 0
		get_node("ShopManagement/Amount2").hide()
		get_node("ShopManagement/Minus2").hide()
	
	if (wpn_amount == 0 and item_amount == 0):
		get_node("ShopManagement/Buy").set_disabled(true)
	else:
		# Apenas comprando armas
		if (item_amount == 0):
			if (wpn_database.get_price(wpn_shop_availability[floor(get_parent().stage / 2)][sm_sw.get_selected_items()[0]]) * wpn_amount <= get_parent().quesha):
				get_node("ShopManagement/Buy").set_disabled(false)
			else:
				get_node("ShopManagement/Buy").set_disabled(true)
		# Apenas comprando items
		elif (wpn_amount == 0):
			if (item_database.get_price(item_shop_availability[floor(get_parent().stage / 2)][sm_si.get_selected_items()[0]]) * item_amount <= get_parent().quesha):
				get_node("ShopManagement/Buy").set_disabled(false)
			else:
				get_node("ShopManagement/Buy").set_disabled(true)
		# Comprando ambos armas e items
		else:
			if ((wpn_database.get_price(wpn_shop_availability[floor(get_parent().stage / 2)][sm_sw.get_selected_items()[0]]) * wpn_amount) + (item_database.get_price(item_shop_availability[floor(get_parent().stage / 2)][sm_si.get_selected_items()[0]]) * item_amount) <= get_parent().quesha):
				get_node("ShopManagement/Buy").set_disabled(false)
			else:
				get_node("ShopManagement/Buy").set_disabled(true)
	
	# Certificando a corretude da exibição da storage,
	# e populando as suas listas
	if (current_screen == "SellManagement"):
		if (populated_storage == 0):
				# Popula e mostra armas e items para storage
				for weapon in storage_weapons:
					sm_stw.add_item("", load(str("res://resources/sprites/weapons/",weapon.name,".tex")), 1)
					sm_stw.set_item_tooltip(sm_stw.get_item_count() - 1, weapon.name)
				for item in storage_items:
					sm_sti.add_item("", load(str("res://resources/sprites/items/",item.name,".tex")), 1)
					sm_sti.set_item_tooltip(sm_sti.get_item_count() - 1, item.name)
				populated_storage = 1
	
	 # Condições para a statusbox da storage no menu de vendas
	if (sm_stw.get_selected_items().size() != 0):
		sm_stws.update_statusbox(storage_weapons[sm_stw.get_selected_items()[0]], "Sell Status", "Weapon", wpn_database)
		# Possivelmente fazer o preço depender da durabilidade restante, no futuro?
		sm_stws.get_node("Price").set_text(str("Price: ", (wpn_database.get_price(storage_weapons[sm_stw.get_selected_items()[0]].id) / 2) * (storage_weapons[sm_stw.get_selected_items()[0]].durability / wpn_database.get_durability(storage_weapons[sm_stw.get_selected_items()[0]].id))))
	else:
		sm_stws.neutralize_node("Shop Status")
	if (sm_sti.get_selected_items().size() != 0):
		sm_stis.update_statusbox(storage_items[sm_sti.get_selected_items()[0]], "Sell Status", "Item", item_database)
		# Possivelmente fazer o preço depender da durabilidade restante, no futuro?
		sm_stis.get_node("Price").set_text(str("Price: ", (item_database.get_price(storage_items[sm_sti.get_selected_items()[0]].id) / 2) * (storage_items[sm_sti.get_selected_items()[0]].amount) / item_database.get_item_stack((storage_items[sm_sti.get_selected_items()[0]].id))))
	else:
		sm_stis.neutralize_node("Shop Status")
	if (sm_stw.get_selected_items().size() != 0 or sm_sti.get_selected_items().size() != 0):
		get_node("SellManagement/Sell").set_disabled(false)
	else:
		get_node("SellManagement/Sell").set_disabled(true)
		
# ########################################### #
# ##### UNIT MANAGEMENT BUTTON FUNCTIONS #### # 
# ########################################### #

func _on_Swap_pressed():
	# Active and Barracks units selected
	if (um_ap.get_selected_items().size() != 0 and um_b.get_selected_items().size() != 0):
		var a_unit = active_units[um_ap.get_selected_items()[0]]
		var a_local_id = um_ap.get_selected_items()[0]
		var b_unit = barracks_units[um_b.get_selected_items()[0]]
		var b_local_id = um_b.get_selected_items()[0]
		active_units.append(b_unit)
		um_ap.add_item(char_database.get_char_name(b_unit.id).capitalize(), load(str(char_database.get_char_folder(b_unit.id),char_database.get_char_name(b_unit.id),"0001.tex")), 1)
		im_ap.add_item(char_database.get_char_name(b_unit.id).capitalize(), load(str(char_database.get_char_folder(b_unit.id),char_database.get_char_name(b_unit.id),"0001.tex")), 1)
		rm_ap.add_item(char_database.get_char_name(b_unit.id).capitalize(), load(str(char_database.get_char_folder(b_unit.id),char_database.get_char_name(b_unit.id),"0001.tex")), 1)
		barracks_units.append(a_unit)
		um_b.add_item(char_database.get_char_name(a_unit.id).capitalize(), load(str(char_database.get_char_folder(a_unit.id),char_database.get_char_name(a_unit.id),"0001.tex")), 1)
		im_b.add_item(char_database.get_char_name(a_unit.id).capitalize(), load(str(char_database.get_char_folder(a_unit.id),char_database.get_char_name(a_unit.id),"0001.tex")), 1)
		rm_b.add_item(char_database.get_char_name(a_unit.id).capitalize(), load(str(char_database.get_char_folder(a_unit.id),char_database.get_char_name(a_unit.id),"0001.tex")), 1)
		active_units.remove(a_local_id)
		um_ap.remove_item(a_local_id)
		im_ap.remove_item(a_local_id)
		rm_ap.remove_item(a_local_id)
		barracks_units.remove(b_local_id)
		um_b.remove_item(b_local_id)
		im_b.remove_item(b_local_id)
		rm_b.remove_item(b_local_id)
		
	# Only Active unit selected // vai ter tamanho maximo de barracks?
	if (um_ap.get_selected_items().size() != 0 and um_b.get_selected_items().size() == 0):
		var a_unit = active_units[um_ap.get_selected_items()[0]]
		var a_local_id = um_ap.get_selected_items()[0]
		barracks_units.append(a_unit)
		um_b.add_item(char_database.get_char_name(a_unit.id).capitalize(), load(str(char_database.get_char_folder(a_unit.id),char_database.get_char_name(a_unit.id),"0001.tex")), 1)
		im_b.add_item(char_database.get_char_name(a_unit.id).capitalize(), load(str(char_database.get_char_folder(a_unit.id),char_database.get_char_name(a_unit.id),"0001.tex")), 1)
		rm_b.add_item(char_database.get_char_name(a_unit.id).capitalize(), load(str(char_database.get_char_folder(a_unit.id),char_database.get_char_name(a_unit.id),"0001.tex")), 1)
		active_units.remove(a_local_id)
		um_ap.remove_item(a_local_id)
		im_ap.remove_item(a_local_id)
		rm_ap.remove_item(a_local_id)
	# Only Barracks unit selected
	if (um_ap.get_selected_items().size() == 0 and um_b.get_selected_items().size() != 0):
		var b_unit = barracks_units[um_b.get_selected_items()[0]]
		var b_local_id = um_b.get_selected_items()[0]
		active_units.append(b_unit)
		um_ap.add_item(char_database.get_char_name(b_unit.id).capitalize(), load(str(char_database.get_char_folder(b_unit.id),char_database.get_char_name(b_unit.id),"0001.tex")), 1)
		im_ap.add_item(char_database.get_char_name(b_unit.id).capitalize(), load(str(char_database.get_char_folder(b_unit.id),char_database.get_char_name(b_unit.id),"0001.tex")), 1)
		rm_ap.add_item(char_database.get_char_name(b_unit.id).capitalize(), load(str(char_database.get_char_folder(b_unit.id),char_database.get_char_name(b_unit.id),"0001.tex")), 1)
		barracks_units.remove(b_local_id)
		um_b.remove_item(b_local_id)
		im_b.remove_item(b_local_id)
		rm_b.remove_item(b_local_id)
	
	#Clear information boxes
	um_aps.neutralize_node("Unit Status")
	um_bs.neutralize_node("Unit Status")
	last_selected_apunit = -1
	last_selected_bunit = -1

# ########################################### #
# ##### ITEM MANAGEMENT BUTTON FUNCTIONS #### # 
# ########################################### #

func _on_SwapWeapons_pressed():
	if (item_swap_mode == 0):
		# Active and Barracks weapons selected
		if (im_apw.get_selected_items().size() != 0 and im_bw.get_selected_items().size() != 0):
			var a_unit = active_units[im_ap.get_selected_items()[0]]
			var a_wpn = a_unit.wpn_vector[im_apw.get_selected_items()[0]]
			var a_local_wpn_id = im_apw.get_selected_items()[0]
			var b_unit = barracks_units[im_b.get_selected_items()[0]]
			var b_wpn = b_unit.wpn_vector[im_bw.get_selected_items()[0]]
			var b_local_wpn_id = im_bw.get_selected_items()[0]
			#condiçao de lock da arma vem aqui
			active_units[im_ap.get_selected_items()[0]].wpn_vector.append(b_wpn)
			im_apw.add_item("", load(str("res://resources/sprites/weapons/",b_wpn.name,".tex")), 1)
			im_apw.set_item_tooltip(im_apw.get_item_count() - 1, b_wpn.name)
			barracks_units[im_b.get_selected_items()[0]].wpn_vector.append(a_wpn)
			im_bw.add_item("", load(str("res://resources/sprites/weapons/",a_wpn.name,".tex")), 1)
			im_bw.set_item_tooltip(im_apw.get_item_count() - 1, a_wpn.name)
			active_units[im_ap.get_selected_items()[0]].wpn_vector.remove(a_local_wpn_id)
			im_apw.remove_item(a_local_wpn_id)
			barracks_units[im_b.get_selected_items()[0]].wpn_vector.remove(b_local_wpn_id)
			im_bw.remove_item(b_local_wpn_id)
			
		# Only Active unit weapon selected
		if (im_apw.get_selected_items().size() != 0 and im_bw.get_selected_items().size() == 0):
			var a_unit = active_units[im_ap.get_selected_items()[0]]
			var a_wpn = a_unit.wpn_vector[im_apw.get_selected_items()[0]]
			var a_local_wpn_id = im_apw.get_selected_items()[0]
			#condiçao de lock da arma vem aqui
			barracks_units[im_b.get_selected_items()[0]].wpn_vector.append(a_wpn)
			im_bw.add_item("", load(str("res://resources/sprites/weapons/",a_wpn.name,".tex")), 1)
			im_bw.set_item_tooltip(im_apw.get_item_count(), a_wpn.name)
			active_units[im_ap.get_selected_items()[0]].wpn_vector.remove(a_local_wpn_id)
			im_apw.remove_item(a_local_wpn_id)
		# Only Barracks unit weapon selected
		if (im_apw.get_selected_items().size() == 0 and im_bw.get_selected_items().size() != 0):
			var b_unit = barracks_units[im_b.get_selected_items()[0]]
			var b_wpn = b_unit.wpn_vector[im_bw.get_selected_items()[0]]
			var b_local_wpn_id = im_bw.get_selected_items()[0]

			active_units[im_ap.get_selected_items()[0]].wpn_vector.append(b_wpn)
			im_apw.add_item("", load(str("res://resources/sprites/weapons/",b_wpn.name,".tex")), 1)
			im_apw.set_item_tooltip(im_apw.get_item_count(), b_wpn.name)
			barracks_units[im_b.get_selected_items()[0]].wpn_vector.remove(b_local_wpn_id)
			im_bw.remove_item(b_local_wpn_id)
	# Storage management
	else:
		# Active and Storage weapons selected
		if (im_apw.get_selected_items().size() != 0 and im_stw.get_selected_items().size() != 0):
			var a_unit = active_units[im_ap.get_selected_items()[0]]
			var a_wpn = a_unit.wpn_vector[im_apw.get_selected_items()[0]]
			var a_local_wpn_id = im_apw.get_selected_items()[0]
			var st_wpn = storage_weapons[im_stw.get_selected_items()[0]]
			var st_local_wpn_id = im_stw.get_selected_items()[0]

			active_units[im_ap.get_selected_items()[0]].wpn_vector.append(st_wpn)
			im_apw.add_item("", load(str("res://resources/sprites/weapons/",st_wpn.name,".tex")), 1)
			im_apw.set_item_tooltip(im_apw.get_item_count() - 1, st_wpn.name)
			storage_weapons.append(a_wpn)
			im_stw.add_item("", load(str("res://resources/sprites/weapons/",a_wpn.name,".tex")), 1)
			im_stw.set_item_tooltip(im_apw.get_item_count() - 1, a_wpn.name)
			active_units[im_ap.get_selected_items()[0]].wpn_vector.remove(a_local_wpn_id)
			im_apw.remove_item(a_local_wpn_id)
			storage_weapons.remove(st_local_wpn_id)
			im_stw.remove_item(st_local_wpn_id)
			
		# Only Active unit weapon selected
		if (im_apw.get_selected_items().size() != 0 and im_stw.get_selected_items().size() == 0):
			var a_unit = active_units[im_ap.get_selected_items()[0]]
			var a_wpn = a_unit.wpn_vector[im_apw.get_selected_items()[0]]
			var a_local_wpn_id = im_apw.get_selected_items()[0]

			storage_weapons.append(a_wpn)
			im_stw.add_item("", load(str("res://resources/sprites/weapons/",a_wpn.name,".tex")), 1)
			im_stw.set_item_tooltip(im_apw.get_item_count(), a_wpn.name)
			active_units[im_ap.get_selected_items()[0]].wpn_vector.remove(a_local_wpn_id)
			im_apw.remove_item(a_local_wpn_id)
		# Only Storage weapon selected
		if (im_apw.get_selected_items().size() == 0 and im_stw.get_selected_items().size() != 0):
			var st_wpn = storage_weapons[im_stw.get_selected_items()[0]]
			var st_local_wpn_id = im_stw.get_selected_items()[0]

			active_units[im_ap.get_selected_items()[0]].wpn_vector.append(st_wpn)
			im_apw.add_item("", load(str("res://resources/sprites/weapons/",st_wpn.name,".tex")), 1)
			im_apw.set_item_tooltip(im_apw.get_item_count(), st_wpn.name)
			storage_weapons.remove(st_local_wpn_id)
			im_stw.remove_item(st_local_wpn_id)

func _on_SwapItems_pressed():
	if (item_swap_mode == 0):
		# Active and Barracks items selected
		if (im_api.get_selected_items().size() != 0 and im_bi.get_selected_items().size() != 0):
			var a_unit = active_units[im_ap.get_selected_items()[0]]
			var a_item = a_unit.item_vector[im_api.get_selected_items()[0]]
			var a_local_item_id = im_api.get_selected_items()[0]
			var b_unit = barracks_units[im_b.get_selected_items()[0]]
			var b_item = b_unit.item_vector[im_bi.get_selected_items()[0]]
			var b_local_item_id = im_bi.get_selected_items()[0]

			active_units[im_ap.get_selected_items()[0]].item_vector.append(b_item)
			im_api.add_item("", load(str("res://resources/sprites/items/",b_item.name,".tex")), 1)
			im_api.set_item_tooltip(im_api.get_item_count() - 1, b_item.name)
			barracks_units[im_b.get_selected_items()[0]].item_vector.append(a_item)
			im_bi.add_item("", load(str("res://resources/sprites/items/",a_item.name,".tex")), 1)
			im_bi.set_item_tooltip(im_api.get_item_count() - 1, a_item.name)
			active_units[im_ap.get_selected_items()[0]].item_vector.remove(a_local_item_id)
			im_api.remove_item(a_local_item_id)
			barracks_units[im_b.get_selected_items()[0]].item_vector.remove(b_local_item_id)
			im_bi.remove_item(b_local_item_id)
			
		# Only Active unit item selected
		if (im_api.get_selected_items().size() != 0 and im_bi.get_selected_items().size() == 0):
			var a_unit = active_units[im_ap.get_selected_items()[0]]
			var a_item = a_unit.item_vector[im_api.get_selected_items()[0]]
			var a_local_item_id = im_api.get_selected_items()[0]

			barracks_units[im_b.get_selected_items()[0]].item_vector.append(a_item)
			im_bi.add_item("", load(str("res://resources/sprites/items/",a_item.name,".tex")), 1)
			im_bi.set_item_tooltip(im_api.get_item_count(), a_item.name)
			active_units[im_ap.get_selected_items()[0]].item_vector.remove(a_local_item_id)
			im_api.remove_item(a_local_item_id)
		# Only Barracks unit item selected
		if (im_api.get_selected_items().size() == 0 and im_bi.get_selected_items().size() != 0):
			var b_unit = barracks_units[im_b.get_selected_items()[0]]
			var b_item = b_unit.item_vector[im_bi.get_selected_items()[0]]
			var b_local_item_id = im_bi.get_selected_items()[0]

			active_units[im_ap.get_selected_items()[0]].item_vector.append(b_item)
			im_api.add_item("", load(str("res://resources/sprites/items/",b_item.name,".tex")), 1)
			im_api.set_item_tooltip(im_api.get_item_count(), b_item.name)
			barracks_units[im_b.get_selected_items()[0]].item_vector.remove(b_local_item_id)
			im_bi.remove_item(b_local_item_id)
	# Storage management
	else:
		# Active and Storage items selected
		if (im_api.get_selected_items().size() != 0 and im_sti.get_selected_items().size() != 0):
			var a_unit = active_units[im_ap.get_selected_items()[0]]
			var a_item = a_unit.item_vector[im_api.get_selected_items()[0]]
			var a_local_item_id = im_api.get_selected_items()[0]
			var st_item = storage_items[im_sti.get_selected_items()[0]]
			var st_local_item_id = im_sti.get_selected_items()[0]

			active_units[im_ap.get_selected_items()[0]].item_vector.append(st_item)
			im_api.add_item("", load(str("res://resources/sprites/items/",st_item.name,".tex")), 1)
			im_api.set_item_tooltip(im_api.get_item_count() - 1, st_item.name)
			storage_items.append(a_item)
			im_sti.add_item("", load(str("res://resources/sprites/items/",a_item.name,".tex")), 1)
			im_sti.set_item_tooltip(im_api.get_item_count() - 1, a_item.name)
			active_units[im_ap.get_selected_items()[0]].item_vector.remove(a_local_item_id)
			im_api.remove_item(a_local_item_id)
			storage_items.remove(st_local_item_id)
			im_sti.remove_item(st_local_item_id)
			
		# Only Active unit item selected
		if (im_api.get_selected_items().size() != 0 and im_sti.get_selected_items().size() == 0):
			var a_unit = active_units[im_ap.get_selected_items()[0]]
			var a_item = a_unit.item_vector[im_api.get_selected_items()[0]]
			var a_local_item_id = im_api.get_selected_items()[0]

			storage_items.append(a_item)
			im_sti.add_item("", load(str("res://resources/sprites/items/",a_item.name,".tex")), 1)
			im_sti.set_item_tooltip(im_api.get_item_count(), a_item.name)
			active_units[im_ap.get_selected_items()[0]].item_vector.remove(a_local_item_id)
			im_api.remove_item(a_local_item_id)
		# Only Storage item selected
		if (im_api.get_selected_items().size() == 0 and im_sti.get_selected_items().size() != 0):
			var st_item = storage_items[im_sti.get_selected_items()[0]]
			var st_local_item_id = im_sti.get_selected_items()[0]

			active_units[im_ap.get_selected_items()[0]].item_vector.append(st_item)
			im_api.add_item("", load(str("res://resources/sprites/items/",st_item.name,".tex")), 1)
			im_api.set_item_tooltip(im_api.get_item_count(), st_item.name)
			storage_items.remove(st_local_item_id)
			im_sti.remove_item(st_local_item_id)
		

func _on_StorageBarracks_pressed():
	if (item_swap_mode == 0):
		im_b.hide()
		im_bw.hide()
		im_bi.hide()
		im_stw.show()
		im_sti.show()
		
		for item in im_b.get_selected_items():
			im_b.unselect(item)
		im_bw.clear()
		im_bi.clear()
		last_selected_barracks = -1
		item_swap_mode = 1
		
		im_bws.neutralize_node("Item Status")
		im_bis.neutralize_node("Item Status")
	else:
		im_b.show()
		im_bw.show()
		im_bi.show()
		im_stw.hide()
		im_sti.hide()
		
		for weapon in im_stw.get_selected_items():
			im_stw.unselect(weapon)
		for item in im_sti.get_selected_items():
			im_sti.unselect(item)
		item_swap_mode = 0
		
		im_bws.neutralize_node("Item Status")
		im_bis.neutralize_node("Item Status")


# ####################################### #
# ##### REPAIR MENU BUTTON FUNCTIONS #### # 
# ####################################### #

# Note que falta implementar o uso de currency
# nestas funções. Falta bug testing para conferir
# se ele esta trabalhando corretamente com as condições limitantes.

func _on_RepairWeapon_pressed():
	var price
	var weapon

	if (last_selected_type == 0):
		weapon = active_units[rm_ap.get_selected_items()[0]].wpn_vector[rm_w.get_selected_items()[0]]
		price = (wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50
		get_parent().quesha -= price
		rm_cq.set_text(str("  Current: ", get_parent().quesha))
		weapon.durability = wpn_database.get_durability(weapon.id)
	else:
		weapon = barracks_units[rm_b.get_selected_items()[0]].wpn_vector[rm_w.get_selected_items()[0]]
		price = (wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50
		get_parent().quesha -= price
		rm_cq.set_text(str("  Current: ", get_parent().quesha))
		weapon.durability = wpn_database.get_durability(weapon.id)# Condições de preço vem aqui
		
func _on_RepairAll_pressed():
	var price
	if (rm_ap.get_selected_items().size() != 0):
		price = 0
		for weapon in active_units[rm_ap.get_selected_items()[0]].wpn_vector:
			price += (wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50
			weapon.durability = wpn_database.get_durability(weapon.id)
		get_parent().quesha -= price
		rm_cq.set_text(str("  Current: ", get_parent().quesha))
	if (rm_b.get_selected_items().size() != 0):
		price = 0
		for weapon in barracks_units[rm_b.get_selected_items()[0]].wpn_vector:
			price += (wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50
			weapon.durability = wpn_database.get_durability(weapon.id)
		get_parent().quesha -= price
		rm_cq.set_text(str("  Current: ", get_parent().quesha))

func _on_RepairAll_mouse_enter():
	var price
	if (rm_ap.get_selected_items().size() != 0):
		price = 0
		for weapon in active_units[rm_ap.get_selected_items()[0]].wpn_vector:
			price += (wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50
		get_node("RepairMenu/RepairAllPrice").set_text(str("  Price: ", price))
		get_node("RepairMenu/RepairAllPrice").show()
	if (rm_b.get_selected_items().size() != 0):
		price = 0
		for weapon in barracks_units[rm_b.get_selected_items()[0]].wpn_vector:
			price += (wpn_database.get_durability(weapon.id) - weapon.durability) * wpn_database.get_price(weapon.id)/50
		get_node("RepairMenu/RepairAllPrice").set_text(str("  Price: ", price))
		get_node("RepairMenu/RepairAllPrice").show()

func _on_RepairAll_mouse_exit():
	get_node("RepairMenu/RepairAllPrice").hide()


# ####################################### #
# ##### SHOP MENU BUTTON FUNCTIONS #### # 
# ####################################### #

func _on_BuyMenu_pressed():
	current_screen = "ShopManagement"
	get_node("ShopKeeperContainer").neutralize_dialog()
	get_node("ShopMenu").hide()
	bonfire.set_opacity(0)
	sm_cqb.set_text(str("  Current: ", get_parent().quesha))
	get_node(current_screen).show()

func _on_SellMenu_pressed():
	current_screen = "SellManagement"
	get_node("ShopKeeperContainer").neutralize_dialog()
	get_node("ShopMenu").hide()
	bonfire.set_opacity(0)
	sm_cqs.set_text(str("  Current: ", get_parent().quesha))
	get_node(current_screen).show()
	
func _on_TalkMenu_pressed():
	get_node("ShopKeeperContainer").generate_dialog(get_parent().stage)

func _on_Buy_pressed():
	# Teremos o id de todas as armas selecionadas, aqui
		
	# Checa a soma dos preços DAS ARMAS aqui, que estarão na database,
	# e possívelmente gera uma mensagem de confirmação.
	# (Se a pessoa disser sim, e não tiver dinheiro, nega ela
	#  mesmo apertando o botão)
	var id
	var iter
	var sw_selected = null
	var si_selected = null
	
	if (sm_sw.get_selected_items().size() != 0):
		iter = 0
		id = wpn_shop_availability[floor(get_parent().stage / 2)][sm_sw.get_selected_items()[0]]
		sw_selected = sm_sw.get_selected_items()[0]
		# Decrementa dinheiro
		get_parent().quesha -= wpn_database.get_price(id) * wpn_amount
		# Fornece armas
		while (iter < wpn_amount):
			var wpn_instance = weapon.new()
			wpn_instance.id = id
			wpn_instance.name = wpn_database.get_wpn_name(id)
			wpn_instance.durability = wpn_database.get_durability(id)
			wpn_instance.type = wpn_database.get_wpn_type(id)
			storage_weapons.append(wpn_instance)
			iter += 1
	
	if (sm_si.get_selected_items().size() != 0):
		iter = 0
		id = item_shop_availability[floor(get_parent().stage / 2)][sm_si.get_selected_items()[0]]
		si_selected = sm_si.get_selected_items()[0]
		# Decrementa dinheiro
		get_parent().quesha -= item_database.get_price(id) * item_amount
		# Fornece items
		while (iter < item_amount):
			var item_instance = item.new(item_database.get_item_name(id), 3, item_database) # <-- Total amount == 3 is only a placeholder
			storage_items.append(item_instance)
			iter += 1
			
	sm_cqb.set_text(str("  Current: ", get_parent().quesha))
	sfx.play("Transaction")
	
	# Faremos uma checagem antes de concretizar a compra,
	# por isso estar neutralizações ficarem separadas é importante
	wpn_amount = 0
	item_amount = 0
	if (sw_selected != null):
		sm_sw.unselect(sw_selected)
	if (si_selected != null):
		sm_si.unselect(si_selected)

func _on_Sell_pressed():
	# Precisa juntar o preço de venda dos dois selecionados
	var total_value = 0
	
	if (sm_stw.get_selected_items().size() != 0):
		# acumula o preço de venda aqui, remove
		get_parent().quesha += (wpn_database.get_price(storage_weapons[sm_stw.get_selected_items()[0]].id) / 2) * (storage_weapons[sm_stw.get_selected_items()[0]].durability / wpn_database.get_durability(storage_weapons[sm_stw.get_selected_items()[0]].id))
		storage_weapons.remove(sm_stw.get_selected_items()[0])
		sm_stw.remove_item(sm_stw.get_selected_items()[0])
		
	if (sm_sti.get_selected_items().size() != 0):
		# acumula o preço de venda aqui, remove
		get_parent().quesha += (item_database.get_price(storage_items[sm_sti.get_selected_items()[0]].id) / 2) * (storage_items[sm_sti.get_selected_items()[0]].amount) / item_database.get_item_stack((storage_items[sm_sti.get_selected_items()[0]].id))
		storage_items.remove(sm_sti.get_selected_items()[0])
		sm_sti.remove_item(sm_sti.get_selected_items()[0])
		
	sm_cqs.set_text(str("  Current: ", get_parent().quesha))
	sfx.play("Transaction")

func _on_Plus1_pressed():
	wpn_amount += 1


func _on_Minus1_pressed():
	if (wpn_amount > 0):
		wpn_amount -= 1


func _on_Plus2_pressed():
	item_amount += 1


func _on_Minus2_pressed():
	if (item_amount > 0):
		item_amount -= 1


# ################################ #
# ###### MENU FUNCTIONALITY ###### # 
# ################################ #


func _on_Units_pressed():
	get_node("Selection").hide()
	get_node("PartyMenu").show()
	bonfire.set_opacity(0)


func _on_Repair_pressed():
	current_screen = "RepairMenu"
	rm_cq.set_text(str("  Current: ", get_parent().quesha))
	get_node("Selection").hide()
	get_node(current_screen).show()
	bonfire.set_opacity(1)

func _on_Shop_pressed():
	current_screen = "ShopMenu"
	get_node("Selection").hide()
	get_node(current_screen).show()
	get_node("ShopKeeperContainer").show()
	bonfire.set_opacity(1)


func _on_ManageUnits_pressed():
	get_node("PartyMenu").hide()
	get_node("UnitManagement").show()
	bonfire.set_opacity(1)

	current_screen = "UnitManagement"

func _on_ManageItems_pressed():
	get_node("PartyMenu").hide()
	get_node("ItemManagement").show()
	bonfire.set_opacity(1)

	current_screen = "ItemManagement"

# Botão de retorno do submenu das unidades
func _on_Back_pressed():
	if (active_units.size() > 0):
		get_node("Selection/Play").set_disabled(false)
	else:
		get_node("Selection/Play").set_disabled(true)
	get_node("PartyMenu").hide()
	get_node("Selection").show()
	bonfire.set_opacity(0)
	
func _on_Back2_pressed():
	get_node("ShopMenu").hide()
	get_node("ShopKeeperContainer").neutralize_node()
	get_node("Selection").show()
	bonfire.set_opacity(0)
	
func _on_Back3_pressed():
	get_node("SelectStage").hide()
	get_node("Selection").show()
	ss_ps.set_pressed(false)
	ss_ns.set_pressed(false)
	ss_ps.set_ignore_mouse(false)
	ss_ns.set_ignore_mouse(false)
	get_node("SelectStage/PartyIndicator").set_pos(Vector2(get_node("SelectStage/PreviousLook").get_pos().x + 215, get_node("SelectStage/NextLook").get_pos().y))
	bonfire.set_opacity(0)

# Return tanto da Unit Management, quando da Item Management e do Repair Menu
func _on_Return_pressed():
	get_node(current_screen).hide()
	if (current_screen == "UnitManagement" or current_screen == "ItemManagement"):
		get_node("PartyMenu").show()
		bonfire.set_opacity(0)
		# Deselect when returning
		for unit in um_ap.get_selected_items():
			um_ap.unselect(unit)
		for unit in um_b.get_selected_items():
			um_b.unselect(unit)
		for item in im_ap.get_selected_items():
			im_ap.unselect(item)
		for item in im_b.get_selected_items():
			im_b.unselect(item)
		im_apw.clear()
		im_api.clear()
		im_bw.clear()
		im_bi.clear()
		last_selected_party = -1
		last_selected_barracks = -1
		
		#Neutralize information boxes
	
		um_aps.neutralize_node("Unit Status")
		um_bs.neutralize_node("Unit Status")
		last_selected_apunit = -1
		last_selected_bunit = -1

		#Neutralize start on ItemManagement screen
		item_swap_mode = 1
		populated_storage = 0
		im_stw.clear()
		im_sti.clear()
		_on_StorageBarracks_pressed()
	if (current_screen == "RepairMenu"):
		get_node("Selection").show()
		bonfire.set_opacity(0)
		for unit in rm_ap.get_selected_items():
			rm_ap.unselect(unit)
		for unit in rm_b.get_selected_items():
			rm_b.unselect(unit)
		rm_w.clear()
		last_selected_repair = -1
		last_selected_type = -1
		
		# Não precisa limpar a StatusBox, pois ela se limpa quando as
		# armas são deselecionadas, na saída da tela
	
	if (current_screen == "ShopManagement" or current_screen == "SellManagement"):
		for selection in sm_sw.get_selected_items():
			sm_sw.unselect(selection)
		for selection in sm_si.get_selected_items():
			sm_si.unselect(selection)
		
		sm_stw.clear()
		sm_sti.clear()
		populated_storage = 0
		
		current_screen = "ShopMenu"
		get_node("ShopMenu").show()
		bonfire.set_opacity(1)
		
		# Tratar depois de repopular, por conta do Sell, etc (vai precisar
		# colocar para atualizar nas funções de troca de unidades também)

func _on_Play_pressed():
	get_node("Selection").hide()
	get_node("SelectStage").show()
	bonfire.set_opacity(1)
	get_node("SelectStage/Begin").set_disabled(true)
	if (get_parent().stage == 0):
		ss_ps.set_disabled(true)
		ss_ns.set_disabled(false)
		get_node("SelectStage/NextLook").set_texture(load("res://resources/sprites/gui/map/forest1.tex"))
		get_node("SelectStage/NextText").set_text("Stage\n     0")
		# get_node("SelectStage/PartyIndicator").set_pos(Vector2(get_node("SelectStage/NextLook").get_pos().x, get_node("SelectStage/NextLook").get_pos().y))
	else:
		if (get_parent().stage - 1 <= 5):
			get_node("SelectStage/PreviousLook").set_texture(load("res://resources/sprites/gui/map/forest1.tex"))
			get_node("SelectStage/PreviousText").set_text(str("Stage\n     ", get_parent().stage - 1))
		if (get_parent().stage <= 5):
			get_node("SelectStage/NextLook").set_texture(load("res://resources/sprites/gui/map/forest1.tex"))
			get_node("SelectStage/NextText").set_text(str("Stage\n     ", get_parent().stage))
		# Placeholder
		else:
			get_node("SelectStage/PreviousLook").set_texture(load("res://resources/sprites/gui/map/forest1.tex"))
			get_node("SelectStage/PreviousText").set_text(str("Stage:\n     ", get_parent().stage - 1))
			get_node("SelectStage/NextLook").set_texture(load("res://resources/sprites/gui/map/forest1.tex"))
			get_node("SelectStage/NextText").set_text(str("Stage:\n     ", get_parent().stage))
	if (get_parent().stage == 5):
		ss_ns.set_disbled(true)
			
func _on_PreviousStage_pressed():
	# Tem que estar desabilitado se o level for 0
	ss_ps.set_ignore_mouse(true)
	ss_ns.set_ignore_mouse(false)
	ss_ns.set_pressed(false)
	get_node("SelectStage/Begin").set_disabled(false)
	get_node("SelectStage/PartyIndicator").set_pos(Vector2(get_node("SelectStage/PreviousLook").get_pos().x - 5, get_node("SelectStage/NextLook").get_pos().y))


func _on_NextStage_pressed():
	ss_ns.set_ignore_mouse(true)
	ss_ps.set_ignore_mouse(false)
	ss_ps.set_pressed(false)
	get_node("SelectStage/Begin").set_disabled(false)
	get_node("SelectStage/PartyIndicator").set_pos(Vector2(get_node("SelectStage/NextLook").get_pos().x - 4, get_node("SelectStage/NextLook").get_pos().y))


func _on_Begin_pressed():
	# Este codigo leva em consideração o aumento do stage na tranição do CombatNode
	if (ss_ps.is_pressed()):
		get_parent().gd = 1
		get_parent().stage -= 1
	else:
		get_parent().gd = 0
	get_parent().set_level("combat")


# Funções temporarias de teste
#BEGIN TEMPORARY SECTION
func instance_unit(id, level, path):
	var unit_instance = Unit.new()
	unit_instance.id = id
	unit_instance.name = char_database.get_char_name(id)
	unit_instance.level = level

	if path == "Party":
		active_units.append(unit_instance)
	elif path == "Barracks":
		barracks_units.append(unit_instance)

func instance_weapon(name, owner):
	
	var id = wpn_database.get_wpn_id(name)
	
	# Data instancing segment
	var wpn_instance = weapon.new()
	wpn_instance.id = id
	wpn_instance.name = name
	wpn_instance.durability = wpn_database.get_durability(id)
	wpn_instance.type = wpn_database.get_wpn_type(id)
	owner.wpn_vector.append(wpn_instance)
	
# owner is the reference in the correct vector (allies or enemies)
func instance_item(name, owner):
	var item_instance = item.new(name, 3, item_database) # <-- Total amount == 3 is only a placeholder
	owner.item_vector.append(item_instance)

#END TEMPORARY SECTION