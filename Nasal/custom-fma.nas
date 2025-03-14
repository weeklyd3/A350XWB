# IT-AUTOFLIGHT V4.0.9 Custom FMA File
# Make sure you enable custom-fma in the config
# Copyright (c) 2024 Josh Davidson (Octal450)

var UpdateFma = {
	latText: "",
	thrText: "",
	vertText: "",
	latArmText: "",
	vertArmText: "",
	thr: func() { # Called when speed/thrust modes change
		me.thrText = {
			"SPEED": "SPEED",
			"MACH": "MACH",
			"IDLE": "THR IDLE",
			"RETARD": "THR IDLE",
			"THR LIM": "THR REF"
		}[Text.thr.getValue()];
	},
	arm: func() { # Called when armed modes change
		Output.lnavArm.getBoolValue();
		Output.locArm.getBoolValue();
		Output.gsArm.getBoolValue();
	},
	lat: func() { # Called when lateral mode changes
		me.latText = {
			"T/O": "RWY",
			"RLOU": "ROLL OUT",
			"HDG": "HDG",
			"ALGN": "FLARE",
			"LNAV": "NAV",
			"LOC": "LOC"
		}[Text.lat.getValue()];
	},
	vert: func() { # Called when vertical mode changes
		me.vertText = {
			"T/O CLB": "SRS",
			"ROLLOUT": "ROLL OUT",
			"ALT HLD": "ALT",
			"FPA": "FPA",
			"V/S": "V/S",
			"ALT CAP": "ALT*",
			"FLARE": "FLARE",
			"SPD CLB": "OP CLB",
			"SPD DES": "OP DES",
			"G/S": "G/S",
			"G/A CLB": "SRS"
		}[Text.vert.getValue()];
	},
};