extends Node

var lang = "en"

const _rocks_knocked = {
	"en" : "Rocks Knocked",
	"ar" : "الأحجار المسقطة"
}

const _throwing_remaining = {
	"en" : "Throwing Rocks Remaining",
	"ar" : "الأحجار الباقية للرمي"
}

const _endgame_messages = {
	"en" : ["This is disappointing.",
			"Decent, but better luck next time.",
			"Good job!",
			"Wow, incredible!",
			"You are a true Knock the Rock champion!"],
	"ar" : ["هذا مخيب للأمل.",
			"حسنا, لكن حظا اوفر في المرة القادمة.",
			"أحسنت!",
			"ممتاز!",
			"انت بطل \"أسقط الحجر\"!"]
}

const _score = {
	"en" : "Score",
	"ar" : "النتيجة"
}

const _mistake_messages = {
	"en" : ["Oops, replacing target",
			"We are experiencing technical difficulties",
			"Whoops, I got this this time",
			"Ok ok, this time for sure",
			"LOL sorry let me try one more time"],
	"ar" : ["لحظة! نحن نبدل الهدف",
			"عفوا, سنصحح الخطأ",
			"حسنا, هذه اخر مرة",
			"ههههه اخر مرة",
			"خخخخخخخخ"]
}

const _knocked = {
	"en" : "Knocked!",
	"ar" : "سقطت!"
}

const _cant_hold_target = {
	"en" : "No picking up the target rock!",
	"ar" : "لا تمسك الهدف!"
}

const _cant_hold_past_line = {
	"en" : "No picking up rocks beyond the line of pebbles!",
	"ar" : "لا تمسك الأحجار خلف خط الحصو!"
}

const _cant_hold_schwoop_rock = {
	"en" : "Let this rock go, it wants to be free.",
	"ar" : "إترك هذا الحجر, يريد ان يكون حر"
}

const _removing_obstructions = {
	"en" : "Removing obstructing rocks...",
	"ar" : "نشفط الأحجار المعيقة..."
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
	},
	"ar" : {
		"ktr title" : "أسقط\nالحجر",
		"sandbox btn" : "لعبة حرة",
		"challenge btn" : "إبدأ تحدي",
		"settings btn" : "الإعدادات",
		"help btn" : "مساعدة",
		"exit btn" : "خروج",
		"settings title" : "الإعدادات",
		"fullscreen" : "كبر النافذة",
		"music volume" : "صوت المسيقة",
		"gravity" : "جاذبية",
		"challenge mode rocks" : "عدد الأحجار في وضع التحدي",
		"corner menu hidden by default" : "إفترض إخفاء قائمة الزاوية",
		"language" : "اللغة",
		"apply btn" : "تطبيق",
		"back btn" : "عودة",
		"defaults btn" : "الإعدادات الإفتراضية",
		"help title" : "مساعدة",
		"hide help btn" : "خبء قائمة المساعدة (H)",
		"return btn" : "عد إلى القائمة الأصلية (Esc)",
		"restart btn" : "إبدأ من جديد (R)",
		"help btn corner menu" : "مساعدة (H)",
		"toggle corner menu lbl" : "خبء هذه القائمة (T)",
	}
}


func version_string() -> String:
	var version_info = Globals.get_version_info()
	
	# If the commit hash is an empty string, then we did not use the build script,
	# This puts "debug" on the version string
	if version_info["commit_hash"] == "":
		return version_info["version_number"] + "debug"
	
	# Now assuming the build script was used,
	# we display the commit hash if it's "dev" and we don't if it's "release"
	elif version_info["dev_or_release"] == "dev":
		return version_info["version_number"] + "dev" + version_info["commit_hash"]
	elif version_info["dev_or_release"] == "release":
		return version_info["version_number"]
	else:
		push_error("Strings.gd: Error generating version string.")
		return "[version string error]"


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

func cant_hold_schwoop_rock():
	return _cant_hold_schwoop_rock[lang]

func removing_obstructions():
	return _removing_obstructions[lang]

func ui_label(btn):
	return _ui_label[lang][btn]
