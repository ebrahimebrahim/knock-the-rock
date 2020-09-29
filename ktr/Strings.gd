extends Node

var lang = "en"


const _rocks_knocked = {
	"en" : "Rocks Knocked"
}

const _throwing_remaining = {
	"en" : "Throwing Rocks Remaining"
}

const _endgame_messages = {
	"en" : ["This is disappointing.",
			"Decent, but better luck next time.",
			"Good job!",
			"Wow, incredible!",
			"You are a true Knock the Rock champion!"]
}

const _score = {
	"en" : "Score"
}

const _mistake_messages = {
	"en" : ["Oops, replacing target",
			"Whoops, I got this this time",
			"Ok ok, this time for sure",
			"LOL sorry let me try one more time",
			"We are experiencing technical difficulties"]
}

const _knocked = {
	"en" : "Knocked!"
}

const _cant_hold_target = {
	"en" : "No picking up the target rock!"
}

const _cant_hold_past_line = {
	"en" : "No picking up rocks beyond the line of pebbles!"
}

const _removing_obstructions = {
	"en" : "Removing obstructing rocks..."
}

const _ui_label = {
	"en" : {
		"ktr title" : "KNOCK\nTHE\nROCK",
		"sandbox btn" : "Sandbox",
		"challenge btn" : "Challenge",
		"settings btn" : "Settings",
		"help btn" : "Help",
		"exit btn" : "Exit",
		"settings title" : "Settings",
		"fullscreen" : "fullscreen",
		"music volume" : "music volume",
		"gravity" : "gravity",
		"challenge mode rocks" : "challenge mode rocks",
		"corner menu hidden by default" : "corner menu hidden by default",
		"language" : "language",
		"apply btn" : "Apply",
		"back btn" : "Back",
		"defaults btn" : "Restore Defaults",
		"help title" : "Help",
		"hide help btn" : "(H)ide Help",
		"return btn" : "Return to Menu (Esc)",
		"restart btn" : "(R)estart",
		"help btn corner menu" : "(H)elp",
		"toggle corner menu lbl" : "(T)oggle this Menu",
	}
}



func rocks_knocked(s):
	return _rocks_knocked[lang] + ": " + str(s)

func throwing_remaining(t):
	return _throwing_remaining[lang] + ": " + str(t) + "/" + str(Globals.total_rocks_given)

func endgame_message(score, total_rocks_given):
	var msg_index : int
	if total_rocks_given < len(_endgame_messages[lang]):
		# warning-ignore:narrowing_conversion
		msg_index = min(score,len(_endgame_messages[lang])-1)
	else:
		# warning-ignore:narrowing_conversion
		msg_index = min((float(score)/total_rocks_given)*(len(_endgame_messages[lang])-1),len(_endgame_messages[lang])-1)
	return _score[lang] + ": " + str(score) + "/" + str(total_rocks_given) + "\n"+ _endgame_messages[lang][msg_index] 

func mistake_message(mistakes_made):
	return _mistake_messages[lang][mistakes_made%len(_mistake_messages[lang])]

func knocked():
	return _knocked[lang]

func cant_hold_target():
	return _cant_hold_target[lang]
	
func cant_hold_past_line():
	return _cant_hold_past_line[lang]

func removing_obstructions():
	return _removing_obstructions[lang]

func ui_label(btn):
	return _ui_label[lang][btn]
