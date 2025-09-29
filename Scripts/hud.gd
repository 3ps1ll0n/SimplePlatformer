extends CanvasLayer

@onready var player: CharacterBody2D = %Player
@onready var health_bar: TextureProgressBar = $HealthBar

const health_bar_size = 20 #Equivalent en HP du joueur

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.min_value = 0
	health_bar.max_value = player.get_max_health()
	health_bar.value = health_bar.max_value
	
	init_textures()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_bar.value = player.get_current_health()
	pass

func init_textures():
	var max_health = player.get_max_health()
	
	if max_health / health_bar_size == 1: # Si la barre de vie fait un seul segment
		health_bar.texture_under = load("res://Assets/HUD_Assets/LifeBarContainer_Single.png")
	
	elif max_health / health_bar_size >= 2: # Si elle est plus grande que 2 segments ou de 2 segments
		var life_bar_left_tex : Image = load("res://Assets/HUD_Assets/LifeBarContainer_Left.png").get_image()
		var life_bar_right_tex : Image = load("res://Assets/HUD_Assets/LifeBarContainer_Right.png").get_image()
		var life_bar_middle_tex : Image = load("res://Assets/HUD_Assets/LifeBarContainer_Middle.png").get_image()
		
		var middle_fragment_nbre : int = max_health / health_bar_size - 2
		
		# Ici on créer la texture de la barre de vie vide
		var canvas_under := Image.create(
			life_bar_left_tex.get_width() + (life_bar_middle_tex.get_width() * middle_fragment_nbre) + life_bar_right_tex.get_width(), life_bar_left_tex.get_height(), 
			false, 
			Image.FORMAT_RGBA8
		)
		canvas_under.fill(Color(0, 0, 0, 0))  # fully transparent
		
		canvas_under.blit_rect(
			life_bar_left_tex,
			Rect2i(Vector2i(0, 0), life_bar_left_tex.get_size()),
			Vector2i(0, 0)
		)
		
		var cursor : int = life_bar_left_tex.get_width()
		
		for i in range(middle_fragment_nbre): # On dessine les textures de barre du milieu
			canvas_under.blit_rect(
				life_bar_middle_tex,
				Rect2i(Vector2i(0, 0), life_bar_middle_tex.get_size()),
				Vector2i(cursor, 0)
			)
			cursor += life_bar_middle_tex.get_width()
		
		canvas_under.blit_rect(
			life_bar_right_tex,
			Rect2i(Vector2i(0, 0), life_bar_right_tex.get_size()),
			Vector2i(cursor, 0)
		)
		
		health_bar.texture_under = ImageTexture.create_from_image(canvas_under)
		
	#On calcule la taille de la jauge de vie
	health_bar.texture_progress = ImageTexture.create_from_image(get_health_progress_texture(max_health / health_bar_size))
		
func get_health_progress_texture(size: int) -> Image:
	var progress_bar_tex : Image = load("res://Assets/HUD_Assets/HealthBarProgress.png").get_image()
	
	# Les px a retirer correcpondent a ceux qu'on perd lors du chevauchement des cases de la barre de vie
	# Sans cette partie, l'affichage de la barre de vie n'est pas representatif de la vie reel du joueurs si sa vie est plus grande que une case de vie
	var px_to_remove = 0
	for i in range(size):
		px_to_remove += (2 * i)
	
	var canvas_progress := Image.create(progress_bar_tex.get_width() * size - px_to_remove, progress_bar_tex.get_height(), false,Image.FORMAT_RGBA8)
	
	canvas_progress.fill(Color(0, 0, 0, 0))  # fully transparent
	
	for i in range(size):
		canvas_progress.blit_rect(
			progress_bar_tex,
			Rect2i(Vector2i(0, 0), progress_bar_tex.get_size()),
			Vector2i(progress_bar_tex.get_width() * i - (2 * i), 0) #Le - (2 * i) sert a faire en sorte que le cases se desine legerement l'une sur l'autre (SINON BUG VISUEL)
		)
	return canvas_progress
