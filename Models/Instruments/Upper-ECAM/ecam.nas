var ecam = {
	new: func(name) {
		print('creating ecam with name', name);
		var display = canvas.new({
			"name": name,   # The name is optional but allow for easier identification
			"size": [2048, 2048], # Size of the underlying texture (should be a power of 2, required) [Resolution]
			"view": [889.646, 564.196],  # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
						# which will be stretched the size of the texture, required)
			"mipmapping": 1       # Enable mipmapping (optional)
		});
		me.display = display;
		me.page_items = {};
		me.page_svg_items = {};
		var path = "Aircraft/A350XWB/Models/Instruments/Upper-ECAM/ecam.svg";
		# create an image child
		var group = display.createGroup('svg');
		canvas.parsesvg(group, path, {'font-mapper': func(doesnt, matter) { return 'ECAMFontRegular.ttf'; }});
		foreach (elem; ["thr_text_l", "thr_needle_l", "donut_l", "thr_text_r", "thr_needle_r", "donut_r", "n1_left", "n1_right", "tat_temp", "sat_temp", "isa_temp", "utc", "egt_text_l", "egt_needle_l", "egt_text_r", "egt_needle_r", "thrust_limit", "thrust_limit_text"]) {
			me.svg_items[elem] = group.getElementById(elem);
		}
		foreach (elem; ["thr_text_l", "thr_text_r", "n1_left", "n1_right", "tat_temp", "sat_temp", "isa_temp", "utc", "egt_text_l", "egt_text_r", "thrust_limit", "thrust_limit_text"]) {
			me.svg_items[elem].enableUpdate();
		}
		me.svg_items["thr_needle_l"].setCenter(150.485, 75.63);
		me.svg_items["thr_needle_r"].setCenter(150.485, 75.63);
		me.props.engine_1 = {
			thr: props.globals.getNode('/systems/engines/thr'),
			n1: props.globals.getNode('/engines/engine/n1'),
			egt: props.globals.getNode('/systems/engines/egt-1'),
			donut: props.globals.getNode('/systems/fadec/throttle/donut-command-1')
		};
		me.props.engine_2 = {
			thr: props.globals.getNode('/systems/engines/thr-1'),
			n1: props.globals.getNode('/engines/engine[1]/n1'),
			egt: props.globals.getNode('/systems/engines/egt-2'),
			donut: props.globals.getNode('/systems/fadec/throttle/donut-command-2')
		};
		me.props.limit = {
			thrust: props.globals.getNode('/systems/fadec/limit/thrust-limit'),
			text: props.globals.getNode('/systems/fadec/limit/thrust-limit-text')
		};
		setlistener("instrumentation/clock/indicated-string", func(value) {
			me.svg_items.utc.updateText(value.getValue());
		});
		var object = me;
		me.ed_update_items = [
			props.UpdateManager.FromHashValue('limit_thrust', 0.05, func(value) {
				object.svg_items.thrust_limit.updateText(sprintf("%0.1f", value) ~ "%");
			}),
			props.UpdateManager.FromHashValue('limit_text', 0.5, func(value) {
				object.svg_items.thrust_limit_text.updateText(['TOGA', 'CLB', 'MREV', 'MCT'][value]);
			}),
			props.UpdateManager.FromHashValue('engine_1_thr', 0.05, func(thr_l) {
				object.svg_items.thr_text_l.updateText(sprintf("%.1f", math.round(thr_l * 10) / 10));
				object.svg_items.thr_needle_l.setRotation((-120 + 210 * thr_l / 100) * math.pi / 180);
			}),
			props.UpdateManager.FromHashValue('engine_2_thr', 0.05, func(thr_r) {
				object.svg_items.thr_text_r.updateText(sprintf("%.1f", math.round(thr_r * 10) / 10));
				object.svg_items.thr_needle_r.setRotation((-120 + 210 * thr_r / 100) * math.pi / 180);
			}),
			props.UpdateManager.FromHashValue('engine_1_egt', 0.5, func(egt_l) {
				object.svg_items.egt_text_l.updateText(sprintf("%d", egt_l));
				object.svg_items.egt_needle_l.setRotation((-90 + 180 * egt_l / 1000) * D2R);
			}),
			props.UpdateManager.FromHashValue('engine_2_egt', 0.5, func(egt_r) {
				object.svg_items.egt_text_r.updateText(sprintf("%d", egt_r));
				object.svg_items.egt_needle_r.setRotation((-90 + 180 * egt_r / 1000) * D2R);
			}),
			props.UpdateManager.FromHashValue('engine_1_n1', 0.05, func(n1_l) {
				object.svg_items.n1_left.updateText(sprintf("%.1f", n1_l));
			}),
			props.UpdateManager.FromHashValue('engine_2_n1', 0.05, func(n1_r) {
				object.svg_items.n1_right.updateText(sprintf("%.1f", n1_r));
			}),
			props.UpdateManager.FromHashValue('engine_1_donut', 0.05, func(donut_l) {
				object.svg_items.donut_l.setRotation((-120 + 210 * donut_l / 100) * math.pi / 180);
			}),
			props.UpdateManager.FromHashValue('engine_2_donut', 0.05, func(donut_r) {
				object.svg_items.donut_r.setRotation((-120 + 210 * donut_r / 100) * math.pi / 180);
			})
		];
		setprop("/instrumentation/ecam/active-page", "apu");
		#var pages = ['hyd', 'apu', 'bleed'];
		var pages = ['apu'];
		foreach (var page; pages) {
			canvas.parsesvg(group, "Aircraft/A350XWB/Models/Instruments/Upper-ECAM/pages/" ~ page ~ ".svg", {'font-mapper': func(doesnt, matter) { return 'ECAMFontRegular.ttf'; }});
			me.svg_items[page] = group.getElementById(page);
		}

		var apu_page = ecam_sd_page.new(me, group, 'apu', {
			n: props.globals.getNode('/systems/apu/n'),
			flap: props.globals.getNode('/systems/apu/flap'),
			egt: props.globals.getNode('/systems/apu/egt'),
			avail: props.globals.getNode('/systems/apu/avail'),
			hz: props.globals.getNode('/systems/apu/gen-hz'),
			voltage: props.globals.getNode('/systems/apu/gen-voltage'),
			gen: props.globals.getNode('/systems/apu/gen'),
			gen_connection: props.globals.getNode('/systems/apu/gen-connection'),
			bleed_psi: props.globals.getNode('/systems/apu/bleed-psi'),
			bleed: props.globals.getNode('/systems/apu/bleed')
		}, ["apu", "apu_n_needle", "apu_egt_needle", "apu_avail", "apu_gen_stats", "apu_gen_border", "apu_gen_off", "apu_gen_text", "apu_gen_connection", "apu_gen_avail", "apu_bleed_closed", "apu_bleed_open"], ["apu_n_text", "apu_flap", "apu_egt_text", "apu_gen_hz", "apu_gen_voltage", "apu_gen_load", "apu_bleed_psi"], [
			['n', 0.1, 'rot', {
				offset: -135,
				scale: 180 / 100,
				element: 'apu_n_needle'
			}],
			['n', 0.4, 'format', {
				format: "%d",
				element: 'apu_n_text'
			}],
			['egt', 0.1, 'rot', {
				offset: -135,
				scale: 240 / 1000,
				element: 'apu_egt_needle'
			}],
			['egt', 0.5, 'function', func(egt) {
				me.page_svg_items['apu_egt_text'].updateText(sprintf("%d", 5 * math.round(egt / 5)));
			}],
			['avail', 0.4, 'show', [
				{
					element: 'apu_avail',
					invert: 0
				},
				{
					element: 'apu_gen_avail',
					invert: 0
				}
			]],
			['hz', 0.5, 'format', {
				element: 'apu_gen_hz',
				format: "%d"
			}],
			['voltage', 0.5, 'format', {
				element: 'apu_gen_voltage',
				format: "%d"
			}],
			['bleed_psi', 0.5, 'format', {
				element: 'apu_bleed_psi',
				format: "%d"
			}],
			['bleed_psi', 0.5, 'format', {
				element: 'apu_bleed_psi',
				format: "%d"
			}],
			['bleed', 0.5, 'show', [
				{
					element: 'apu_bleed_open',
					invert: 0
				},
				{
					element: 'apu_bleed_closed',
					invert: 1
				}
			]],
			['flap', 0.01, 'show', {
				element: 'apu_flap',
				invert: 0
			}],
			['flap', 0.01, 'function', func(flap) {
				if (flap > 0.95) me.page_svg_items['apu_flap'].updateText('FLAP OPEN');
				else me.page_svg_items['apu_flap'].updateText('FLAP MOVING');
			}],
			['gen_connection', 0.01, 'function', func(connection) {
				if (connection) me.page_svg_items.apu_gen_connection.setColor(0, 1, 0);
				else me.page_svg_items.apu_gen_connection.setColor(1, 1, 1);
			}],
			['gen', 0.4, 'show', [
				{
					element: 'apu_gen_off',
					invert: 1
				},
				{
					element: 'apu_gen_stats',
					invert: 0
				}
			]]
		]);

		#me.pages['hyd'] = hyd_page.new(display, group);
		me.pages['apu'] = apu_page;
		#me.pages['bleed'] = bleed_page.new(display, group);
		foreach (var page; keys(me.pages)) {
			setprop("/instrumentation/ecam/" ~ page ~ "-active", 0);
		}
		me.active_page = props.globals.getNode('/instrumentation/ecam/active-page');
		setlistener("/instrumentation/ecam/active-page", func(value) {
			foreach (var page; keys(me.pages)) {
				if (page != value.getValue()) {
					print('hiding page ', page);
					setprop("/instrumentation/ecam/" ~ page ~ "-active", 0);
					me.svg_items[page].hide();
				} else {
					print(page);
					me.svg_items[page].show();
					setprop("/instrumentation/ecam/" ~ page ~ "-active", 1);
					#me.pages[page].update_all();
				}
			}
		}, 1, 0);
		display.addPlacement({"node": name});
		var timer = maketimer(1 / 15, me, me.update_engines);
		timer.start();
		return {"parents": ecam};
	},
	update_engines: func() {
		var notification = {};
		foreach (key; keys(me.props)) {
			foreach (key2; keys(me.props[key])) {
				notification[key ~ "_" ~ key2] = me.props[key][key2].getValue();
			}
		}
		foreach (item; me.ed_update_items) item.update(notification);		
		
		var n1_r = me.props.engine_2.n1.getValue();
		me.svg_items.n1_right.updateText(sprintf("%.1f", n1_r));

		var notification = {};
		foreach (key; keys(me.pages[me.active_page.getValue()].properties)) {
			var key1 = me.pages[me.active_page.getValue()].properties[key];
			if (isa(key1, props.Node)) {
				notification[key] = key1.getValue();
				continue;
			}
			foreach (key2; keys(key1)) {
				notification[key ~ "_" ~ key2] = me.pages[me.active_page.getValue()].properties[key][key2].getValue();
			}
		}
		foreach (item; me.page_items[me.active_page.getValue()]) {
			item.update(notification);
		}
	},
	pages: {},
	props: {},
	svg_items: {},
	show: func() {
		var window = canvas.Window.new([889, 564], "dialog").set("resize", 1);
		window.setCanvas(me.display);
	}
};
# something that displays data
var ecam_item = {
	new: func(prop, change, mode, function) {
		if (typeof(prop) == 'vector') {
			# u must want a list of properties
			if (mode != 'function') {
				print('when prop is a vector, only mode "function" is available');
				return;
			}
			return props.UpdateManager.FromHashList(prop, change, function);
		}
		var execute_func = func(mode, function_single, value) {
			if (mode == 'trans-x') function_single.element.setTranslation(function_single.offset + value * function_single.scale, 0);
			if (mode == 'trans-y') function_single.element.setTranslation(0, function_single.offset + value * function_single.scale);
			if (mode == 'rot') function_single.element.setRotation((function_single.offset + value * function_single.scale) * math.pi / 180);
			if (mode == 'format') function_single.element.updateText(sprintf(function_single.format, value));
			if (mode == 'show') {
				if (function_single.invert) {
					if (value) function_single.element.hide();
					else function_single.element.show();
				} else {
					if (value) function_single.element.show();
					else function_single.element.hide();
				}
			}
			if (mode == 'function') function_single(value);
		}
		# then probably a string
		return props.UpdateManager.FromHashValue(prop, change, func(value) {
			if (typeof(function) == 'vector') {
				# list of actions
				foreach (var action; function) execute_func(mode, action, value);
			} else execute_func(mode, function, value);
		});
	}
};
var ecam_sd_page = {
	new: func(ecam_parent, svg_group, name, properties, svg_items, svg_text, items) {
		var returned = {parents: [ecam_sd_page], ecam: ecam_parent, properties: properties, items: items};
		ecam_parent.page_items[name] = [];
		ecam_parent.page_svg_items[name] = {};
		foreach (item; svg_items) ecam_parent.page_svg_items[item] = svg_group.getElementById(item);
		foreach (item; svg_text) {
			ecam_parent.page_svg_items[item] = svg_group.getElementById(item);
			ecam_parent.page_svg_items[item].enableUpdate();
		}
		foreach (var item; items) {
			if (typeof(item[3]) == 'vector') var item_list = item[3];
			else var item_list = [item[3]];
			foreach (active_element; item_list) {
				if (contains(active_element, 'element')) {
					active_element.element = ecam_parent.page_svg_items[active_element.element];
				}
			}
			append(ecam_parent.page_items[name], ecam_item.new(item[0], item[1], item[2], item[3]));
		}
		return returned;
	}
};
var hyd_page = {
	new: func(draw, svg_group) {
		me.canvas = draw;
		foreach (elem; ["yellow_quantity", "green_quantity", "hyd"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
		}
		foreach (elem; ["yellow_pressure", "green_pressure"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
			me.svg_items[elem].enableUpdate();
		}
		foreach (elem; ["green", "yellow"]) {
			foreach (elem2; ["supply", "pump"]) {
				foreach (elem3; ["on", "off"]) {
					foreach (elem4; ["1", "2"]) {
						var name = "eng" ~ elem4 ~ elem ~ elem2 ~ "_" ~ elem3;
						me.svg_items[name] = svg_group.getElementById(name);
						if (elem3 == "off") {
							var on_or_off_bool = 0;
							var engine = "engine";
							if (elem4 == "1") engine = "engine";
							else engine = "engine[1]";
							if (elem2 == "pump") on_or_off_bool = getprop("/engines/" ~ engine ~ "/" ~ elem ~ "-pump");
							else on_or_off_bool = 1;
							var on_or_off = "off";
							if (on_or_off_bool) on_or_off = "on";
							me.update_valve(elem4, elem, elem2, on_or_off);
						}
					}
				}
			}
		}
		setlistener("/systems/hydraulic/green-pressure", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_pressure('green', value.getValue());
		});
		setlistener("/systems/hydraulic/yellow-pressure", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_pressure('yellow', value.getValue());
		});
		# this is a mess!
		setlistener("engines/engine/yellow-pump", func(value) {
			if (!me.am_i_on_screen()) return;
			var on_or_off = 'off';
			if (value.getValue()) on_or_off = 'on';
			me.update_valve('1', 'yellow', 'pump', on_or_off);
		});
		setlistener("engines/engine[1]/yellow-pump", func(value) {
			if (!me.am_i_on_screen()) return;
			var on_or_off = 'off';
			if (value.getValue()) on_or_off = 'on';
			me.update_valve('2', 'yellow', 'pump', on_or_off);
		});
		setlistener("engines/engine/green-pump", func(value) {
			if (!me.am_i_on_screen()) return;
			var on_or_off = 'off';
			if (value.getValue()) on_or_off = 'on';
			me.update_valve('1', 'green', 'pump', on_or_off);
		});
		setlistener("engines/engine[1]/green-pump", func(value) {
			if (!me.am_i_on_screen()) return;
			var on_or_off = 'off';
			if (value.getValue()) on_or_off = 'on';
			me.update_valve('2', 'green', 'pump', on_or_off);
		});
		return {"parents": [hyd_page]};
	},
	hide: func() {
		me.svg_items['hyd'].hide();
	},
	show: func() {
		me.svg_items['hyd'].show();
	},
	am_i_on_screen: func() {
		return getprop("/instrumentation/ecam/active-page") == "hyd";
	},
	update_pressure: func(system, pressure) {
		# system: 'green' or 'yellow'
		me.svg_items[system ~ "_pressure"].updateText(sprintf("%d", pressure));
	},
	update_valve: func(eng, system, supply_or_pump, on_or_off) {
		# eng: 1 or 2
		# supply_or_pump: 'supply' or 'pump'
		# on_or_off: 'on' or 'off'
		var opposite = "";
		if (on_or_off == "on") opposite = "off";
		if (on_or_off == "off") opposite = "on";
		me.svg_items['eng' ~ eng ~ system ~ supply_or_pump ~ "_" ~ on_or_off].show();
		me.svg_items['eng' ~ eng ~ system ~ supply_or_pump ~ "_" ~ opposite].hide();
	},
	update_all: func() {
		me.update_pressure('green', getprop("/systems/hydraulic/green-pressure"));
		me.update_pressure('yellow', getprop("/systems/hydraulic/yellow-pressure"));
		foreach (elem; ["green", "yellow"]) {
			foreach (elem2; ["supply", "pump"]) {
				foreach (elem3; ["on", "off"]) {
					foreach (elem4; ["1", "2"]) {
						var name = "eng" ~ elem4 ~ elem ~ elem2 ~ "_" ~ elem3;
						if (elem3 == "off") {
							var on_or_off_bool = 0;
							var engine = "engine";
							if (elem4 == "1") engine = "engine";
							else engine = "engine[1]";
							if (elem2 == "pump") on_or_off_bool = getprop("/engines/" ~ engine ~ "/" ~ elem ~ "-pump");
							else on_or_off_bool = 1;
							var on_or_off = "off";
							if (on_or_off_bool) on_or_off = "on";
							me.update_valve(elem4, elem, elem2, on_or_off);
						}
					}
				}
			}
		}
	},
	svg_items: {}
};
var bleed_page = {
	new: func(draw, svg_group) {
		me.canvas = draw;
		foreach (elem; ["bleed", "bleed_apu_on", "bleed_apu_off", "bleed_apu_running", "bleed_cross_open", "bleed_cross_closed", "bleed_eng1_on", "bleed_eng1_off", "bleed_eng2_on", "bleed_eng2_off"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
		}
		foreach (elem; ["bleed_eng1temp", "bleed_eng1psi", "bleed_eng2temp", "bleed_eng2psi", "bleed_pack1_intemp", "bleed_pack2_intemp"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
			me.svg_items[elem].enableUpdate();
		}
		setlistener("/systems/apu/bleed", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_apu_bleed(value.getValue());
		});
		setlistener("/systems/apu/avail", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_apu_avail(value.getValue());
		});
		setlistener("/systems/air/x-bleed", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_cross_bleed(value.getValue());
		});
		setlistener("/engines/engine/bleed", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_1_bleed(value.getValue());
		});
		setlistener("/engines/engine[1]/bleed", func(value) {
			if (!me.am_i_on_screen()) return;
			me.update_2_bleed(value.getValue());
		});
		setlistener("/systems/air/eng-1-bleed-temp", func(temp) {
			if (!me.am_i_on_screen()) return;
			me.update_bleed_temp(1, temp.getValue());
		}, 0, 0);
		setlistener("/systems/air/eng-2-bleed-temp", func(temp) {
			if (!me.am_i_on_screen()) return;
			me.update_bleed_temp(2, temp.getValue());
		}, 0, 0);
		setlistener("/systems/air/eng-1-bleed-psi", func(psi) {
			if (!me.am_i_on_screen()) return;
			me.update_bleed_psi(1, psi.getValue());
		}, 0, 0);
		setlistener("/systems/air/eng-2-bleed-psi", func(psi) {
			if (!me.am_i_on_screen()) return;
			me.update_bleed_psi(2, psi.getValue());
		}, 0, 0);
		setlistener("/systems/air/eng-1-pack-in-temp", func(temp) {
			if (!me.am_i_on_screen()) return;
			me.update_pack_in_temp(1, temp.getValue());
		}, 0, 0);
		setlistener("/systems/air/eng-2-pack-in-temp", func(temp) {
			if (!me.am_i_on_screen()) return;
			me.update_pack_in_temp(2, temp.getValue());
		}, 0, 0);
		return {parents: [bleed_page]};
	},
	update_apu_bleed: func(bleed) {
		if (bleed) {
			me.svg_items.bleed_apu_on.hide();
			me.svg_items.bleed_apu_off.show();
		} else {
			me.svg_items.bleed_apu_off.hide();
			me.svg_items.bleed_apu_on.show();
		}
	},
	update_apu_avail: func(avail) {
		if (avail) me.svg_items.bleed_apu_running.show();
		else me.svg_items.bleed_apu_running.hide();
	},
	update_cross_bleed: func(bleed) {
		if (bleed) {
			me.svg_items.bleed_cross_open.show();
			me.svg_items.bleed_cross_closed.hide();
		} else {
			me.svg_items.bleed_cross_open.hide();
			me.svg_items.bleed_cross_closed.show();
		}
	},
	update_1_bleed: func(bleed) {
		if (bleed) {
			me.svg_items.bleed_eng1_on.show();
			me.svg_items.bleed_eng1_off.hide();
		} else {
			me.svg_items.bleed_eng1_on.hide();
			me.svg_items.bleed_eng1_off.show();
		}
	},
	update_2_bleed: func(bleed) {
		if (bleed) {
			me.svg_items.bleed_eng2_on.show();
			me.svg_items.bleed_eng2_off.hide();
		} else {
			me.svg_items.bleed_eng2_on.hide();
			me.svg_items.bleed_eng2_off.show();
		}
	},
	update_bleed_temp: func(eng, temp) {
		me.svg_items['bleed_eng' ~ eng ~ 'temp'].updateText(sprintf("%d", temp));
	},
	update_bleed_psi: func(eng, psi) {
		me.svg_items['bleed_eng' ~ eng ~ 'psi'].updateText(sprintf("%d", psi));
	},
	update_pack_in_temp: func(pack, temp) {
		me.svg_items['bleed_pack' ~ pack ~ "_intemp"].updateText(sprintf("%d", temp));
	},
	show: func() {
		me.svg_items.bleed.show();
	},
	hide: func() {
		me.svg_items.bleed.hide();
	},
	am_i_on_screen: func() {
		return getprop("/instrumentation/ecam/active-page") == "bleed";
	},
	update_all: func() {
		me.update_apu_bleed(getprop("/systems/apu/bleed"));
		me.update_apu_avail(getprop("/systems/apu/avail"));
		me.update_cross_bleed(getprop("/systems/air/x-bleed"));
		me.update_1_bleed(getprop("/engines/engine/bleed"));
		me.update_2_bleed(getprop("/engines/engine[1]/bleed"));
		foreach (engine; ["1", "2"]) {
			me.update_bleed_psi(engine, getprop("/systems/air/eng-" ~ engine ~ "-bleed-psi"));
			me.update_bleed_temp(engine, getprop("/systems/air/eng-" ~ engine ~ "-bleed-temp"));
			me.update_pack_in_temp(engine, getprop("/systems/air/eng-" ~ engine ~ "-pack-in-temp"));
		}
	},
	svg_items: {}
};
var upper_ecam = ecam.new('upper_ecam');
