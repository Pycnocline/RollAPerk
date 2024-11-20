extends Control

var buy_weapon_id = 0
var buy_weapon_name = ""
var buy_weapon_atk = 0
var buy_weapon_def = 0
var buy_weapon_spd = 0
var buy_perk_id = 0
var buy_perk_name = ""
var buy_perk_atk = 0
var buy_perk_def = 0
var buy_perk_spd = 0
var weaponlist = 0
var enemy_weapons = {}
var enemy_hp = 100
var enemy_current_hp = 100
var enemy_atk = 10
var enemy_current_atk = 10
var enemy_def = 0
var enemy_current_def = 0
var enemy_spd = 100
var enemy_current_spd = 100
var turn = 0
var action = 0
var text = ""
var enemy_weapon_count = 0
var get_coin = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$NextLevel.disabled = true
	battle_log("战斗开始了")
	$WeaponListBox.text = ""
	while weaponlist < Playerdata.player_weapon_count:
		weaponlist += 1
		$WeaponListBox.text += "[" + str(weaponlist) + "] " + Playerdata.player_weapons[weaponlist]["name"] + " atk:" + str(Playerdata.player_weapons[weaponlist]["atk"]) + " def:" + str(Playerdata.player_weapons[weaponlist]["def"]) + " spd:" + str(Playerdata.player_weapons[weaponlist]["spd"]) + "\n"
	
	# 敌方购买装备
	weaponlist = 0
	while weaponlist <= 5:
		buy_weapon_id = int(randi_range(1, RandomBase.weapon_count))
		buy_weapon_name = RandomBase.weapons[buy_weapon_id]["name"]
		buy_weapon_atk = int(RandomBase.weapons[buy_weapon_id]["atk"])
		buy_weapon_def = int(RandomBase.weapons[buy_weapon_id]["def"])
		buy_weapon_spd = int(RandomBase.weapons[buy_weapon_id]["spd"])
		buy_perk_id = int(randi_range(1, RandomBase.perk_count))
		buy_perk_name = RandomBase.perks[buy_perk_id]["name"]
		buy_perk_atk = int(RandomBase.perks[buy_perk_id]["atk"])
		buy_perk_def = int(RandomBase.perks[buy_perk_id]["def"])
		buy_perk_spd = int(RandomBase.perks[buy_perk_id]["spd"])
		enemy_weapons[weaponlist] = {
			"name" = buy_perk_name + buy_weapon_name,
			"atk" = buy_weapon_atk * buy_perk_atk,
			"def" = buy_weapon_def * buy_perk_def,
			"spd" = buy_weapon_spd * buy_perk_spd,
		}
		weaponlist += 1
		
	weaponlist = 0
	enemy_weapon_count = 5
	$EnemyWeaponListBox.text = ""
	while weaponlist < 5:
		weaponlist += 1
		$EnemyWeaponListBox.text += "[" + str(weaponlist) + "] " + enemy_weapons[weaponlist]["name"] + " atk:" + str(enemy_weapons[weaponlist]["atk"]) + " def:" + str(enemy_weapons[weaponlist]["def"]) + " spd:" + str(enemy_weapons[weaponlist]["spd"]) + "\n"
	
	# 初始化玩家血量
	Playerdata.player_current_hp = Playerdata.player_hp
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PlayerHPBar.value = max(0, Playerdata.player_current_hp)
	$EnemyHPBar.value = max(0, enemy_current_hp)


func _on_next_level_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/ready.tscn")

func battle_log(log:String):
	$BattleLog.text = log + "\n" + $BattleLog.text
	
func player_weapon_damage():
	# 玩家武器损坏
	if Playerdata.player_weapon_count > 0:
		Playerdata.player_weapon_count -= 1
	# 玩家武器更新
	weaponlist = 0
	$WeaponListBox.text = ""
	while weaponlist < Playerdata.player_weapon_count:
		weaponlist += 1
		$WeaponListBox.text += "[" + str(weaponlist) + "] " + Playerdata.player_weapons[weaponlist]["name"] + " atk:" + str(Playerdata.player_weapons[weaponlist]["atk"]) + " def:" + str(Playerdata.player_weapons[weaponlist]["def"]) + " spd:" + str(Playerdata.player_weapons[weaponlist]["spd"]) + "\n"

func enemy_weapon_damage():
	# 敌人武器损坏
	if enemy_weapon_count > 0:
		enemy_weapon_count -= 1
	# 敌人武器更新
	weaponlist = 0
	$EnemyWeaponListBox.text = ""
	while weaponlist < enemy_weapon_count:
		weaponlist += 1
		$EnemyWeaponListBox.text += "[" + str(weaponlist) + "] " + enemy_weapons[weaponlist]["name"] + " atk:" + str(enemy_weapons[weaponlist]["atk"]) + " def:" + str(enemy_weapons[weaponlist]["def"]) + " spd:" + str(enemy_weapons[weaponlist]["spd"]) + "\n"
	
func winning_judge():
	if Playerdata.player_weapon_count <= 0 and enemy_weapon_count <= 0:
		battle_log("双方都已耗尽武器，血量高者将获胜")
		if enemy_current_hp < Playerdata.player_current_hp:
			battle_log("敌方血量高，寄！")
		else:
			battle_log("你血量高，赢！")
			get_coin = max(0, randi_range(10, 25) - action)
			Playerdata.coin += get_coin
			text = "获得" + str(get_coin) + "金币！"
			battle_log(text)
			$NextLevel.disabled = false
		$Timer.stop()
	else:
		if Playerdata.player_current_hp <= 0:
			battle_log("你的血量低于0，寄！")
			$Timer.stop()
		elif enemy_current_hp <= 0:
			battle_log("敌方的血量低于0，赢！")
			get_coin = max(0, randi_range(10, 25) - action)
			Playerdata.coin += get_coin
			text = "获得" + str(get_coin) + "金币！"
			battle_log(text)
			$NextLevel.disabled = false
			$Timer.stop()
		
func _on_timer_timeout() -> void:
	turn += 1
	winning_judge()
	action += 1
	print(str(action))
	if turn == 1:	# 玩家装备武器
		if Playerdata.player_weapon_count > 0:
			text = "你装备了" + Playerdata.player_weapons[Playerdata.player_weapon_count]["name"]
			battle_log(text)
			Playerdata.player_current_atk = Playerdata.player_atk + Playerdata.player_weapons[Playerdata.player_weapon_count]["atk"]
			Playerdata.player_current_def = Playerdata.player_def + Playerdata.player_weapons[Playerdata.player_weapon_count]["def"]
			Playerdata.player_current_spd = Playerdata.player_spd + Playerdata.player_weapons[Playerdata.player_weapon_count]["spd"]
			text = "你目前的属性[atk,def,spd]：" + str(Playerdata.player_current_atk) + "|" + str(Playerdata.player_current_def) + "|" + str(Playerdata.player_current_spd)
			battle_log(text)

	if turn == 2:	# 敌人装备武器
		if enemy_weapon_count > 0:
			text = "敌人装备了" + enemy_weapons[enemy_weapon_count]["name"]
			battle_log(text)
			enemy_current_atk = enemy_atk + enemy_weapons[enemy_weapon_count]["atk"]
			enemy_current_def = enemy_def + enemy_weapons[enemy_weapon_count]["def"]
			enemy_current_spd = enemy_spd + enemy_weapons[enemy_weapon_count]["spd"]
			text = "敌人目前的属性[atk,def,spd]：" + str(enemy_current_atk) + "|" + str(enemy_current_def) + "|" + str(enemy_current_spd)
			battle_log(text)
			
	if turn == 3: # 对比速度并行动
		battle_log("速度鉴定！")
		if Playerdata.player_current_spd >= enemy_current_spd:
			battle_log("你先行动！")
			turn = 4
		else:
			battle_log("敌人先行动！")
			turn = 6
	if turn == 4:
		# 玩家行动
		battle_log("你的行动！")
		enemy_current_hp -= max(0,Playerdata.player_current_atk - enemy_current_def)
		text = "敌人目前的血量：" + str(enemy_current_hp)
		battle_log(text)
		player_weapon_damage()
		winning_judge()
		
	if turn == 5:
		# 敌人行动
		battle_log("敌人的行动！")
		Playerdata.player_current_hp -= max(0,enemy_current_atk - Playerdata.player_current_def)
		text = "你目前的血量：" + str(Playerdata.player_current_hp)
		battle_log(text)
		enemy_weapon_damage()
		winning_judge()
		turn = 0
		
	if turn == 6:
		# 敌人行动
		battle_log("敌人的行动！")
		Playerdata.player_current_hp -= max(0,enemy_current_atk - Playerdata.player_current_def)
		text = "你目前的血量：" + str(Playerdata.player_current_hp)
		battle_log(text)
		enemy_weapon_damage()
		winning_judge()
		
		
	if turn == 7:
		# 玩家行动
		battle_log("你的行动！")
		enemy_current_hp -= max(0,Playerdata.player_current_atk - enemy_current_def)
		text = "敌人目前的血量：" + str(enemy_current_hp)
		battle_log(text)
		player_weapon_damage()
		winning_judge()
		turn = 0
		
