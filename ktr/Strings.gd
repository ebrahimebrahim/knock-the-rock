extends Node

var lang = "en"


var _rocks_knocked = {
	"en" : "Rocks Knocked"
}

var _throwing_remaining = {
	"en" : "Throwing Rocks Remaining"
}

var _endgame_messages = {
	"en" : ["This is disappointing.",
			"Decent, but better luck next time.",
			"Good job!","Wow, incredible!",
			"You are a true Knock the Rock champion!"]
}

var _score = {
	"en" : "Score"
}

var _to_proceed = {
	"en" : "Restart or return to menu to proceed"
}

func rocks_knocked(s):
	return _rocks_knocked[lang] + ": " + str(s)

func throwing_remaining(t):
	return _throwing_remaining[lang] + ": " + str(t)

func endgame_message(score, total_rocks_given):
	var msg_index = min(int((float(score)/total_rocks_given)*(len(_endgame_messages[lang])-1)),len(_endgame_messages[lang])-1)
	return _score[lang] + ": " + str(score) + "\n\""+ _endgame_messages[lang][msg_index] + "\"\n" + _to_proceed[lang]



