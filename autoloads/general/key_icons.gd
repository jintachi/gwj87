class_name KeyIcons
const KEYS : Texture2D = preload("uid://kk25b3rbsav0")

static func add_tags(t: RichTextLabel, key: InputEvent) -> int:
	if key is InputEventKey: 
		match key.physical_keycode:
			KEY_TAB: return add_image(t, 0) + add_image(t, 1)
			KEY_1: return add_image(t, 2)
			KEY_2: return add_image(t, 3)
			KEY_3: return add_image(t, 4)
			KEY_4: return add_image(t, 5)
			KEY_5: return add_image(t, 6)
			KEY_6: return add_image(t, 7)
			KEY_7: return add_image(t, 8)
			KEY_8: return add_image(t, 9)
			KEY_9: return add_image(t, 10)
			KEY_0: return add_image(t, 11)
			# mouse
			KEY_CAPSLOCK: return add_image(t, 15) + add_image(t, 16)
			KEY_Q: return add_image(t, 17)
			KEY_W: return add_image(t, 18)
			KEY_E: return add_image(t, 19)
			KEY_R: return add_image(t, 20)
			KEY_T: return add_image(t, 21)
			KEY_Y: return add_image(t, 22)
			KEY_U: return add_image(t, 23)
			KEY_I: return add_image(t, 24)
			KEY_O: return add_image(t, 25)
			KEY_P: return add_image(t, 26)
			# gamepad d-pad
			KEY_SHIFT: return add_image(t, 30) + add_image(t, 31)
			KEY_A: return add_image(t, 32)
			KEY_S: return add_image(t, 33)
			KEY_D: return add_image(t, 34)
			KEY_F: return add_image(t, 35)
			KEY_G: return add_image(t, 36)
			KEY_H: return add_image(t, 37)
			KEY_J: return add_image(t, 38)
			KEY_K: return add_image(t, 39)
			KEY_L: return add_image(t, 40)
			KEY_CTRL: return add_image(t, 45) + add_image(t, 46)
			KEY_Z: return add_image(t, 47)
			KEY_X: return add_image(t, 48)
			KEY_C: return add_image(t, 49)
			KEY_V: return add_image(t, 50)
			KEY_B: return add_image(t, 51)
			KEY_N: return add_image(t, 52)
			KEY_M: return add_image(t, 53)
			KEY_UP: return add_image(t, 54)
			KEY_ALT: return add_image(t, 62) + add_image(t, 63)
			KEY_SPACE: return add_image(t, 64) + add_image(t, 65) + add_image(t, 66)
			KEY_LEFT: return add_image(t, 68)
			KEY_DOWN: return add_image(t, 69)
			KEY_RIGHT: return add_image(t, 70)
			KEY_ESCAPE: return add_image(t, 72) + add_image(t, 73)
		push_warning("Unhandled icon for keycode " + str(key.physical_keycode))
	elif key is InputEventJoypadButton:
		var device_name : String = Input.get_joy_name(key.device)
		match device_name:
			"Sony DualSense", \
			"PS5 Controller", \
			"PS4 Controller", \
			"Nacon Revolution Unlimited Pro Controller":
				match key.button_index:
					2: return add_image(t, 55)
					3: return add_image(t, 58)
					0: return add_image(t, 57)
					1: return add_image(t, 56)
		match key.button_index:
			2: return add_image(t, 75)
			3: return add_image(t, 76)
			0: return add_image(t, 77)
			1: return add_image(t, 78)
			9: return add_image(t, 83) + add_image(t, 84)
			10: return add_image(t, 85) + add_image(t, 86)
	push_warning("Unhandled icon for device " + str(key))
	return add_image(t, 71)

static func add_image(t: RichTextLabel, index: int) -> int:
	var w = 12
	var h = 12
	var x = (index * w) % 180
	var y = floori((index * w) / 180.0) * h
	var c = Color(1, 1, 1, 1)
	var key_name = str(index)
	t.add_image(KEYS, 0, 0, c, INLINE_ALIGNMENT_CENTER, Rect2(x, y, 12, 12), key_name, false, "", false, false, key_name)
	return 0
