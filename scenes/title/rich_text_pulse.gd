@tool
extends RichTextEffect
class_name RichTextPulse

# Syntax: [pulse freq=5.0 height=0.0 color=#ffffff88]...[/pulse]

var bbcode = "pulse"

func _process_custom_fx(char_fx: CharFXTransform):
	var freq = char_fx.env.get("freq", 5.0)
	var span = char_fx.env.get("span", 10.0)
	
	var alpha = (sin(char_fx.elapsed_time * freq + char_fx.range.x / span) + 1.0) / 2.0
	char_fx.color.a = lerp(0.1, 1.0, alpha)
	
	return true
