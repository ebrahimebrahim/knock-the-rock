extends Node

var lang = "en"


var _rocks_knocked = {
	"en" : "Rocks Knocked"
}

var _throwing_remaining = {
	"en" : "Throwing Rocks Remaining"
}


func rocks_knocked(s):
	return _rocks_knocked[lang] + ": " + str(s)

func throwing_remaining(t):
	return _throwing_remaining[lang] + ": " + str(t)
