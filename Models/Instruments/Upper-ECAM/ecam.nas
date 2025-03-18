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
		me.group = group;
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
		me.props.electric = {
			dc_emer_1: props.globals.getNode('/systems/electrical/bus/dc-emer-1')
		};
		setlistener("instrumentation/clock/indicated-string", func(value) {
			me.svg_items.utc.updateText(value.getValue());
		});
		var object = me;
		me.ed_update_items = [
			props.UpdateManager.FromHashValue('electric_dc_emer_1', 0.1, func(volts) {
				if (volts > 20) object.group.show();
				else object.group.hide();
			}),
			props.UpdateManager.FromHashValue('limit_thrust', 0.05, func(value) {
				object.svg_items.thrust_limit.updateText(sprintf("%0.1f", value) ~ "%");
			}),
			props.UpdateManager.FromHashValue('limit_text', 0.5, func(value) {
				object.svg_items.thrust_limit_text.updateText(['TOGA', 'CLB', 'MREV', 'MCT', 'D-TO', 'FLEX'][value]);
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
		setprop("/instrumentation/ecam/active-page", "elec_ac");
		#var pages = ['hyd', 'apu', 'bleed'];
		var pages = ['apu', 'elec_ac'];
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
		var elec_ac_page = ecam_sd_page.new(me, group, "elec_ac", {
			gen_1a: {
				voltage: props.globals.getNode('/systems/electrical/voltage/gen-1a'),
				drive: props.globals.getNode('/controls/electric/drive-1a'),
				off: props.globals.getNode('/controls/electric/gen-1a'),
				fault: props.globals.getNode('/systems/electrical/ecam/fault-1a'),
				connector: props.globals.getNode('/systems/electrical/reconfiguration/gen-1a-1a'),
				load: props.globals.getNode('/systems/electrical/loads/gen-1a-load'),
				overload: props.globals.getNode('/systems/electrical/overload/gen-1a-overload')
			},
			gen_1b: {
				voltage: props.globals.getNode('/systems/electrical/voltage/gen-1b'),
				drive: props.globals.getNode('/controls/electric/drive-1b'),
				off: props.globals.getNode('/controls/electric/gen-1b'),
				fault: props.globals.getNode('/systems/electrical/ecam/fault-1b'),
				connector: props.globals.getNode('/systems/electrical/reconfiguration/gen-1b-1b'),
				load: props.globals.getNode('/systems/electrical/loads/gen-1b-load'),
				overload: props.globals.getNode('/systems/electrical/overload/gen-1b-overload')
			},
			gen_2a: {
				voltage: props.globals.getNode('/systems/electrical/voltage/gen-2a'),
				drive: props.globals.getNode('/controls/electric/drive-2a'),
				off: props.globals.getNode('/controls/electric/gen-2a'),
				fault: props.globals.getNode('/systems/electrical/ecam/fault-2a'),
				connector: props.globals.getNode('/systems/electrical/reconfiguration/gen-2a-2a'),
				load: props.globals.getNode('/systems/electrical/loads/gen-2a-load'),
				overload: props.globals.getNode('/systems/electrical/overload/gen-2a-overload')
			},
			gen_2b: {
				voltage: props.globals.getNode('/systems/electrical/voltage/gen-2b'),
				drive: props.globals.getNode('/controls/electric/drive-2b'),
				off: props.globals.getNode('/controls/electric/gen-2b'),
				fault: props.globals.getNode('/systems/electrical/ecam/fault-2b'),
				connector: props.globals.getNode('/systems/electrical/reconfiguration/gen-2b-2b'),
				load: props.globals.getNode('/systems/electrical/loads/gen-2b-load'),
				overload: props.globals.getNode('/systems/electrical/overload/gen-2b-overload')
			},
			apu: {
				running: props.globals.getNode('/systems/apu/avail'),
				contactor: props.globals.getNode('/systems/electrical/ecam/apu-contactor'),
				supplies_1a: props.globals.getNode('/systems/electrical/reconfiguration/apu-1a'),
				supplies_1b: props.globals.getNode('/systems/electrical/reconfiguration/apu-1b'),
				supplies_2a: props.globals.getNode('/systems/electrical/reconfiguration/apu-2a'),
				supplies_2b: props.globals.getNode('/systems/electrical/reconfiguration/apu-2b'),
				voltage: props.globals.getNode('/systems/apu/gen-voltage'),
				off: props.globals.getNode('/systems/apu/gen'),
				load: props.globals.getNode('/systems/electrical/loads/apu-load'),
				overload: props.globals.getNode('/systems/electrical/overload/apu-overload'),
				frequency: props.globals.getNode('/systems/apu/gen-hz')
			},
			ac_bus: {
				bus_1a: props.globals.getNode('/systems/electrical/ecam/ac-1a'),
				bus_1b: props.globals.getNode('/systems/electrical/ecam/ac-1b'),
				bus_2a: props.globals.getNode('/systems/electrical/ecam/ac-2a'),
				bus_2b: props.globals.getNode('/systems/electrical/ecam/ac-2b'),
				bus_1a_1b: props.globals.getNode('/systems/electrical/ecam/bus-1a-1b-230'),
				bus_2a_2b: props.globals.getNode('/systems/electrical/ecam/bus-2a-2b-230'),
				gen_1b_apu_1a: props.globals.getNode('/systems/electrical/ecam/gen-1b-apu-1a'),
				gen_2b_apu_2a: props.globals.getNode('/systems/electrical/ecam/gen-2b-apu-2a'),
				gen_1a_2b: props.globals.getNode('/systems/electrical/ecam/gen-1a-2b'),
				gen_1a_2b_1b: props.globals.getNode('/systems/electrical/ecam/gen-1a-2b-1b'),
				gen_1b_2a: props.globals.getNode('/systems/electrical/ecam/gen-1b-2a'),
				gen_1b_2a_2b: props.globals.getNode('/systems/electrical/ecam/gen-1b-2a-2b'),
				gen_1a_2b_1b_2a: props.globals.getNode('/systems/electrical/ecam/gen-1a-2b-1b-2a')
			},
			ext: {
				voltage_1: props.globals.getNode('/systems/electrical/voltage/ext-a'),
				voltage_2: props.globals.getNode('/systems/electrical/voltage/ext-b'),
				ext_a: props.globals.getNode('/systems/electrical/generators/ext-a'),
				ext_b: props.globals.getNode('/systems/electrical/generators/ext-b'),
				contactor_a: props.globals.getNode('/systems/electrical/ecam/ext-a-contactor'),
				contactor_b: props.globals.getNode('/systems/electrical/ecam/ext-b-contactor'),
				ext_1a: props.globals.getNode('/systems/electrical/ecam/ext-1a'),
				ext_1b: props.globals.getNode('/systems/electrical/ecam/ext-1b'),
				ext_2a: props.globals.getNode('/systems/electrical/ecam/ext-2a'),
				ext_2b: props.globals.getNode('/systems/electrical/ecam/ext-2b'),
				left: props.globals.getNode('/systems/electrical/ecam/ext-left-line'),
				center: props.globals.getNode('/systems/electrical/ecam/ext-center-line'),
				right: props.globals.getNode('/systems/electrical/ecam/ext-right-line'),
				wow: props.globals.getNode('/fdm/jsbsim/gear/wow')
			},
			emer: {
				bus_1b_1: props.globals.getNode('/systems/electrical/reconfiguration/ac-1b-supplies-emer-1'),
				bus_2b_2: props.globals.getNode('/systems/electrical/reconfiguration/ac-2b-supplies-emer-2'),
				rat_voltage: props.globals.getNode('/systems/electrical/voltage/rat'),
				rat_position: props.globals.getNode('/systems/electrical/generators/rat-position'),
				rat_1: props.globals.getNode('/systems/electrical/reconfiguration/rat-supplies-emer-1'),
				rat_2: props.globals.getNode('/systems/electrical/reconfiguration/rat-supplies-emer-2'),
				rat_contactor: props.globals.getNode('/systems/electrical/ecam/rat-contactor'),
				connector: props.globals.getNode('/systems/electrical/ecam/emer-1-emer-2'),
				emer_1: props.globals.getNode('/systems/electrical/ecam/ac-emer-1'),
				emer_2: props.globals.getNode('/systems/electrical/ecam/ac-emer-2'),
			},
			engine_1: {
				running: props.globals.getNode('/engines/engine/running')
			},
			engine_2: {
				running: props.globals.getNode('/engines/engine[1]/running')
			}
		}, 
		['elec_ac_gen_1a_label', 'elec_ac_gen_1a_text', 'elec_ac_gen_1a_off', 'elec_ac_gen_1a_stats', 'elec_ac_gen_1a_voltage', 'elec_ac_gen_1a_load', 'elec_ac_gen_1a_disc', 'elec_ac_gen_1a_connector', 'elec_ac_gen_1b_label', 'elec_ac_gen_1b_text', 'elec_ac_gen_1b_off', 'elec_ac_gen_1b_stats', 'elec_ac_gen_1b_voltage', 'elec_ac_gen_1b_load', 'elec_ac_gen_1b_disc', 'elec_ac_gen_1b_connector', 'elec_ac_gen_2a_label', 'elec_ac_gen_2a_text', 'elec_ac_gen_2a_off', 'elec_ac_gen_2a_stats', 'elec_ac_gen_2a_voltage', 'elec_ac_gen_2a_load', 'elec_ac_gen_2a_disc', 'elec_ac_gen_2a_connector', 'elec_ac_gen_2b_label', 'elec_ac_gen_2b_text', 'elec_ac_gen_2b_off', 'elec_ac_gen_2b_stats', 'elec_ac_gen_2b_voltage', 'elec_ac_gen_2b_load', 'elec_ac_gen_2b_disc', 'elec_ac_gen_2b_connector', 'elec_ac_1a_115_text', 'elec_ac_1a_230_text', 'elec_ac_1a_diamond', 'elec_ac_1b_115_text', 'elec_ac_1b_230_text', 'elec_ac_1b_diamond', 'elec_ac_2a_115_text', 'elec_ac_2a_230_text', 'elec_ac_2a_diamond', 'elec_ac_2b_115_text', 'elec_ac_2b_230_text', 'elec_ac_2b_diamond', 'elec_ac_bus_1a_1b_230', 'elec_ac_bus_2a_2b_230', 'elec_ac_apu_gen_contactor', 'elec_ac_apu_1a', 'elec_ac_apu_1b', 'elec_ac_apu_2b', 'elec_ac_apu_2a', 'elec_ac_1b_apu_1a', 'elec_ac_2b_apu_2a', 'elec_ac_1a_2b', 'elec_ac_1b_2a', 'elec_ac_1a_2b_1b', 'elec_ac_1b_2a_2b', 'elec_ac_1a_2b_1b_2a', 'elec_ac_ext_1a', 'elec_ac_ext_1b', 'elec_ac_ext_2a', 'elec_ac_ext_2b', 'elec_ac_ext_1_voltage', 'elec_ac_ext_2_voltage', 'elec_ac_ext_1_stats', 'elec_ac_ext_1_off', 'elec_ac_ext_2_stats', 'elec_ac_ext_2_off', 'elec_ac_ext_1_contactor', 'elec_ac_ext_2_contactor', 'elec_ac_ext_left','elec_ac_ext_right', 'elec_ac_ext_center', 'elec_ac_2b_emer_2', 'elec_ac_1b_emer_1', 'elec_ac_rat_voltage', 'elec_ac_rat', 'elec_ac_rat_1', 'elec_ac_rat_2', 'elec_ac_rat_contactor', 'elec_ac_emer_connector', 'elec_ac_ext_1', 'elec_ac_ext_2', 'elec_ac_ext_center_emer_1', 'elec_ac_ext_center_emer_2', 'elec_ac_emer_1_diamond', 'elec_ac_emer_1_115', 'elec_ac_emer_1_230', 'elec_ac_emer_2_diamond', 'elec_ac_emer_2_115', 'elec_ac_emer_2_230', 'elec_ac_apu_gen', 'elec_ac_apu_gen_off', 'elec_ac_apu_gen_stats', 'elec_ac_apu_gen_frequency', 'elec_ac_apu_gen_voltage', 'elec_ac_apu_gen_load'], 
		['elec_ac_gen_1a_voltage', 'elec_ac_gen_1a_load', 'elec_ac_gen_1b_voltage', 'elec_ac_gen_1b_load', 'elec_ac_gen_2a_voltage', 'elec_ac_gen_2a_load', 'elec_ac_gen_2b_voltage', 'elec_ac_gen_2b_load', 'elec_ac_ext_1_voltage', 'elec_ac_ext_2_voltage', 'elec_ac_rat_voltage', 'elec_ac_apu_gen_frequency', 'elec_ac_apu_gen_voltage', 'elec_ac_apu_gen_load'], 
		[
			["gen_1a_voltage", 0.5, 'format', {
				element: 'elec_ac_gen_1a_voltage',
				format: '%d'
			}],
			["gen_1a_load", 0.1, 'format', {
				element: 'elec_ac_gen_1a_load',
				format: '%d'
			}],
			["gen_1a_overload", 0.5, 'function', func(overload) {
				if (overload) {
					me.page_svg_items.elec_ac_gen_1a_load.setColor(187 / 255, 97 / 255, 0);
				} else {
					me.page_svg_items.elec_ac_gen_1a_load.setColor(0, 1, 0);
				}
			}],
			["gen_1a_voltage", 0.01, 'function', func(voltage) {
				if (voltage >= 230 and voltage <= 240) {
					me.page_svg_items.elec_ac_gen_1a_voltage.setColor(0, 1, 0);
				} else {
					me.page_svg_items.elec_ac_gen_1a_voltage.setColor(187 / 255, 97 / 255, 0);
				}
			}],
			["gen_1a_drive", 0.5, 'show', {
				element: 'elec_ac_gen_1a_disc',
				invert: 1
			}],
			["gen_1a_off", 0.5, 'show', [{
				element: 'elec_ac_gen_1a_off',
				invert: 1
			}, {
				element: 'elec_ac_gen_1a_stats',
				invert: 0
			}]],
			["gen_1a_fault", 0.5, 'function', func(fault) {
				if (!fault) me.page_svg_items['elec_ac_gen_1a_label'].setColor(1, 1, 1);
				else me.page_svg_items['elec_ac_gen_1a_label'].setColor(187 / 255, 97 / 255, 0);
			}],
			["gen_1a_connector", 0.5, 'show', {
				element: 'elec_ac_gen_1a_connector',
				invert: 0
			}],
			["engine_1_running", 0.5, 'function', func(running) {
				if (running) {
					me.page_svg_items['elec_ac_gen_1a_text'].setColor(1, 1, 1);
					me.page_svg_items['elec_ac_gen_1b_text'].setColor(1, 1, 1);
				} else {
					me.page_svg_items['elec_ac_gen_1a_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_gen_1b_text'].setColor(187 / 255, 97 / 255, 0);
				}
			}],
			["engine_2_running", 0.5, 'function', func(running) {
				if (running) {
					me.page_svg_items['elec_ac_gen_2a_text'].setColor(1, 1, 1);
					me.page_svg_items['elec_ac_gen_2b_text'].setColor(1, 1, 1);
				} else {
					me.page_svg_items['elec_ac_gen_2a_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_gen_2b_text'].setColor(187 / 255, 97 / 255, 0);
				}
			}],
			['ac_bus_bus_1a', 0.5, 'function', func(bus) {
				if (bus) {
					me.page_svg_items['elec_ac_1a_115_text'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_1a_230_text'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_1a_diamond'].show();
				} else {
					me.page_svg_items['elec_ac_1a_115_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_1a_230_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_1a_diamond'].hide();
				}
			}],
			['ac_bus_bus_1a_1b', 0.5, 'show', {
				element: 'elec_ac_bus_1a_1b_230',
				invert: 0
			}],
			['ac_bus_bus_2a_2b', 0.5, 'show', {
				element: 'elec_ac_bus_2a_2b_230',
				invert: 0
			}],
			['apu_contactor', 0.5, 'show', {
				element: 'elec_ac_apu_gen_contactor',
				invert: 0
			}],
			['apu_running', 0.5, 'show', {
				element: 'elec_ac_apu_gen',
				invert: 0
			}],
			['apu_off', 0.5, 'show', [{
				element: 'elec_ac_apu_gen_stats',
				invert: 0
			}, {
				element: 'elec_ac_apu_gen_off',
				invert: 1
			}]],
			["apu_voltage", 0.01, 'function', func(voltage) {
				if (voltage >= 225 and voltage <= 245) {
					me.page_svg_items.elec_ac_apu_gen_voltage.setColor(0, 1, 0);
				} else {
					me.page_svg_items.elec_ac_apu_gen_voltage.setColor(187 / 255, 97 / 255, 0);
				}
			}],
			["apu_frequency", 0.01, 'function', func(frequency) {
				if (frequency >= 385 and frequency <= 418) {
					me.page_svg_items.elec_ac_apu_gen_frequency.setColor(0, 1, 0);
				} else {
					me.page_svg_items.elec_ac_apu_gen_frequency.setColor(187 / 255, 97 / 255, 0);
				}
			}],
			["apu_overload", 0.5, 'function', func(overload) {
				if (overload) {
					me.page_svg_items.elec_ac_apu_gen_load.setColor(187 / 255, 97 / 255, 0);
				} else {
					me.page_svg_items.elec_ac_apu_gen_load.setColor(0, 1, 0);
				}
			}],
			['apu_load', 0.5, 'format', {
				element: 'elec_ac_apu_gen_load',
				format: '%d'
			}],
			['apu_voltage', 0.5, 'format', {
				element: 'elec_ac_apu_gen_voltage',
				format: '%d'
			}],
			['apu_frequency', 0.5, 'format', {
				element: 'elec_ac_apu_gen_frequency',
				format: '%d'
			}],
			['apu_supplies_1a', 0.5, 'show', {
				element: 'elec_ac_apu_1a',
				invert: 0
			}],
			['apu_supplies_1b', 0.5, 'show', {
				element: 'elec_ac_apu_1b',
				invert: 0
			}],
			['apu_supplies_2b', 0.5, 'show', {
				element: 'elec_ac_apu_2b',
				invert: 0
			}],
			['apu_supplies_2a', 0.5, 'show', {
				element: 'elec_ac_apu_2a',
				invert: 0
			}],
			['ac_bus_gen_1b_apu_1a', 0.5, 'show', {
				element: 'elec_ac_1b_apu_1a',
				invert: 0
			}],
			['ac_bus_gen_2b_apu_2a', 0.5, 'show', {
				element: 'elec_ac_2b_apu_2a',
				invert: 0
			}],
			['ac_bus_gen_1a_2b', 0.5, 'show', {
				element: 'elec_ac_1a_2b',
				invert: 0
			}],
			['ac_bus_gen_1b_2a', 0.5, 'show', {
				element: 'elec_ac_1b_2a',
				invert: 0
			}],
			['ac_bus_gen_1a_2b_1b', 0.5, 'show', {
				element: 'elec_ac_1a_2b_1b',
				invert: 0
			}],
			['ac_bus_gen_1a_2b_1b_2a', 0.5, 'show', {
				element: 'elec_ac_1a_2b_1b_2a',
				invert: 0
			}],
			['ac_bus_gen_1b_2a_2b', 0.5, 'show', {
				element: 'elec_ac_1b_2a_2b',
				invert: 0
			}],
			['ext_wow', 0.5, 'show', [{
				element: 'elec_ac_ext_1',
				invert: 0
			}, {
				element: 'elec_ac_ext_2',
				invert: 0
			}]],
			['ext_voltage_1', 0.5, 'format', {
				element: 'elec_ac_ext_1_voltage',
				format: '%d'
			}],
			['ext_voltage_2', 0.5, 'format', {
				element: 'elec_ac_ext_2_voltage',
				format: '%d'
			}],
			['ext_ext_1a', 0.5, 'show', {
				element: 'elec_ac_ext_1a',
				invert: 0
			}],
			['ext_ext_1b', 0.5, 'show', {
				element: 'elec_ac_ext_1b',
				invert: 0
			}],
			['ext_ext_2a', 0.5, 'show', {
				element: 'elec_ac_ext_2a',
				invert: 0
			}],
			['ext_ext_2b', 0.5, 'show', {
				element: 'elec_ac_ext_2b',
				invert: 0
			}],
			['ext_ext_a', 0.5, 'show', [{
				element: 'elec_ac_ext_1_stats',
				invert: 0
			}, {
				element: 'elec_ac_ext_1_off',
				invert: 1
			}]],
			['ext_ext_b', 0.5, 'show', [{
				element: 'elec_ac_ext_2_stats',
				invert: 0
			}, {
				element: 'elec_ac_ext_2_off',
				invert: 1
			}]],
			['ext_contactor_a', 0.5, 'show', {
				element: 'elec_ac_ext_1_contactor',
				invert: 0
			}],
			['ext_contactor_b', 0.5, 'show', {
				element: 'elec_ac_ext_2_contactor',
				invert: 0
			}],
			['ext_left', 0.5, 'show', {
				element: 'elec_ac_ext_left',
				invert: 0
			}],
			['ext_center', 0.5, 'show', {
				element: 'elec_ac_ext_center',
				invert: 0
			}],
			['ext_right', 0.5, 'show', {
				element: 'elec_ac_ext_right',
				invert: 0
			}],
			['emer_emer_1', 0.5, 'function', func(bus) {
				if (bus) {
					me.page_svg_items['elec_ac_emer_1_230'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_emer_1_115'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_emer_1_diamond'].show();
				} else {
					me.page_svg_items['elec_ac_emer_1_230'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_emer_1_115'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_emer_1_diamond'].hide();
				}
			}],
			['emer_emer_2', 0.5, 'function', func(bus) {
				if (bus) {
					me.page_svg_items['elec_ac_emer_2_230'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_emer_2_115'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_emer_2_diamond'].show();
				} else {
					me.page_svg_items['elec_ac_emer_2_230'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_emer_2_115'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_emer_2_diamond'].hide();
				}
			}],
			['emer_bus_1b_1', 0.5, 'show', [{
				element: 'elec_ac_1b_emer_1',
				invert: 0
			}, {
				element: 'elec_ac_ext_center_emer_1',
				invert: 0
			}]],
			['emer_bus_2b_2', 0.5, 'show', [{
				element: 'elec_ac_2b_emer_2',
				invert: 0
			}, {
				element: 'elec_ac_ext_center_emer_2',
				invert: 0
			}]],
			['emer_rat_position', 0.01, 'function', func(position) {
				if (position > 0.5) me.page_svg_items.elec_ac_rat.show();
				else me.page_svg_items.elec_ac_rat.hide();
			}],
			['emer_rat_voltage', 0.01, 'format', {
				format: '%d',
				element: 'elec_ac_rat_voltage'
			}],

			['emer_rat_1', 0.5, 'show', {
				element: 'elec_ac_rat_1',
				invert: 0
			}],
			['emer_rat_2', 0.5, 'show', {
				element: 'elec_ac_rat_2',
				invert: 0
			}],
			['emer_rat_contactor', 0.5, 'show', {
				element: 'elec_ac_rat_contactor',
				invert: 0
			}],
			['emer_connector', 0.5, 'show', {
				element: 'elec_ac_emer_connector',
				invert: 0
			}],
			# rest of this stuff is copied ...
			["gen_1b_voltage", 0.5, 'format', {
				element: 'elec_ac_gen_1b_voltage',
				format: '%d'
			}],
			["gen_1b_load", 0.1, 'format', {
				element: 'elec_ac_gen_1b_load',
				format: '%d'
			}],
			["gen_1b_overload", 0.5, 'function', func(overload) {
				if (overload) {
					me.page_svg_items.elec_ac_gen_1b_load.setColor(187 / 255, 97 / 255, 0);
				} else {
					me.page_svg_items.elec_ac_gen_1b_load.setColor(0, 1, 0);
				}
			}],
			["gen_1b_voltage", 0.01, 'function', func(voltage) {
				if (voltage >= 230 and voltage <= 240) {
					me.page_svg_items.elec_ac_gen_1b_voltage.setColor(0, 1, 0);
				} else {
					me.page_svg_items.elec_ac_gen_1b_voltage.setColor(187 / 255, 97 / 255, 0);
				}
			}],
			["gen_1b_drive", 0.5, 'show', {
				element: 'elec_ac_gen_1b_disc',
				invert: 1
			}],
			["gen_1b_off", 0.5, 'show', [{
				element: 'elec_ac_gen_1b_off',
				invert: 1
			}, {
				element: 'elec_ac_gen_1b_stats',
				invert: 0
			}]],
			["gen_1b_fault", 0.5, 'function', func(fault) {
				if (!fault) me.page_svg_items['elec_ac_gen_1b_label'].setColor(1, 1, 1);
				else me.page_svg_items['elec_ac_gen_1b_label'].setColor(187 / 255, 97 / 255, 0);
			}],
			["gen_1b_connector", 0.5, 'show', {
				element: 'elec_ac_gen_1b_connector',
				invert: 0
			}],

			["gen_2a_voltage", 0.5, 'format', {
				element: 'elec_ac_gen_2a_voltage',
				format: '%d'
			}],
			["gen_2a_load", 0.1, 'format', {
				element: 'elec_ac_gen_2a_load',
				format: '%d'
			}],
			["gen_2a_overload", 0.5, 'function', func(overload) {
				if (overload) {
					me.page_svg_items.elec_ac_gen_2a_load.setColor(187 / 255, 97 / 255, 0);
				} else {
					me.page_svg_items.elec_ac_gen_2a_load.setColor(0, 1, 0);
				}
			}],
			["gen_2a_voltage", 0.01, 'function', func(voltage) {
				if (voltage >= 230 and voltage <= 240) {
					me.page_svg_items.elec_ac_gen_2a_voltage.setColor(0, 1, 0);
				} else {
					me.page_svg_items.elec_ac_gen_2a_voltage.setColor(187 / 255, 97 / 255, 0);
				}
			}],
			["gen_2a_drive", 0.5, 'show', {
				element: 'elec_ac_gen_2a_disc',
				invert: 1
			}],
			["gen_2a_off", 0.5, 'show', [{
				element: 'elec_ac_gen_2a_off',
				invert: 1
			}, {
				element: 'elec_ac_gen_2a_stats',
				invert: 0
			}]],
			["gen_2a_fault", 0.5, 'function', func(fault) {
				if (!fault) me.page_svg_items['elec_ac_gen_2a_label'].setColor(1, 1, 1);
				else me.page_svg_items['elec_ac_gen_2a_label'].setColor(187 / 255, 97 / 255, 0);
			}],
			["gen_2a_connector", 0.5, 'show', {
				element: 'elec_ac_gen_2a_connector',
				invert: 0
			}],

			["gen_2b_voltage", 0.5, 'format', {
				element: 'elec_ac_gen_2b_voltage',
				format: '%d'
			}],
			["gen_2b_load", 0.1, 'format', {
				element: 'elec_ac_gen_2b_load',
				format: '%d'
			}],
			["gen_2b_overload", 0.5, 'function', func(overload) {
				if (overload) {
					me.page_svg_items.elec_ac_gen_2b_load.setColor(187 / 255, 97 / 255, 0);
				} else {
					me.page_svg_items.elec_ac_gen_2b_load.setColor(0, 1, 0);
				}
			}],
			["gen_2b_voltage", 0.01, 'function', func(voltage) {
				if (voltage >= 230 and voltage <= 240) {
					me.page_svg_items.elec_ac_gen_2b_voltage.setColor(0, 1, 0);
				} else {
					me.page_svg_items.elec_ac_gen_2b_voltage.setColor(187 / 255, 97 / 255, 0);
				}
			}],
			["gen_2b_drive", 0.5, 'show', {
				element: 'elec_ac_gen_2b_disc',
				invert: 1
			}],
			["gen_2b_off", 0.5, 'show', [{
				element: 'elec_ac_gen_2b_off',
				invert: 1
			}, {
				element: 'elec_ac_gen_2b_stats',
				invert: 0
			}]],
			["gen_2b_fault", 0.5, 'function', func(fault) {
				if (!fault) me.page_svg_items['elec_ac_gen_2b_label'].setColor(1, 1, 1);
				else me.page_svg_items['elec_ac_gen_2b_label'].setColor(187 / 255, 97 / 255, 0);
			}],
			["gen_2b_connector", 0.5, 'show', {
				element: 'elec_ac_gen_2b_connector',
				invert: 0
			}],
			['ac_bus_bus_1b', 0.5, 'function', func(bus) {
				if (bus) {
					me.page_svg_items['elec_ac_1b_115_text'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_1b_230_text'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_1b_diamond'].show();
				} else {
					me.page_svg_items['elec_ac_1b_115_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_1b_230_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_1b_diamond'].hide();
				}
			}],
			['ac_bus_bus_2a', 0.5, 'function', func(bus) {
				if (bus) {
					me.page_svg_items['elec_ac_2a_115_text'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_2a_230_text'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_2a_diamond'].show();
				} else {
					me.page_svg_items['elec_ac_2a_115_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_2a_230_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_2a_diamond'].hide();
				}
			}],
			['ac_bus_bus_2b', 0.5, 'function', func(bus) {
				if (bus) {
					me.page_svg_items['elec_ac_2b_115_text'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_2b_230_text'].setColor(0, 1, 0);
					me.page_svg_items['elec_ac_2b_diamond'].show();
				} else {
					me.page_svg_items['elec_ac_2b_115_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_2b_230_text'].setColor(187 / 255, 97 / 255, 0);
					me.page_svg_items['elec_ac_2b_diamond'].hide();
				}
			}],
		]);
		var elec_dc_page = ecam_sd_page.new(me, group, 'elec_dc', {
			bat_emer_2: {
				switch: props.globals.getNode('/controls/electric/batteries/bat-emer-2'),
				voltage: props.globals.getNode('/systems/electrical/batteries/bat-2-voltage'),
				amps: props.globals.getNode('/systems/electrical/batteries/bat-2-amps')
			}
		}, ['elec_dc_bat_emer_2_off', 'elec_dc_bat_emer_2_stats'], [], 
		[
			['bat_emer_2_switch', 0.5, 'show', [{
				element: 'elec_dc_bat_emer_2_stats', 
				invert: 0
			},
			{
				element: 'elec_dc_bat_emer_2_off', 
				invert: 1
			}]]
		]);
		#me.pages['hyd'] = hyd_page.new(display, group);
		me.pages['apu'] = apu_page;
		me.pages['elec_ac'] = elec_ac_page;
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
