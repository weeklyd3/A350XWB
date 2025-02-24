var mfd = {
	new: func(name) {
		print('creating mfd with name', name);
		var display = canvas.new({
			"name": name,   # The name is optional but allow for easier identification
			"size": [2048, 2048], # Size of the underlying texture (should be a power of 2, required) [Resolution]
			"view": [449, 600],  # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
						# which will be stretched the size of the texture, required)
			"mipmapping": 1       # Enable mipmapping (optional)
		});
		var returned = {parents: [mfd]};
		returned.app = '';
		returned.section = '';
		returned.page = '';
		returned.display = display;
		returned.svg_items = {};
		var path = "Aircraft/A350XWB/Models/Instruments/MFD/res/fms.svg";
		var page_prefix = "Aircraft/A350XWB/Models/Instruments/MFD/res/";
		# create an image child
		var group = display.createGroup('svg');
		returned.group = group;
		var parse_options = {'font-mapper': func(doesnt, matter) { return 'ECAMFontRegular.ttf'; }};
		canvas.parsesvg(group, path, parse_options);

		var fms = group.getElementById('fms');
		canvas.parsesvg(fms, page_prefix ~ "fms/init"           ~ ".svg", parse_options);
		canvas.parsesvg(fms, page_prefix ~ "fms/fuelload"       ~ ".svg", parse_options);
		canvas.parsesvg(fms, page_prefix ~ "fms/perf_to"        ~ ".svg", parse_options);

		returned.setApp(returned, 'fms');
		returned.setPage(returned, 'init');
		foreach (item; ['cursor', 'mfd']) returned.svg_items[item] = group.getElementById(item);
		returned.svg_items.cursor.addEventListener('mouseenter', func() { print('bruh'); });
		returned.svg_items.cursor.addEventListener('mouseleave', func() { print('bruh leave'); });
		display.addEventListener('click', func() {
			if (returned.active == nil) return;
			returned.active.blur(returned.active);
			returned.active = nil;
		});
		returned.active = nil;
		setlistener("/devices/status/keyboard/event", func(node) {
			if (!node.getNode('pressed').getValue()) return;
			var keyCode = node.getNode('key').getValue();
			if (returned.active == nil) return;
			if (!returned.active.supportsKeyboard) return;
			if (keyCode == 8 or keyCode == 127) {
				# BACKSPACE or DELETE
				returned.active.input_value = substr(returned.active.input_value, 0, size(returned.active.input_value) - 1);
			} elsif (keyCode == 10 or keyCode == 13) {
				# ENTER
				returned.active.blur(returned.active);
				returned.active.active = 0;
				returned.active = nil;
				setprop("/devices/status/keyboard/event/key", -1);
				return;
			} else {
				var key = string.uc(chr(keyCode));
				var valid_key = 0;
				# idk any better way to do this, so here we go
				if ((key == 'A' or key == 'B' or key == 'C' or key == 'D' or
				     key == 'E' or key == 'F' or key == 'G' or key == 'H' or
				     key == 'I' or key == 'J' or key == 'K' or key == 'L' or
				     key == 'M' or key == 'N' or key == 'O' or key == 'P' or
				     key == 'Q' or key == 'R' or key == 'S' or key == 'T' or
				     key == 'U' or key == 'V' or key == 'W' or key == 'X' or
				     key == 'Y' or key == 'Z') and returned.active.options.letters) valid_key = 1;
				if ((key == '1' or key == '2' or key == '3' or key == '4' or 
				     key == '5' or key == '6' or key == '7' or key == '8' or 
				     key == '9' or key == '0') and
				     returned.active.options.numbers) valid_key = 1;
				if ((key == '.' or key == '-') and returned.active.options.punctuation)
					valid_key = 1;
				debug.dump(key, valid_key);
				if (valid_key) returned.active.input_value ~= key;
				else return;
			}
			debug.dump(returned.active.input_value);
			returned.active.update(returned.active, returned.active.input_value, returned.active.input_value);
			setprop("/devices/status/keyboard/event/key", -1);
		});
		
		returned.widgets = [
			# fms -> init
			button.new(returned, group, 'acft_status', func(ret) { print('hi'); }),
			button.new(returned, group, 'init_fuelload', func(ret) { ret.setPage(ret, 'fuelload'); }),
			button.new(returned, group, 'init_to_perf', func(ret) { ret.setPage(ret, 'perf_to'); }),
			field.new(returned, group, 'from_airport', '/autopilot/route-manager/departure/airport', {}),
			field.new(returned, group, 'to_airport', '/autopilot/route-manager/destination/airport', {}),
			field.new(returned, group, 'altn_airport', '/autopilot/route-manager/alternate/airport', {}),
			field.new(returned, group, 'flt_nbr', '/fms/config/flight-number', { default: "" }),
			numeric_field.new(returned, group, 'crz_fl', '/fms/config/crz-fl', {letters: 0, punctuation: 0, format: "%d", default: "", numeric: 1}),
			numeric_field.new(returned, group, 'tropo', '/fms/config/tropo', {letters: 0, punctuation: 0, format: "%d", default: "36090", numeric: 1}),
			numeric_field.new(returned, group, 'ci', '/fms/config/ci', {punctuation: 0, format: "%d", default: ""}),
			dropdown.new(returned, group, "init_mode", '/fms/config/mode', {
				options: ['econ', 'lrc']
			}),
			# fms -> fuel&load
			# fms -> to perf
			dropdown.new(returned, group, "perf_to_flaps", '/fms/perf/takeoff/flaps', {
				options: ['1', '2', '3']
			}),
			dropdown.new(returned, group, "perf_to_packs", '/fms/perf/takeoff/packs', {
				options: ['off', 'on'],
				alias: {
					'off': 'off/apu'
				}
			}),
			dropdown.new(returned, group, "perf_to_ai", '/fms/perf/takeoff/anti-ice', {
				options: ['off', 'eai', 'both'],
				alias: {
					'eai': 'eng only',
					'both': 'eng+wing'
				}
			}),
			numeric_field.new(returned, group, 'perf_to_shift', '/fms/perf/takeoff/shift', {letters: 0, punctuation: 0, format: "%d", default: "0", numeric: 1}),
			numeric_field.new(returned, group, 'perf_to_ths', '/fms/perf/takeoff/ths', {letters: 0, punctuation: 1, format: "%.1f", default: "", numeric: 1}),
			numeric_field.new(returned, group, 'perf_to_v1', '/fms/perf/takeoff/v1', {letters: 0, punctuation: 0, format: "%d", default: '', numeric: 1}),
			numeric_field.new(returned, group, 'perf_to_vr', '/fms/perf/takeoff/vr', {letters: 0, punctuation: 0, format: "%d", default: '', numeric: 1}),
			numeric_field.new(returned, group, 'perf_to_v2', '/fms/perf/takeoff/v2', {letters: 0, punctuation: 0, format: "%d", default: '', numeric: 1}),
			numeric_field.new(returned, group, 'perf_to_eo_accel', '/fms/perf/takeoff/eo-accel', {letters: 0, punctuation: 0, format: "%d", default: "1000", numeric: 1}),
			numeric_field.new(returned, group, 'perf_to_trans', '/fms/perf/transition-altitude', {letters: 0, punctuation: 0, format: "%d", default: "18000", numeric: 1}),
			numeric_field.new(returned, group, 'perf_to_flex_temp', '/fms/perf/takeoff/flex-temp', {letters: 0, punctuation: 0, format: "%d", default: "", numeric: 1}),
			dropdown.new(returned, group, "perf_to_derate", '/fms/perf/takeoff/derate', {
				options: ['4', '8', '12', '16', '20', '24'],
				alias: {
					'4': 'D04',
					'8': 'D08',
					'12': 'D12',
					'16': 'D16',
					'20': 'D20',
					'24': 'D24'
				}
			}),
			radio.new(returned, group, "perf_to_thrust", '/fms/perf/takeoff/thrust', {
				options: ['toga', 'flex', 'derated'],
				alias: {
					'toga': 0,
					'flex': 1,
					'derated': 2
				}
			}),
		];
		display.addEventListener('mousemove', func(ev) {
			returned.svg_items.cursor.setTranslation(ev.clientX, ev.clientY);
		});
		display.addPlacement({"node": name, "capture-events": 1});
		return returned;
	},
	setActive: func(returned, item) {
		if (returned.active != nil) {
			returned.active.blur(returned.active);
			returned.active.active = 0;
		}
		item.active = 1;
		item.selected(item);
		returned.active = item;
	},
	setApp: func(returned, app) {
		var apps = ['fms'];
		returned.app = app;
		returned.activeApp = returned.group.getElementById(app);
		foreach (var name; apps) {
			if (name != app) returned.group.getElementById(name).hide();
			else returned.group.getElementById(name).show();
		}
	},
	setPage: func(returned, page) {
		var pages = {
			'fms': ['init', 'fuelload', 'perf_to']
		};
		var activePages = pages[returned.app];
		foreach (var name; activePages) {
			if (name != page) returned.group.getElementById(name).hide();
			else returned.group.getElementById(name).show();
		}
	}
};
var show = func(mfd) {
	var window = canvas.Window.new([889 / 2, 564], "dialog").set("resize", 1);
	window.setCanvas(mfd.display);
}
var plan = flightplan();
var button = {
	new: func(parent, group, element, function) {
		var ret = {parents: [button]};
		ret.element = group.getElementById(element);
		ret.frame = group.getElementById(element ~ '_frame');
		ret.parent = parent;
		ret.element.addEventListener('mouseenter', func() {
			# 157, 157, 157
			ret.frame.setColorFill(0.615686275, 0.615686275, 0.615686275);
		});
		ret.element.addEventListener('mouseleave', func() {
			# 59, 59, 59
			ret.frame.setColorFill(0.23137254902, 0.23137254902, 0.23137254902);
		});
		ret.element.addEventListener('click', func() { function(parent); });
		return ret;
	}
};
var cursor_character = ""; #"█";
# DON'T TOUCH THIS FIELD CLASS!!!
# IDK HOW IT WORKS ANYMORE AND BROKE IT TOO MANY TIMES
var field = {
	new: func(parent, group, element, prop, extra_options = nil) {
		var new_options = {
			format: nil,
			letters: 1,
			numbers: 1,
			punctuation: 1,
			default: ''
		};
		if (extra_options != nil) {
			foreach (k; keys(extra_options)) {
				new_options[k] = extra_options[k];
			}
		}
		var ret = {parents: [field]};
		ret.element = group.getElementById(element);
		ret.supportsKeyboard = 1;
		ret.elementName = element;
		ret.parent = parent;
		ret.element.addEventListener('click', func(ev) {
			ev.stopPropagation();
			parent.setActive(parent, ret);
			#if (!ret.options.noAlign) ret.text.setAlignment('left-center');
			ret.frame.setColor(0, 1, 1);
			ret.empty.hide();
			ret.text.show();
			ret.text.updateText(ret.input_value ~ cursor_character);
		});
		ret.text = group.getElementById(element ~ "_data");
		ret.text.enableUpdate();
		ret.frame = group.getElementById(element ~ "_frame");
		ret.element.addEventListener('mouseenter', func() {
			ret.frame.setColor(0, 1, 1);
		});
		ret.element.addEventListener('mouseleave', func() {
			if (ret.active) return;
			ret.frame.setColor(1, 1, 1);
		});
		ret.empty = group.getElementById(element ~ "_empty");
		var default = new_options.default;
		if (prop) {
			ret.prop = props.globals.getNode(prop);
			if (ret.prop == nil) {
				ret.prop = props.globals.initNode(prop, new_options.default);
			}
			ret.value = ret.prop.getValue() ~ "";
		} else {
			ret.value = extra_options.get();
			ret.prop = nil;
		}
		ret.active = 0;
		ret.options = new_options;
		ret.update(ret, ret.value, ret.options.default);
		ret.input_value = default ~ "";
		return ret;
	},
	blur: func(ret) {
		ret.active = 0;
		var format = ret.options.format;
		debug.dump(format);
		if (format == nil) var formatted = ret.input_value;
		else var formatted = sprintf(format, ret.input_value);
		var default = ret.options.default;
		if (ret.prop != nil) ret.prop.setValue(formatted);
		else ret.options.set(ret.value);
		ret.update(ret, formatted, ret.input_value);
		ret.frame.setColor(1, 1, 1);
	},
	selected: func(ret) {},
	update: func(ret, formatted, input) {
		#var format = ret.options.format;
		#if (ret.options.numeric and value == "") value = "0";
		#if (format != nil) var formatted = sprintf(format, value);
		#else var formatted = value ~ "";
		#ret.input_value = formatted;
		formatted = formatted;
		ret.value = formatted;
		debug.dump(formatted);
		if (ret.active) {
			ret.text.updateText(formatted ~ cursor_character);
			return;
		}
		if (size(formatted) == 0) {
			ret.text.hide();
			ret.empty.show();
		} else {
			ret.empty.hide();
			ret.text.show();
		}
		ret.text.updateText(string.uc(formatted));
	}
};
var numeric_field = {
	new: func(parent, group, element, prop, extra_options = nil) {
		var new_options = {
			format: nil,
			punctuation: 1,
			default: '',
			numbers: 1,
			letters: 0
		};
		if (extra_options != nil) {
			foreach (k; keys(extra_options)) {
				new_options[k] = extra_options[k];
			}
		}
		var ret = {parents: [numeric_field]};
		ret.element = group.getElementById(element);
		ret.supportsKeyboard = 1;
		ret.elementName = element;
		ret.parent = parent;
		ret.element.addEventListener('click', func(ev) {
			ev.stopPropagation();
			parent.setActive(parent, ret);
			ret.frame.setColor(0, 1, 1);
			ret.empty.hide();
			ret.text.show();
			ret.text.updateText(ret.input_value ~ cursor_character);
		});
		ret.text = group.getElementById(element ~ "_data");
		ret.text.enableUpdate();
		ret.frame = group.getElementById(element ~ "_frame");
		ret.element.addEventListener('mouseenter', func() {
			ret.frame.setColor(0, 1, 1);
		});
		ret.element.addEventListener('mouseleave', func() {
			if (ret.active) return;
			ret.frame.setColor(1, 1, 1);
		});
		ret.empty = group.getElementById(element ~ "_empty");
		var default = new_options.default;
		if (num(default) == nil) {
			default = 0;
			ret.empty.show();
			ret.text.hide();
		} else {
			ret.empty.hide();
		}
		if (prop) {
			ret.prop = props.globals.getNode(prop);
			if (ret.prop == nil or ret.prop.getValue() == nil) {
				ret.prop = props.globals.initNode(prop, default, 'DOUBLE');
			}
			ret.value = ret.prop.getValue() ~ "";
		}
		ret.active = 0;
		ret.options = new_options;
		ret.update(ret, ret.value);
		ret.input_value = new_options.default ~ "";
		return ret;
	},
	update: func(ret, value) {
		# here we actually need to use setText rather than updateText
		# when i enter 1 and press the period key, it thinks 1. is identical
		# to 1 so it doesn't update if i use updatetext
		if (ret.active) {
			ret.text.setText(value ~ cursor_character);
			return;
		}
		if (num(value) == nil) {
			ret.text.hide();
			ret.empty.show();
			return;
		}
		if (ret.options.format) var formatted = sprintf(ret.options.format, value);
		else var formatted = value;
		ret.text.setText(formatted);
		return formatted;
	},
	blur: func(ret) {
		ret.active = 0;
		var formatted = ret.update(ret, ret.input_value);
		if (formatted != nil and formatted != 'nil') ret.prop.setDoubleValue(formatted);
		else {
			if (num(ret.options.default) == nil) ret.prop.setDoubleValue(0);
			else ret.prop.setDoubleValue(ret.options.default);
		}
		ret.value = ret.input_value;
		ret.frame.setColor(1, 1, 1);
	},
	selected: func(ret) {},
};
var dropdown = {
	new: func(parent, group, element, prop, extra_options = nil) {
		var ret = {parents: [dropdown]};
		var new_options = {
			default: extra_options.options[0],
		};
		if (extra_options != nil) {
			foreach (k; keys(extra_options)) {
				new_options[k] = extra_options[k];
			}
		}
		ret.elementName = element;
		ret.parent = parent;
		ret.supportsKeyboard = 0;
		ret.element = group.getElementById(element);
		ret.parent = parent;
		ret.option_list = group.getElementById(element ~ "_options");
		ret.option_list.hide();
		ret.choices = {};
		ret.prop = props.globals.getNode(prop);
		if (ret.prop == nil) {
			ret.prop = props.globals.initNode(prop, new_options.default);
		}
		foreach (var opt; extra_options.options) {
			ret.choices[opt] = group.getElementById(element ~ "_option_" ~ opt);
			me.makeOption(ret, group, opt, extra_options);
		}
		ret.element.addEventListener('click', func(ev) {
			ev.stopPropagation();
			parent.setActive(parent, ret);
			ret.frame.setColor(0, 1, 1);
			ret.text.updateText(string.uc(ret.display_value));
		});
		ret.text = group.getElementById(element ~ "_data");
		ret.text.enableUpdate();
		ret.frame = group.getElementById(element ~ "_frame");
		ret.element.addEventListener('mouseenter', func() {
			ret.frame.setColor(0, 1, 1);
		});
		ret.element.addEventListener('mouseleave', func() {
			if (ret.active) return;
			ret.frame.setColor(1, 1, 1);
		});
		ret.options = new_options;
		ret.active = 0;
		ret.value = ret.options.default;
		var display_value = ret.value;
		if (contains(extra_options, 'alias')) {
			if (contains(extra_options.alias, ret.value)) display_value = extra_options.alias[ret.value];
		}
		ret.display_value = display_value;
		return ret;
	},
	blur: func(ret) {
		ret.parent.active = nil;
		ret.text.updateText(string.uc(ret.display_value ~ ""));
		ret.prop.setValue(ret.value);
		ret.active = 0;
		ret.option_list.hide();
		ret.frame.setColor(1, 1, 1);
	},
	selected: func(ret) {
		ret.option_list.show();
	},
	makeOption: func(object, group, option, extra_options) {
		var element = group.getElementById(object.elementName ~ "_option_" ~ option);
		var frame = group.getElementById(object.elementName ~ "_option_" ~ option ~ "_frame");
		var display_value = option;
		if (contains(extra_options, 'alias')) {
			if (contains(extra_options.alias, option)) display_value = extra_options.alias[option];
		}
		me.display_value = display_value;
		element.addEventListener('mouseenter', func() {
			frame.setColor(0, 1, 1);
		});
		element.addEventListener('mouseleave', func() {
			# 102, 102, 102
			frame.setColor(0.4, 0.4, 0.4);
		});
		element.addEventListener('click', func(ev) {
			object.value = option;
			object.display_value = display_value;
			print('blurring');
			object.blur(object);
			ev.stopPropagation();
		});
	}
};
var radio = {
	new: func(parent, group, element, prop, extra_options = nil) {
		var ret = {parents: [radio]};
		var new_options = {
			default: extra_options.options[0],
			alias: {}
		};
		if (extra_options != nil) {
			foreach (k; keys(extra_options)) {
				new_options[k] = extra_options[k];
			}
		}
		ret.new_options = new_options;
		ret.elementName = element;
		ret.parent = parent;
		ret.supportsKeyboard = 0;
		ret.element = group.getElementById(element);
		ret.parent = parent;
		ret.choices = {};
		ret.prop = props.globals.getNode(prop);
		var default = new_options.default;
		if (contains(new_options.alias, default)) default = new_options.alias[default];
		if (ret.prop == nil) ret.prop = props.globals.initNode(prop, default);
		foreach (var opt; extra_options.options) {
			ret.choices[opt] = group.getElementById(element ~ "_" ~ opt ~ "_button");
			me.makeOption(ret, group, opt, extra_options);
		}
		ret.options = new_options;
		ret.active = 0;
		ret.value = ret.options.default;
		ret.update(ret, group);
		return ret;
	},
	update: func(object, group) {
		debug.dump(object.value);
		foreach (option; object.new_options.options) {
			var button = object.choices[option];
			if (option != object.value) button.hide();
			else button.show();
		}
	},
	blur: func(ret) {
		return;
	},
	selected: func(ret) {
		return;
	},
	makeOption: func(object, group, option, extra_options) {
		var option_element = group.getElementById(object.elementName ~ "_" ~ option);
		option_element.addEventListener('click', func(ev) {
			object.value = option;
			var value = object.value;
			if (contains(object.new_options.alias, value)) value = object.new_options.alias[value];
			object.prop.setValue(value);
			object.update(object, group);
		});
	}
};
var clear = func() {
	props.globals.getNode('/autopilot/route-manager/route/wp').clearValue();
	var plan = createFlightplan();
	var ppos = createWP(geo.aircraft_position().lat(), geo.aircraft_position().lon(), "PPOS");
	plan.insertWP(ppos, 0);
	plan.activate();
};
print('trying to clear flightplan');
setprop('/autopilot/route-manager/route/num', 0);
setprop('/autopilot/route-manager/departure/airport', '');
var timer = maketimer(1, clear);
timer.singleShot = 1;
timer.start();
var mfd_l = mfd.new('mfd1');