extends Node

# Config and data variables
var config = {
    "unlock_key": KEY_END,
    "stop_key": KEY_DELETE,
    "enable_logs": true,
    "enable_notifications": false,
    "infinite_values": false
}

var prop_items = [
	"prop_picnic", "prop_canvas", "prop_bush", "prop_rock", "prop_fish_trap", "prop_fish_ocean",
	"prop_island_tiny", "prop_med", "prop_island_big", "prop_boombox", "prop_well",
	"prop_campfire", "prop_chair", "prop_chair", "prop_chair", "prop_chair", "prop_table", "prop_therapy_seat", "prop_toilet", "prop_whoopie", 
	"prop_beer", "prop_greenscreen", "prop_portable_bait"
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

# State variables
var initialization_in_progress = false
var initialization_completed = true

# Command signals
signal start_initialization
signal stop
signal reset
signal clear
signal obtain_tags
signal player_stats
signal progress_quests
signal unlock_cosmetics
signal unlock_baits_lures
signal unlock_props_spectral
signal complete_journal
signal unlock_achievements
signal complete_quests
signal combine_quests
signal toggle_logs
signal toggle_notifications
signal set_infinite_values
signal set_unlock_key
signal set_stop_key

# Command signals
signal level
signal money
signal rod_power
signal rod_speed
signal rod_chance
signal rod_luck
signal buddy
signal buddy_speed
signal loan
signal max_bait
signal fish_caught

func _enter_tree():
    var node = get_node("/root/CommandsEx")
    
    # Register all commands
    node.register_command("start", "start_initialization", self, "start_initialization_command")
    node.register_command("stop", "stop", self, "stop_command")
    node.register_command("reset", "reset", self, "reset_command")
    node.register_command("clear", "clear", self, "clear_command")
    node.register_command("tags", "obtain_tags", self, "obtain_tags_command")
    node.register_command("stats", "player_stats", self, "player_stats_command")
    node.register_command("quests", "progress_quests", self, "progress_quests_command")
    node.register_command("cosmetics", "unlock_cosmetics", self, "unlock_cosmetics_command")
    node.register_command("baits", "unlock_baits_lures", self, "unlock_baits_lures_command")
    node.register_command("props", "unlock_props_spectral", self, "unlock_props_spectral_command")
    node.register_command("journal", "complete_journal", self, "complete_journal_command")
    node.register_command("achievements", "unlock_achievements", self, "unlock_achievements_command")
    node.register_command("complete_quests", "complete_quests", self, "complete_quests_command")
    node.register_command("combine_quests", "combine_quests", self, "combine_quests_command")
    node.register_command("logs", "toggle_logs", self, "toggle_logs_command")
    node.register_command("notifications", "toggle_notifications", self, "toggle_notifications_command")
    node.register_command("infinite", "set_infinite_values", self, "set_infinite_values_command")
    node.register_command("set_unlock", "set_unlock_key", self, "set_unlock_key_command")
    node.register_command("set_stop", "set_stop_key", self, "set_stop_key_command")

    # Register all commands
    node.register_command("level", "level", self, "level")
    node.register_command("money", "money", self, "money")
    node.register_command("rod_power", "rod_power", self, "rod_power")
    node.register_command("rod_speed", "rod_speed", self, "rod_speed")
    node.register_command("rod_chance", "rod_chance", self, "rod_chance")
    node.register_command("rod_luck", "rod_luck", self, "rod_luck")
    node.register_command("buddy", "buddy", self, "buddy")
    node.register_command("buddy_speed", "buddy_speed", self, "buddy_speed")
    node.register_command("loan", "loan", self, "loan")
    node.register_command("max_bait", "max_bait", self, "max_bait")
    node.register_command("fish_caught", "fish_caught", self, "fish_caught")

# Command implementations
func start_initialization_command(text, args):
    if initialization_completed and not initialization_in_progress:
        _local_chat_reset()
        log_message("[RUNNING]")
        _start_initialization()

func stop_command(text, args):
    _local_chat_reset()
    log_message("[STOPPED]")
    onClickClearCache()

func clear_command(text, args):
    _local_chat_reset()
    log_message("[CLEARED]")

func reset_command(text, args):
    PlayerData._reset_save()
    log_message("[RESET SAVE]")

func obtain_tags_command(text, args):
    _obtain_tags()

func player_stats_command(text, args):
    _player_stats()

func progress_quests_command(text, args):
    _progress_quests()

func unlock_cosmetics_command(text, args):
    _unlock_cosmetics()

func unlock_baits_lures_command(text, args):
    _unlock_baits_and_lures()

func unlock_props_spectral_command(text, args):
    _unlock_props_spectral()

func complete_journal_command(text, args):
    _complete_journal()

func unlock_achievements_command(text, args):
    _unlock_achievements()

func complete_quests_command(text, args):
    _complete_quests()

func combine_quests_command(text, args):
    _combine_quests()


func toggle_logs_command(text, args):
    if args.size() > 1:
        config.enable_logs = args[1].to_lower() in ["true", "on", "1"]
        log_message("Logs %s" % ("ENABLED" if config.enable_logs else "DISABLED"))
    else:
        log_message("Usage: logs <on/off>")

func toggle_notifications_command(text, args):
    if args.size() > 1:
        config.enable_notifications = args[1].to_lower() in ["true", "on", "1"]
        log_message("Notifications %s" % ("ENABLED" if config.enable_notifications else "DISABLED"))
    else:
        log_message("Usage: notifications <on/off>")

func set_infinite_values_command(text, args):
    if args.size() > 1:
        config.infinite_values = args[1].to_lower() in ["true", "on", "1"]
        log_message("Infinite values %s" % ("ENABLED" if config.infinite_values else "DISABLED"))
    else:
        log_message("Usage: infinite <on/off>")

func set_unlock_key_command(text, args):
    if args.size() > 1:
        var key = OS.find_scancode_from_string(args[1])
        if key != 0:
            config.unlock_key = key
            log_message("Unlock key set to: %s" % args[1])
        else:
            log_message("Invalid key name")

func set_stop_key_command(text, args):
    if args.size() > 1:
        var key = OS.find_scancode_from_string(args[1])
        if key != 0:
            config.stop_key = key
            log_message("Stop key set to: %s" % args[1])
        else:
            log_message("Invalid key name")

# Original functionality below (keep all existing methods from initial code)
func has_item_in_inventory(item_id):
    var item_count = 0
    for item in PlayerData.inventory:
        if item["id"] == item_id:
            item_count += 1
    return item_count > 0
    
func onClickClearCache():
    if is_instance_valid(_finapseScript):
        for child in _finapseScript.get_children():
            if child is CanvasLayer:
                continue
            child.queue_free()

func _local_chat_reset():
    Network._update_chat("", true)
    Network.LOCAL_GAMECHAT = ""
    Network.LOCAL_GAMECHAT_COLLECTIONS.clear()

func log_message(message):
    if config.enable_logs:
        Network._update_chat(message, true)

func notification_message(message):
    if config.enable_notifications:
        PlayerData._send_notification(message)

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

func _infinite_complete_quests():
    var attempts = 0
    while PlayerData.current_quests.size() > 0 and attempts < 31:
        for quest in PlayerData.current_quests.keys():
            Network.MESSAGE_COUNT_TRACKER.clear()
            PlayerData._complete_quest(quest)
            yield(get_tree().create_timer(0), "timeout")
        attempts += 1
    PlayerData.money = INF
    PlayerData.cash_total = PlayerData.money
    UserSave._save_general_save()

func _input(event):
    if event is InputEventKey and event.pressed:
        match event.scancode:
            config.unlock_key:
                if initialization_completed and not initialization_in_progress:
                    _local_chat_reset()
                    notification_message("[RUNNING]")
                    log_message("[RUNNING]")
                    _start_initialization()
            config.stop_key:
                _local_chat_reset()
                PlayerData._reset_save()
                notification_message("[STOPPED]")
                log_message("[STOPPED]")
                onClickClearCache()

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
    yield(_complete_quests(), "completed")
    initialization_completed = true
    initialization_in_progress = false
    notification_message("[COMPLETE]")
    log_message("[COMPLETE]")

func _obtain_tags():
    for tag in tags:
        if not PlayerData.saved_tags.has(tag):
            PlayerData.saved_tags.append(tag)
    notification_message("[TAGS UNLOCKED]")
    log_message("[TAGS UNLOCKED]")
    yield(get_tree().create_timer(0), "timeout")
    return "completed"

func _player_stats():
    if config.infinite_values:
        _infinite_player_stats()
    else:
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
    notification_message("[STATS UPDATED]")
    log_message("[STATS UPDATED]")
    yield(get_tree().create_timer(0), "timeout")
    return "completed"

func _progress_quests():
    if config.infinite_values:
        _infinite_progress_quests()
    else:
        for quest in PlayerData.current_quests:
            PlayerData.current_quests[quest]["progress"] = 99999
    notification_message("[QUESTS PROGRESSED]")
    log_message("[QUESTS PROGRESSED]")
    yield(get_tree().create_timer(0), "timeout")
    return "completed"

func _unlock_cosmetics():
    for cosmetic in Globals.cosmetic_data:
        if not PlayerData.cosmetics_unlocked.has(cosmetic):
            PlayerData._unlock_cosmetic(cosmetic)
    notification_message("[COSMETICS UNLOCKED]")
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
    notification_message("[BAITS/LURES UNLOCKED]")
    log_message("[BAITS/LURES UNLOCKED]")
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
    notification_message("[PROPS/SPECTRAL UNLOCKED]")
    log_message("[PROPS/SPECTRAL UNLOCKED]")
    yield(get_tree().create_timer(0), "timeout")
    return "completed"

func _complete_journal():
    if config.infinite_values:
        _infinite_complete_journal()
    else:
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
    notification_message("[JOURNAL COMPLETED]")
    log_message("[JOURNAL COMPLETED]")
    yield(get_tree().create_timer(0), "timeout")
    return "completed"

func _unlock_achievements():
    for achievement in achievement_ids:
        Network._unlock_achievement(achievement)
    notification_message("[ACHIEVEMENTS UNLOCKED]")
    log_message("[ACHIEVEMENTS UNLOCKED]")
    yield(get_tree().create_timer(0), "timeout")
    return "completed"

func _complete_quests():
    if config.infinite_values:
        _infinite_complete_quests()
    else:
        var attempts = 0
        while PlayerData.current_quests.size() > 0 and attempts < 31:
            for quest in PlayerData.current_quests.keys():
                Network.MESSAGE_COUNT_TRACKER.clear()
                PlayerData._complete_quest(quest)
                yield(get_tree().create_timer(0), "timeout")
            attempts += 1
        PlayerData.cash_total = PlayerData.money
        UserSave._save_general_save()
    notification_message("[QUESTS COMPLETED]")
    log_message("[QUESTS COMPLETED]")
    yield(get_tree().create_timer(0), "timeout")
    return "completed"

func _combine_quests():
    if config.infinite_values:
        _infinite_progress_quests()
        _infinite_complete_final_quests()
    else:
        var attempts = 0
        for quest in PlayerData.current_quests.keys():
            PlayerData.current_quests[quest]["progress"] = 99999

        while PlayerData.current_quests.size() > 0 and attempts < 31:
            for quest in PlayerData.current_quests.keys():
                Network.MESSAGE_COUNT_TRACKER.clear()
                PlayerData._complete_quest(quest)
                yield(get_tree().create_timer(0), "timeout")
            attempts += 1

        PlayerData.cash_total = PlayerData.money
        UserSave._save_general_save()
    
    notification_message("[QUESTS PROGRESSED & COMPLETED]")
    log_message("[QUESTS PROGRESSED & COMPLETED]")
    yield(get_tree().create_timer(0), "timeout")
    return "completed"

func level(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.badge_level = amount
        notification_message("[LEVEL] [%d]" % amount)
        log_message("[LEVEL] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: level <amount> - Provide a number to set level")

func money(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.money = amount
        notification_message("[MONEY] [%d]" % amount)
        log_message("[MONEY] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: money <amount> - Provide a number to set money")

func rod_power(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.rod_power_level = amount
        notification_message("[ROD POWER LEVEL] [%d]" % amount)
        log_message("[ROD POWER LEVEL] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: rod_power <amount> - Provide a number to set rod power level")

func rod_speed(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.rod_speed_level = amount
        notification_message("[ROD SPEED LEVEL] [%d]" % amount)
        log_message("[ROD SPEED LEVEL] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: rod_speed <amount> - Provide a number to set rod speed level")

func rod_chance(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.rod_chance_level = amount
        notification_message("[ROD CHANCE LEVEL] [%d]" % amount)
        log_message("[ROD CHANCE LEVEL] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: rod_chance <amount> - Provide a number to set rod chance level")

func rod_luck(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.rod_luck_level = amount
        notification_message("[ROD LUCK LEVEL] [%d]" % amount)
        log_message("[ROD LUCK LEVEL] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: rod_luck <amount> - Provide a number to set rod luck level")

func buddy(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.buddy_level = amount
        notification_message("[BUDDY LEVEL] [%d]" % amount)
        log_message("[BUDDY LEVEL] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: buddy <amount> - Provide a number to set buddy level")

func buddy_speed(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.buddy_speed = amount
        notification_message("[BUDDY SPEED] [%d]" % amount)
        log_message("[BUDDY SPEED] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: buddy_speed <amount> - Provide a number to set buddy speed")

func loan(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.loan_level = amount
        notification_message("[LOAN LEVEL] [%d]" % amount)
        log_message("[LOAN LEVEL] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: loan <amount> - Provide a number to set loan level")

func max_bait(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.max_bait = amount
        notification_message("[MAX BAIT] [%d]" % amount)
        log_message("[MAX BAIT] [%d]" % amount)
    else:
        PlayerData._send_notification("Usage: max_bait <amount> - Provide a number to set max bait")

func fish_caught(text, args):
    if args.size() > 1:
        var amount = int(args[1])
        PlayerData.fish_caught = amount
        notification_message("[FISH CAUGHT] [%d]" % amount)
        Network._update_stat("fish_caught", PlayerData.fish_caught)
        log_message("[FISH CAUGHT] [%d]" % amount )
    else:
        PlayerData._send_notification("Usage: fish_caught <amount> - Provide a number to set fish caught")
