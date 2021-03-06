# The sum of ATK, DEF, SPATK, SPDEF, DEX and LUK in lv. 20 is 420 blaze it no scope 360

extends Node

const FOLDER = 0
const CHAR_NAME = 1
const ANIM_ARRAY = 2
const HP = 3
const MP = 4
const ATK = 5
const DEF = 6
const SPATK = 7
const SPDEF = 8
const SPD = 9
const DEX = 10
const LUK = 11
const WPN_VECTOR = 12
const SKILL_VECTOR = 13


var char_database = [
	{ # ID = 0
		FOLDER : "res://characters/bat/",
		CHAR_NAME : "bat",
		ANIM_ARRAY : ["idle", "attack", "skillmagic"],
		# Max level: 20
		# 10 attribute points per level; 12 every 5 levels; level 20 is a huge boost
		# LV:    1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20
		HP :    [12, 14, 17, 21, 25, 27, 29, 31, 33, 37, 40, 43, 45, 47, 50, 52, 54, 56, 58, 60], # HP
		MP :    [5,  6,  7,  8,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25], # MP
		ATK :   [5,  8,  11, 14, 18, 21, 24, 27, 30, 34, 37, 40, 43, 46, 50, 53, 56, 59, 62, 66], # ATK
		SPATK : [0,  1,  2,  4,  4,  6,  7,  9,  11, 13, 14, 16, 18, 19, 21, 22, 23, 25, 27, 30], # SPATK
		DEF :   [2,  3,  4,  4,  6,  7,  8,  9,  10, 12, 13, 14, 16, 18, 20, 21, 22, 23, 24, 25], # DEF
		SPDEF : [0,  1,  2,  5,  5,  6,  7,  9,  10, 11, 12, 14, 16, 16, 18, 19, 20, 22, 23, 25], # SPDEF
		SPD :   [9,  11, 13, 15, 18, 21, 23, 24, 25, 27, 29, 30, 32, 34, 36, 38, 40, 41, 43, 45], # SPD
		DEX :   [3,  5,  7,  9,  12, 13, 16, 18, 20, 22, 24, 26, 27, 29, 30, 32, 34, 35, 37, 40], # DEX
		LUK :   [2,  4,  6,  7,  9,  10, 11, 12, 13, 14, 15, 16, 16, 17, 18, 19, 20, 22, 23, 25], # LUK
		WPN_VECTOR : ["Bat Fangs", "Bat Wings"],
		SKILL_VECTOR : ["Shadow Strike"]
	},
	
	{ # ID = 1
		FOLDER : "res://characters/samurai/",
		CHAR_NAME : "samurai",
		ANIM_ARRAY : ["idle", "idleSword", "attackSword", "skillmagic"],
		# Max level: 20
		# 12 attribute points per level; 15 every 5 levels; level 20 is a huge boost
		# LV:    1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20
		HP :    [15, 17, 20, 23, 28, 30, 33, 35, 38, 41, 44, 47, 50, 52, 56, 59, 61, 64, 66, 70], # HP
		MP :    [5,  6,  7,  8,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25], # MP
		ATK :   [5,  8,  10, 12, 16, 18, 20, 22, 24, 27, 29, 30, 32, 36, 39, 41, 44, 47, 49, 55], # ATK
		SPATK : [1,  2,  5,  6,  8,  11, 12, 13, 15, 17, 18, 20, 22, 23, 25, 27, 28, 29, 30, 33], # SPATK
		DEF :   [2,  4,  5,  7,  8,  9,  11, 12, 13, 15, 16, 18, 19, 20, 22, 23, 24, 25, 27, 30], # DEF
		SPDEF : [1,  2,  5,  7,  8,  9,  10, 11, 12, 14, 15, 17, 18, 19, 21, 23, 25, 27, 28, 30], # SPDEF
		SPD :   [5,  7,  8,  10, 12, 14, 16, 18, 21, 23, 26, 28, 30, 32, 35, 37, 39, 41, 43, 45], # SPD
		DEX :   [10, 12, 13, 14, 17, 18, 21, 24, 26, 28, 31, 33, 36, 38, 40, 42, 42, 44, 47, 50], # DEX
		LUK :   [1,  2,  3,  5,  7,  9,  10, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25], # LUK
		WPN_VECTOR : ["Katana", "Sword", "Sword", "Sword"],
		SKILL_VECTOR : ["Sonic Blow", "Sword Dance", "Agility"]
	},
	
	{ # ID = 2
		FOLDER : "res://characters/soldier/",
		CHAR_NAME : "soldier",
		ANIM_ARRAY : ["idle", "idleSword", "idleAxe", "idleSpear", "attackSword", "attackAxe", "attackSpear", "skillmagic"],
		# Max level: 20
		# 12 attribute points per level; 15 every 5 levels; level 20 is a huge boost
		# LV:    1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20
		HP :    [20, 25, 28, 30, 35, 38, 41, 44, 46, 50, 53, 55, 58, 60, 65, 68, 70, 72, 75, 80], # HP
		MP :    [10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 35], # MP
		ATK :   [5,  7,  8,  10, 11, 12, 13, 15, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 40], # ATK
		SPATK : [3,  6,  10, 12, 15, 17, 19, 21, 23, 27, 29, 32, 34, 36, 40, 42, 44, 46, 48, 53], # SPATK
		DEF :   [3,  6,  9, 11, 15, 20, 22, 24, 26, 28, 31, 33, 36, 39, 42, 45, 48, 51, 54, 60], # DEF
		SPDEF : [5,  7,  9,  11, 13, 15, 17, 19, 22, 24, 27, 29, 31, 33, 35, 37, 39, 41, 43, 47], # SPDEF
		SPD :   [4,  5,  6,  8,  9,  11, 13, 14, 16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 30], # SPD
		DEX :   [5,  6,  6,  7,  10, 11, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 30], # DEX
		LUK :   [1,  2,  3,  4,  5,  6,  7,  8,  9,  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20], # LUK
		WPN_VECTOR : ["Sword", "Spear", "Axe"],
		SKILL_VECTOR : ["Cure", "Heal Wave", "Guard", "Heal"]
	},
	
	{ # ID = 3
		FOLDER : "res://characters/baby_dragon/",
		CHAR_NAME : "baby_dragon",
		ANIM_ARRAY : ["idle", "attack", "skillmagic"],
		# Max level: 20
		# 15 attribute points per level; 18 every 5 levels; level 20 is a huge boost
		# LV:    1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20
		HP :    [23, 27, 30, 33, 40, 43, 46, 48, 50, 55, 58, 60, 62, 63, 67, 70, 73, 75, 78, 85], # HP
		MP :    [5,  6,  7,  8,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25], # MP
		ATK :   [5,  6,  7,  9,  10, 13, 15, 17, 18, 21, 24, 26, 29, 32, 35, 39, 42, 44, 47, 50], # ATK
		SPATK : [1,  3,  6,  9,  11, 13, 16, 19, 22, 26, 28, 30, 33, 35, 37, 40, 42, 45, 48, 55], # SPTAK
		DEF :   [5,  6,  7,  9,  14, 16, 18, 20, 22, 25, 28, 31, 34, 37, 40, 43, 46, 49, 52, 55], # DEF
		SPDEF : [1,  4,  5,  7,  10, 12, 15, 16, 19, 21, 24, 26, 28, 32, 35, 37, 40, 43, 45, 50], # SPDEF
		SPD :   [3,  5,  7,  9,  11, 13, 14, 16, 18, 20, 22, 23, 24, 26, 28, 30, 32, 34, 37, 40], # SPD
		DEX :   [3,  5,  7,  9,  11, 13, 15, 17, 18, 20, 23, 24, 25, 27, 30, 32, 34, 36, 38, 40], # DEX
		LUK :   [1,  2,  4,  5,  7,  9,  10, 12, 13, 15, 16, 18, 19, 20, 22, 23, 24, 25, 25, 25], # LUK
		WPN_VECTOR : ["Fangs", "Claws"],
		SKILL_VECTOR : ["Blast", "Eruption", "Slash"]
	},
	
	{ # ID = 4
		FOLDER : "res://characters/mage/",
		CHAR_NAME : "mage",
		ANIM_ARRAY : ["idle", "attack", "skillmagic"],
		# Max level: 20
		# 12 attribute points per level; 15 every 5 levels; level 20 is a huge boost
		# LV:    1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20
		HP :    [13, 15, 17, 20, 25, 28, 30, 32, 34, 38, 40, 42, 44, 46, 50, 52, 54, 56, 58, 63],
		MP :    [10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 35],
		ATK :   [3,  4,  6,  8,  10, 12, 14, 16, 18, 21, 23, 25, 27, 29, 32, 34, 36, 38, 40, 45],
		SPATK : [5,  8,  10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 40, 43, 47, 50, 53, 56, 59, 65],
		DEF :   [3,  5,  7,  8,  10, 12, 14, 16, 18, 21, 23, 25, 27, 29, 32, 34, 36, 38, 40, 45],
		SPDEF : [5,  8,  10, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 63],
		SPD :   [5,  6,  7,  9,  11, 11, 12, 13, 13, 14, 15, 15, 16, 17, 18, 19, 20, 21, 22, 25],
		DEX :   [5,  6,  8,  9,  11, 12, 12, 12, 13, 14, 14, 15, 16, 17, 18, 19, 20, 21, 22, 25],
		LUK :   [1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
		WPN_VECTOR : ["Book", "Book"],
		SKILL_VECTOR : ["Aqua Strike", "Aqua Blast", "Heal"]
	}
]


var cd_map = { }

func _ready():
	for id in range (char_database.size()):
		cd_map[char_database[id][CHAR_NAME]] = id

func get_char_id(name):
	return cd_map[name]

func get_char_folder(id):
	return char_database[id][FOLDER]

func get_char_name(id):
	return char_database[id][CHAR_NAME]

func get_animation_array(id):
	return char_database[id][ANIM_ARRAY]

func get_hp(id, level):
	return char_database[id][HP][level - 1]

func get_mp(id, level):
	return char_database[id][MP][level - 1]

func get_attack(id, level):
	return char_database[id][ATK][level - 1]
	
func get_defense(id, level):
	return char_database[id][DEF][level - 1]

func get_sp_attack(id, level):
	return char_database[id][SPATK][level - 1]

func get_sp_defense(id, level):
	return char_database[id][SPDEF][level - 1]

func get_speed(id, level):
	return char_database[id][SPD][level - 1]

func get_dexterity(id, level):
	return char_database[id][DEX][level - 1]

func get_luck(id, level):
	return char_database[id][LUK][level - 1]

func get_weapon_vector(id):
	return char_database[id][WPN_VECTOR]

func get_skill_vector(id):
	return char_database[id][SKILL_VECTOR]
