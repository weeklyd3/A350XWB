# IT-AUTOFLIGHT V4.0.9 Custom FMA File
# Make sure you enable custom-fma in the config
# Copyright (c) 2024 Josh Davidson (Octal450)

var loc_star = props.globals.initNode('/systems/pfd/loc-star', 0, 'BOOL');
var gs_star = props.globals.initNode('/systems/pfd/gs-star', 0, 'BOOL');

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
		if (Text.lat.getValue() == 'LOC') {
			loc_star.setBoolValue(1);
		}
		me.latText = {
			"T/O": "RWY",
			"RLOU": "ROLL OUT",
			"ROLLOUT": "ROLL OUT",
			"HDG": "HDG",
			"ALGN": "FLARE",
			"ALIGN": "FLARE",
			"LNAV": "NAV",
			"LOC": "LOC"
		}[Text.lat.getValue()];
	},
	vert: func() { # Called when vertical mode changes
		if (Text.vert.getValue() == 'G/S') {
			gs_star.setBoolValue(1);
		}
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
setlistener("/systems/fadec/throttle/max-throttle", func(throttle) {
	var thr = throttle.getValue();
	if (thr == 1) {
		itaf.ITAF.takeoffGoAround();
		itaf.ITAF.athrMaster(1);
	}
	if (thr == 0) itaf.ITAF.athrMaster(0);
}, 0, 0);