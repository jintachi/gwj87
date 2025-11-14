## This acts as a middle-layer where if I need strings, but want the consistency of Enums.
class_name GenumHelper

## Used to get the name of an Audio Bus based on its corresponding Enum in [class Genum]
const BusName : Dictionary[Genum.BusID, String] = {
	Genum.BusID.MASTER: &"Master",
	Genum.BusID.OST: &"OST",
	Genum.BusID.SFX: &"SFX",
	Genum.BusID.UI: &"UI",
	Genum.BusID.AMBIENT: &"Ambient"
}
