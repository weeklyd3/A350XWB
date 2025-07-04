# A3XX ND Canvas
# Copyright (c) 2020 Josh Davidson (Octal450)

io.include("A3XX_ND.nas");

io.include("A3XX_ND_drivers.nas");
canvas.NDStyles["Airbus"].options.defaults.route_driver = A3XXRouteDriver.new();

setprop("/systems/electrical/bus/ac-ess-shed", 111);
setprop("/systems/electrical/bus/ac2", 111);
setprop("/controls/lighting/DU/du2", 1);
setprop("/controls/lighting/DU/du5", 1);
setprop("/systems/acconfig/options/nd-rate", 2);
setprop("/systems/acconfig/autoconfig-running", 0);
var ND_1 = nil;
var ND_2 = nil;
var ND_1_test = nil;
var ND_2_test = nil;
var elapsedtime = 0;

# Fetch nodes:
foreach (var du; [1, 2, 3, 4, 5, 6]) {
	setprop("/instrumentation/du/du" ~ du ~ "-test", 0);
	setprop("/instrumentation/du/du" ~ du ~ "-test-time", 40);
	setprop("/instrumentation/du/du" ~ du ~ "-test-amount", -0.5);
}
setprop("/modes/fo-du-xfr", 0);
setprop("/modes/cpt-du-xfr", 0);
var du1_test = props.globals.getNode("/instrumentation/du/du1-test");
var du1_test_time = props.globals.getNode("/instrumentation/du/du1-test-time");
var du1_test_amount = props.globals.getNode("/instrumentation/du/du1-test-amount");
var du2_test = props.globals.getNode("/instrumentation/du/du2-test");
var du2_test_time = props.globals.getNode("/instrumentation/du/du2-test-time");
var du2_test_amount = props.globals.getNode("/instrumentation/du/du2-test-amount");
var du5_test = props.globals.getNode("/instrumentation/du/du5-test");
var du5_test_time = props.globals.getNode("/instrumentation/du/du5-test-time");
var du5_test_amount = props.globals.getNode("/instrumentation/du/du5-test-amount");
var du6_test = props.globals.getNode("/instrumentation/du/du6-test");
var du6_test_time = props.globals.getNode("/instrumentation/du/du6-test-time");
var du6_test_amount = props.globals.getNode("/instrumentation/du/du6-test-amount");
var cpt_du_xfr = props.globals.getNode("/modes/cpt-du-xfr");
var fo_du_xfr = props.globals.getNode("/modes/fo-du-xfr");
var wow0 = props.globals.getNode("/gear/gear[0]/wow");

var nd_display = {};

var ND = canvas.NavDisplay;

var myCockpit_switches = {
	"toggle_range": {path: "/inputs/range-nm", value:40, type:"INT"},
	"toggle_weather": {path: "/inputs/wxr", value:0, type:"BOOL"},
	"toggle_airports": {path: "/inputs/arpt", value:0, type:"BOOL"},
	"toggle_ndb": {path: "/inputs/NDB", value:0, type:"BOOL"},
	"toggle_stations": {path: "/inputs/sta", value:0, type:"BOOL"},
	"toggle_vor": {path: "/inputs/VORD", value:0, type:"BOOL"},
	"toggle_dme": {path: "/inputs/DME", value:0, type:"BOOL"},
	"toggle_cstr": {path: "/inputs/CSTR", value:0, type:"BOOL"},
	"toggle_waypoints": {path: "/inputs/wpt", value:0, type:"BOOL"},
	"toggle_position": {path: "/inputs/pos", value:0, type:"BOOL"},
	"toggle_data": {path: "/inputs/data",value:0, type:"BOOL"},
	"toggle_terrain": {path: "/inputs/terr",value:0, type:"BOOL"},
	"toggle_traffic": {path: "/inputs/tfc",value:0, type:"BOOL"},
	"toggle_centered": {path: "/inputs/nd-centered",value:0, type:"BOOL"},
	"toggle_lh_vor_adf": {path: "/input/lh-vor-adf",value:0, type:"INT"},
	"toggle_rh_vor_adf": {path: "/input/rh-vor-adf",value:0, type:"INT"},
	"toggle_display_mode": {path: "/nd/canvas-display-mode", value:"NAV", type:"STRING"},
	"toggle_display_type": {path: "/nd/display-type", value:"LCD", type:"STRING"},
	"toggle_true_north": {path: "/nd/true-north", value:0, type:"BOOL"},
	"toggle_track_heading": {path: "/trk-selected", value:0, type:"BOOL"},
	"toggle_wpt_idx": {path: "/inputs/plan-wpt-index", value: -1, type: "INT"},
	"toggle_plan_loop": {path: "/nd/plan-mode-loop", value: 0, type: "INT"},
	"toggle_weather_live": {path: "/nd/wxr-live-enabled", value: 0, type: "BOOL"},
	"toggle_chrono": {path: "/inputs/CHRONO", value: 0, type: "INT"},
	"toggle_xtrk_error": {path: "/nd/xtrk-error", value: 0, type: "BOOL"},
	"toggle_trk_line": {path: "/nd/trk-line", value: 0, type: "BOOL"},
};

var canvas_nd_base = {
	init: func(canvas_group, file = nil) {
		var font_mapper = func(family, weight) {
			return "ECAMFontRegular.ttf";
		};

		if (file != nil) {
			canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
			var svg_keys = me.getKeys();
			foreach(var key; svg_keys) {
				me[key] = canvas_group.getElementById(key);
			}
		}
		#canvas.parsesvg(canvas_group, "Aircraft/A350XWB/Models/Instruments/ND/canvas/res/vsd.svg", {"font-mapper": font_mapper});
		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		elapsedtime = getprop("/sim/time/elapsed-sec");
		if (getprop("/systems/electrical/bus/ac-ess-shed") >= 110) {
			if (wow0.getValue() == 1 and 0) { # eww dont want self test
				if (getprop("/systems/acconfig/autoconfig-running") != 1 and du2_test.getValue() != 1) {
					du2_test.setValue(1);
					du2_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
					du2_test_time.setValue(getprop("/sim/time/elapsed-sec"));
				} else if (getprop("/systems/acconfig/autoconfig-running") == 1 and du2_test.getValue() != 1) {
					du2_test.setValue(1);
					du2_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
					du2_test_time.setValue(getprop("/sim/time/elapsed-sec") - 30);
				}
			} else {
				du2_test.setValue(1);
				du2_test_amount.setValue(0);
				du2_test_time.setValue(-100);
			}
		} else {
			du2_test.setValue(0);
		}
		if (getprop("/systems/electrical/bus/ac2") >= 110) {
			if (wow0.getValue() == 1) {
				if (getprop("/systems/acconfig/autoconfig-running") != 1 and du5_test.getValue() != 1) {
					du5_test.setValue(1);
					du5_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
					du5_test_time.setValue(getprop("/sim/time/elapsed-sec"));
				} else if (getprop("/systems/acconfig/autoconfig-running") == 1 and du5_test.getValue() != 1) {
					du5_test.setValue(1);
					du5_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
					du5_test_time.setValue(getprop("/sim/time/elapsed-sec") - 30);
				}
			} else {
				du5_test.setValue(1);
				du5_test_amount.setValue(0);
				du5_test_time.setValue(-100);
			}
		} else {
			du5_test.setValue(0);
		}
		
		if (getprop("/systems/electrical/bus/dc-emer-1") >= 20 and getprop("/controls/lighting/DU/du2") > 0) {
			if (du2_test_time.getValue() + du2_test_amount.getValue() >= elapsedtime and cpt_du_xfr.getValue() != 1) {
				ND_1.page.hide();
				ND_1_test.page.show();
				ND_1_test.update();
			} else if (du1_test_time.getValue() + du1_test_amount.getValue() >= elapsedtime and cpt_du_xfr.getValue() == 1) {
				ND_1.page.hide();
				ND_1_test.page.show();
				ND_1_test.update();
			} else {
				ND_1_test.page.hide();
				ND_1.page.show();
				ND_1.NDCpt.update();
				ND_1.NDCpt.update_vd();
			}
		} else {
			ND_1_test.page.hide();
			ND_1.page.hide();
		}
		if (getprop("/systems/electrical/bus/dc-emer-2") >= 20 and getprop("/controls/lighting/DU/du5") > 0) {
			if (du5_test_time.getValue() + du5_test_amount.getValue() >= elapsedtime and fo_du_xfr.getValue() != 1) {
				ND_2.page.hide();
				ND_2_test.page.show();
				ND_2_test.update();
			} else if (du6_test_time.getValue() + du6_test_amount.getValue() >= elapsedtime and fo_du_xfr.getValue() == 1) {
				ND_2.page.hide();
				ND_2_test.page.show();
				ND_2_test.update();
			} else {
				ND_2_test.page.hide();
				ND_2.page.show();
				ND_2.NDFo.update();
				ND_2.NDFo.update_vd();
			}
		} else {
			ND_2_test.page.hide();
			ND_2.page.hide();
		}
	},
};
var vd_symbols = std.Vector.new(['alt_scale', 'current_alt', 'terrain_group']);
var vd_text = std.Vector.new([]);
for (var i = 1; i <= 14; i += 1) {
	vd_symbols.append('line_' ~ i);
	if (i == 1 or i == 3 or i == 5 or i == 7 or i == 9 or i == 11 or i == 13) {
		vd_symbols.append('text_' ~ i);
		vd_text.append('text_' ~ i);
	}
}
var canvas_ND_1 = {
	new: func(canvas_group) {
		var m = {parents: [canvas_ND_1, canvas_nd_base]};
		var font_mapper = func(doesnt, matter) { return "ECAMFontRegular.ttf"; };
		m.init(canvas_group);
		# here we make the ND:
		me.NDCpt = ND.new("instrumentation/efis", myCockpit_switches, "Airbus");
		me.NDCpt.newMFD(canvas_group);
		canvas.parsesvg(canvas_group, "Aircraft/A350XWB/Models/Instruments/ND/canvas/res/vsd.svg", {"font-mapper": font_mapper});
		me.group = canvas_group;
		m.group = canvas_group;
		foreach (var symbol; vd_symbols.vector) me.NDCpt.symbols["vd_" ~ symbol] = canvas_group.getElementById("vd_" ~ symbol);
		foreach (var symbol; vd_text.vector) {
			me.NDCpt.symbols["vd_" ~ symbol].enableUpdate();
		}
		me.NDCpt.symbols['vd_alt_scale'].set('clip', 'rect(1022, 229, 1273, 0)');
		me.NDCpt.vd_switches = {
			range: props.globals.getNode('/instrumentation/efis[0]/inputs/range-nm'),
			vd_range: props.globals.getNode('/instrumentation/efis/vd/horizontal-range'),
			vert_range: props.globals.getNode('/instrumentation/efis/vd/range'),
			altitude: props.globals.getNode('/instrumentation/altimeter/indicated-altitude-ft')
		};
		me.NDCpt.page = canvas_group;
		me.NDCpt.terrain_elements = [];

		foreach (var prop; ['horizontal-range', 'scale', 'low', 'tick-scale', 'low-displacement']) me.NDCpt.vd_switches[prop] = props.globals.getNode('/instrumentation/efis/vd/' ~ prop);
		me.NDCpt.update();

		print('HIII creating navigation display [left]');
		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {

	},
};

var canvas_ND_2 = {
	new: func(canvas_group) {
		var m = {parents: [canvas_ND_2, canvas_nd_base]};
		var font_mapper = func(doesnt, matter) { return "ECAMFontRegular.ttf"; };
		m.init(canvas_group);

		# here we make the ND:
		me.NDFo = ND.new("instrumentation/efis[1]", myCockpit_switches, "Airbus");
		me.NDFo.newMFD(canvas_group);
		me.NDFo.is_fo = 1;
		canvas.parsesvg(canvas_group, "Aircraft/A350XWB/Models/Instruments/ND/canvas/res/vsd.svg", {"font-mapper": font_mapper});
		me.group = canvas_group;
		m.group = canvas_group;
		foreach (var symbol; vd_symbols.vector) me.NDFo.symbols["vd_" ~ symbol] = canvas_group.getElementById("vd_" ~ symbol);
		foreach (var symbol; vd_text.vector) {
			me.NDFo.symbols["vd_" ~ symbol].enableUpdate();
		}
		me.NDFo.symbols['vd_alt_scale'].set('clip', 'rect(1022, 229, 1273, 0)');
		me.NDFo.vd_switches = {
			range: props.globals.getNode('/instrumentation/efis[0]/inputs/range-nm'),
			vd_range: props.globals.getNode('/instrumentation/efis/vd/horizontal-range'),
			vert_range: props.globals.getNode('/instrumentation/efis/vd/range'),
			altitude: props.globals.getNode('/instrumentation/altimeter/indicated-altitude-ft')
		};
		foreach (var prop; ['horizontal-range', 'scale', 'low', 'tick-scale', 'low-displacement']) me.NDFo.vd_switches[prop] = props.globals.getNode('/instrumentation/efis/vd/' ~ prop);
		me.NDFo.page = canvas_group;
		me.NDFo.terrain_elements = [];
		me.NDFo.update();
		print('HIII creating navigation display [right]');
		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {

	},
};

var canvas_ND_1_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "ECAMFontRegular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
		}

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_ND_1_test]};
		m.init(canvas_group, file);
		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		elapsedtime = getprop("/sim/time/elapsed-sec") or 0;
		if ((du2_test_time.getValue() + 1 >= elapsedtime) and getprop("/modes/cpt-du-xfr") != 1) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else if ((du1_test_time.getValue() + 1 >= elapsedtime) and getprop("/modes/cpt-du-xfr") != 0) {
			print(getprop("/modes/cpt-du-xfr"));
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

var canvas_ND_2_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "ECAMFontRegular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
		}

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_ND_2_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		elapsedtime = getprop("/sim/time/elapsed-sec") or 0;
		if ((du5_test_time.getValue() + 1 >= elapsedtime) and getprop("/modes/cpt-du-xfr") != 1) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else if ((du6_test_time.getValue() + 1 >= elapsedtime) and getprop("/modes/cpt-du-xfr") != 0) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

setlistener("sim/signals/fdm-initialized", func {
	setprop("instrumentation/efis[0]/inputs/plan-wpt-index", -1);
	setprop("instrumentation/efis[1]/inputs/plan-wpt-index", -1);

	nd_display.main = canvas.new({
		"name": "ND1",
		"size": [1024, 1024],
		"view": [1024, 1286],
		"mipmapping": 1
	});

	nd_display.right = canvas.new({
		"name": "ND2",
		"size": [1024, 1024],
		"view": [1024, 1286],
		"mipmapping": 1
	});

	nd_display.main.addPlacement({"node": "ND.screen"});
	nd_display.right.addPlacement({"node": "ND_R.screen"});
	var group_nd1 = nd_display.main.createGroup();
	var group_nd1_test = nd_display.main.createGroup();
	var group_nd2 = nd_display.right.createGroup();
	var group_nd2_test = nd_display.right.createGroup();

	ND_1 = canvas_ND_1.new(group_nd1);
	ND_1_test = canvas_ND_1_test.new(group_nd1_test, "Aircraft/A350XWB/Models/Instruments/Common/res/du-test.svg");
	print('creating nd2');
	ND_2 = canvas_ND_2.new(group_nd2);
	ND_2_test = canvas_ND_2_test.new(group_nd2_test, "Aircraft/A350XWB/Models/Instruments/Common/res/du-test.svg");

	nd_update.start();
	if (getprop("/systems/acconfig/options/nd-rate") > 1) {
		rateApply();
	}
});

var rateApply = func {
	nd_update.restart(0.05 * getprop("/systems/acconfig/options/nd-rate"));
}

var nd_update = maketimer(2, func {
	canvas_nd_base.update();
});

for (i = 0; i < 2; i = i + 1 ) {
	setlistener("/instrumentation/efis["~i~"]/nd/display-mode", func(node) {
		var par = node.getParent().getParent();
		var idx = par.getIndex();
		var canvas_mode = "/instrumentation/efis["~idx~"]/nd/canvas-display-mode";
		var nd_centered = "/instrumentation/efis["~idx~"]/inputs/nd-centered";
		var mode = getprop("/instrumentation/efis["~idx~"]/nd/display-mode");
		var cvs_mode = "NAV";
		var centered = 1;
		if (mode == "ILS") {
			cvs_mode = "APP";
		}
		else if (mode == "VOR") {
			cvs_mode = "VOR";
		}
		else if (mode == "NAV"){
			cvs_mode = "MAP";
		}
		else if (mode == "ARC"){
			cvs_mode = "MAP";
			centered = 0;
		}
		else if (mode == "PLAN"){
			cvs_mode = "PLAN";
		}
		setprop(canvas_mode, cvs_mode);
		setprop(nd_centered, centered);
	});
	setprop("/instrumentation/efis["~i~"]/nd/display-mode", 'ARC');
}

setlistener("/instrumentation/efis[0]/nd/terrain-on-nd", func{
	var terr_on_hd = getprop("/instrumentation/efis[0]/nd/terrain-on-nd");
	var alpha = 1;
	if (terr_on_hd) {
		alpha = 0.5;
	}
	#nd_display.main.setColorBackground(0,0,0,alpha);
});
setprop("/instrumentation/efis[0]/nd/terrain-on-nd", 1);
setprop("/instrumentation/efis[1]/nd/terrain-on-nd", 1);
setlistener("/flight-management/control/capture-leg", func(n) {
	var capture_leg = n.getValue();
	setprop("instrumentation/efis[0]/nd/xtrk-error", capture_leg);
	setprop("instrumentation/efis[1]/nd/xtrk-error", capture_leg);
	setprop("instrumentation/efis[0]/nd/trk-line", capture_leg);
	setprop("instrumentation/efis[1]/nd/trk-line", capture_leg);
}, 0, 0);

var showNd = func(nd = nil) {
	if (nd == nil) nd = "main";
	var dlg = canvas.Window.new([889 / 2, 564], "dialog").set("resize", 1);
	dlg.setCanvas(nd_display[nd]);
}
