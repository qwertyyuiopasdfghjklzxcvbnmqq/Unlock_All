extends Node

var config = {
	"unlock_key": KEY_END,
	"enable_logs": true,
	"infinite_values": false
}

onready var TackleBox := $"/root/TackleBox"
var PlayerAPI
var KeybindsAPI

var ingame = false
var isOpen = false
var localPlayer

func _ready():

	while not get_node_or_null("/root/BlueberryWolfiAPIs/KeybindsAPI"):
		yield(get_tree(), "idle_frame")
	
	PlayerAPI = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")
	KeybindsAPI = get_node_or_null("/root/BlueberryWolfiAPIs/KeybindsAPI")
	
	var savedConfig = TackleBox.get_mod_config("Cry4pt.Unlock_All")
	for key in config.keys():
		if not savedConfig.has(key):
			savedConfig[key] = config[key]

	if typeof(savedConfig.unlock_key) == TYPE_STRING:
		savedConfig.unlock_key = OS.find_scancode_from_string(savedConfig.unlock_key)
	
	config = savedConfig.duplicate()
	TackleBox.set_mod_config("Cry4pt.Unlock_All", {
		"unlock_key": OS.get_scancode_string(config.unlock_key),
		"enable_logs": config.enable_logs,
		"infinite_values": config.infinite_values
	})
	emit_signal("mod_config_updated", config)
	
	if KeybindsAPI:
		KeybindsAPI.unregister_keybind("unlock_all")
		var toggleOpenKeybind = KeybindsAPI.register_keybind({
			"action_name": "unlock_all",
			"title": "Unlocks Everything In The Game",
			"key": config.unlock_key
		})
		KeybindsAPI.connect(toggleOpenKeybind + "_up", self, "_on_unlock_pressed")

	TackleBox.connect("mod_config_updated", self, "_ready")
	PlayerAPI.connect("_ingame", self, "onIngame")
	PlayerAPI.connect("_playeradded", self, "playerAdded")
	PlayerAPI.connect("_player_removed", self, "playerRemoved")

var prop_items = [
	"prop_picnic", "prop_canvas", "prop_bush", "prop_rock", "prop_fish_trap", "prop_fish_ocean",
	"prop_island_tiny", "prop_med", "prop_island_big", "prop_boombox", "prop_well",
	"prop_campfire", "prop_chair", "prop_chair", "prop_chair", "prop_chair", "prop_table",
	"prop_therapy_seat", "prop_toilet", "prop_whoopie", "prop_beer", "prop_greenscreen", "prop_portable_bait"
]

var achievement_ids = [
	"camp_tier_2", "camp_tier_3", "camp_tier_4", "catch_100_fish", "catch_single_fish", 
	"journal_normal", "journal_shining", "journal_glistening", "journal_opulent", "journal_radiant", "journal_alpha", 
	"rank_25", "rank_5", "rank_50", "10k_cash", "spectral_rod"
]

var tags = [
	"first_join",
	"journal_all",
	"journal_0", "journal_1", "journal_2", "journal_3", "journal_4", "journal_5",
	"spectral", "Cry4pt"   
]

var initialization_in_progress = false
var initialization_completed = true

func has_item_in_inventory(item_id):
	var item_count = 0
	for item in PlayerData.inventory:
		if item["id"] == item_id:
			item_count += 1
	return item_count > 0
	
func _local_chat_reset():
	Network._update_chat("", true)
	Network.LOCAL_GAMECHAT = ""
	Network.LOCAL_GAMECHAT_COLLECTIONS.clear()

func log_message(message):
	if config.enable_logs:
		Network._update_chat(message, true)
		
func _infinite_player_stats():
		PlayerData.badge_level = 50
		PlayerData.rod_power_level = 8
		PlayerData.rod_speed_level = 5
		PlayerData.rod_chance_level = 5
		PlayerData.rod_luck_level = 5
		PlayerData.buddy_level = 5
		PlayerData.buddy_speed = 5
		PlayerData.loan_level = 3
		PlayerData.max_bait = INF
		PlayerData.fish_caught = INF
		Network._update_stat("fish_caught", PlayerData.fish_caught)

func _infinite_progress_quests():
	for quest in PlayerData.current_quests:
		PlayerData.current_quests[quest]["progress"] = INF

func _infinite_complete_journal():
	for biome in PlayerData.VALID_JOURNAL_KEYS:
		if not PlayerData.journal_logs.has(biome):
			continue
		for fish_id in PlayerData.journal_logs[biome].keys():
			if not PlayerData.journal_logs[biome].has(fish_id):
				PlayerData.journal_logs[biome][fish_id] = {}
				
			PlayerData.journal_logs[biome][fish_id] = {
				"quality": [0, 1, 2, 3, 4, 5],
				"count": INF,
				"record": INF
			}

func _infinite_complete_final_quests():
	var attempts = 0
	while PlayerData.current_quests.size() > 0 && attempts < 31:
		for quest in PlayerData.current_quests.keys():
			Network.MESSAGE_COUNT_TRACKER.clear()
			PlayerData._complete_quest(quest)
			yield(get_tree().create_timer(0), "timeout")
		attempts += 1
	PlayerData.money = INF
	PlayerData.cash_total = PlayerData.money
	UserSave._save_general_save()

func _on_unlock_pressed():
	if initialization_completed and not initialization_in_progress:
		_local_chat_reset()
		log_message("[RUNNING]")
		_start_initialization()

func _start_initialization():
	initialization_in_progress = true
	initialization_completed = false
	yield(_obtain_tags(), "completed")
	yield(_player_stats(), "completed")
	yield(_progress_quests(), "completed")
	yield(_unlock_cosmetics(), "completed")
	yield(_unlock_baits_and_lures(), "completed")
	yield(_unlock_props_spectral(), "completed")
	yield(_complete_journal(), "completed")
	yield(_unlock_achievements(), "completed")
	yield(_complete_final_quests(), "completed")
	initialization_completed = true
	initialization_in_progress = false
	log_message("[COMPLETED]")

func _obtain_tags():
	for tag in tags:
		if not PlayerData.saved_tags.has(tag):
			PlayerData.saved_tags.append(tag)
	log_message("[TAGS OBTAINED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"

func _player_stats():
	if config.infinite_values:
		_infinite_player_stats()
		log_message("[PLAYER STATS UPDATED]")
		yield(get_tree().create_timer(0), "timeout")
		return "completed"
		
	PlayerData.badge_level = 50
	PlayerData.rod_power_level = 8
	PlayerData.rod_speed_level = 5
	PlayerData.rod_chance_level = 5
	PlayerData.rod_luck_level = 5
	PlayerData.buddy_level = 5
	PlayerData.buddy_speed = 5
	PlayerData.loan_level = 3
	PlayerData.max_bait = 50
	PlayerData.fish_caught = randi() % 1000000
	Network._update_stat("fish_caught", PlayerData.fish_caught)
	log_message("[PLAYER STATS UPDATED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"

func _progress_quests():
	if config.infinite_values:
		_infinite_progress_quests()
		log_message("[QUESTS PROGRESS MAXED]")
		yield(get_tree().create_timer(0), "timeout")
		return "completed"

	for quest in PlayerData.current_quests:
		PlayerData.current_quests[quest]["progress"] = 99999
	log_message("[QUESTS PROGRESS MAXED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"

func _unlock_cosmetics():
	for cosmetic in Globals.cosmetic_data:
		if not PlayerData.cosmetics_unlocked.has(cosmetic):
			PlayerData._unlock_cosmetic(cosmetic)
	log_message("[COSMETICS UNLOCKED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"

func _unlock_baits_and_lures():
	for bait in PlayerData.BAIT_DATA:
		if not PlayerData.bait_unlocked.has(bait):
			PlayerData.bait_unlocked.append(bait)
			PlayerData._refill_bait(bait, true)
	for lure in PlayerData.LURE_DATA:
		if not PlayerData.lure_unlocked.has(lure):
			PlayerData.lure_unlocked.append(lure)
	log_message("[BAITS & LURES UNLOCKED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"

func _unlock_props_spectral():
	var chair_count = 0
	for item in PlayerData.inventory:
		if item["id"] == "prop_chair":
			chair_count += 1
	for item in prop_items:
		if item == "prop_chair" and chair_count < 4:
			PlayerData._add_item(item)
			chair_count += 1
		elif not has_item_in_inventory(item):
			PlayerData._add_item(item)
	if not has_item_in_inventory("fishing_rod_skeleton"):
		PlayerData._add_item("fishing_rod_skeleton")
	log_message("[PROPS & SPECTRAL UNLOCKED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"

func _complete_journal():
	if config.infinite_values:
		_infinite_complete_journal()
		log_message("[JOURNAL COMPLETED]")
		yield(get_tree().create_timer(0), "timeout")
		return "completed"

	for biome in PlayerData.VALID_JOURNAL_KEYS:
		if not PlayerData.journal_logs.has(biome):
			continue
		for fish_id in PlayerData.journal_logs[biome].keys():
			if not PlayerData.journal_logs[biome].has(fish_id):
				PlayerData.journal_logs[biome][fish_id] = {}
				
			PlayerData.journal_logs[biome][fish_id] = {
				"quality": [0, 1, 2, 3, 4, 5],
				"count": randi() % 10000,
				"record": randi() % 10000
			}
	log_message("[JOURNAL COMPLETED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"

func _unlock_achievements():
	for achievement in achievement_ids:
		Network._unlock_achievement(achievement)
	log_message("[ACHIEVEMENTS UNLOCKED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"

func _complete_final_quests():
	if config.infinite_values:
		_infinite_complete_final_quests()
		log_message("[FINAL QUESTS COMPLETED]")
		yield(get_tree().create_timer(0), "timeout")
		return "completed"
		
	var attempts = 0
	while PlayerData.current_quests.size() > 0 && attempts < 31:
		for quest in PlayerData.current_quests.keys():
			Network.MESSAGE_COUNT_TRACKER.clear()
			PlayerData._complete_quest(quest)
			yield(get_tree().create_timer(0), "timeout")
		attempts += 1
	PlayerData.cash_total = PlayerData.money
	UserSave._save_general_save()
	log_message("[FINAL QUESTS COMPLETED]")
	yield(get_tree().create_timer(0), "timeout")
	return "completed"
