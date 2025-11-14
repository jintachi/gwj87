## The Singleton in charge of managing the Music of the game
extends Node

#region Declarations
@export var song_pool : Array[OstHolder]

var main_music_player : AudioStreamPlayer
var secondary_music_player : AudioStreamPlayer
var current_song : OstHolder
var current_time : float
var crossfade := false
#endregion

#region Setup
func _ready() -> void:
	setup_music_players()

func _process(delta: float) -> void:
	if current_song:
		if not current_song.can_loop:
			return
		
		if current_song.loop_vector.y == -1:
			var current_pos = main_music_player.get_playback_position()
			if current_pos >= current_song.ost_stream.get_length():
				play_song(current_song.ost_name, current_song.loop_vector.x)
		elif current_song.loop_vector.y != -1 and not crossfade:
			var current_pos = main_music_player.get_playback_position()
			if current_pos >= current_song.loop_vector.y:
				play_song(current_song.ost_name, current_song.loop_vector.x)

func load_music() -> void:
	pass

func setup_music_players() -> void:
	main_music_player = AudioStreamPlayer.new()
	main_music_player.bus = GenumHelper.BusName.get(Genum.BusID.OST)
	add_child(main_music_player)
	
	secondary_music_player = AudioStreamPlayer.new()
	secondary_music_player.bus = GenumHelper.BusName.get(Genum.BusID.OST)
	add_child(secondary_music_player)
#endregion

#region Usage Functions
func play_song(song_name: StringName, play_position: float = 0, crossover: bool = false) -> void:
	# TODO: Need to be able to loop the song as Yuvi describes, might need to change
	# how songs are loaded?
	current_song = _find_song(song_name)
	if not current_song:
		push_error("There's no song by the name %s in song_pool" % song_name)
		return
	
	if crossover:
		_crossover(song_name)
	else:
		main_music_player.stream = current_song.ost_stream
		main_music_player.play()

func _crossover(song_name: StringName, sfx_crossover := false) -> void:
	crossfade = true
	if !sfx_crossover:
		# Setup new song on secondary
		secondary_music_player.stream = _find_song(song_name).ost_stream
		secondary_music_player.volume_linear = 0
		secondary_music_player.play()
		
		# Create the crossover tween
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
		tween.tween_property(main_music_player, "volume_linear", 0, 1.0)
		tween.parallel().tween_property(secondary_music_player, "volume_linear", 1, 1.0)
		tween.tween_callback(func(): tween.kill)
		
		await tween.finished
		# Move from secondary to main
		main_music_player.stream = secondary_music_player.stream
		main_music_player.volume_linear = 1
		secondary_music_player.volume_linear = 0
		main_music_player.play(secondary_music_player.get_playback_position())
		secondary_music_player.stop()
		secondary_music_player.stream = null
	elif sfx_crossover:
		# fade our main track, play our SFX, then fade back in
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
		tween.tween_property(main_music_player, "volume_linear", 0, 5.0)
		await tween.finished
		SoundManager.play_sound(song_name)
		tween.tween_property(main_music_player, "volume_linear", 1, 5.0)
		await tween.finished
	
	crossfade = false

func play_jingle(sfx: StringName) -> void:
	# TODO: Need to crossfade with an ost to do the "jingle" that Yuvi needs
	if main_music_player.playing:
		_crossover(sfx, true)
	else : SoundManager.play_sound(sfx)

func stop_song() -> void:
	main_music_player.stop()
	current_song = null
#endregion

#region Helper Methods
func _find_song(ost_name: StringName) -> OstHolder:
	for ost in song_pool:
		if ost.ost_name == ost_name:
			return ost
	
	return null
#endregion
