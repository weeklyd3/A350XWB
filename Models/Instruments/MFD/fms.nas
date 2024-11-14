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
		# create an image child
		var group = display.createGroup('svg');
		returned.group = group;
		canvas.parsesvg(group, path, {'font-mapper': func(doesnt, matter) { return 'ECAMFontRegular.ttf'; }});
		returned.setApp(returned, 'fms');
		returned.setSection(returned, 'active');
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
			print(keyCode);
			if (returned.active == nil) return;
			if (!returned.active.supportsKeyboard) return;
			if (keyCode == 8 or keyCode == 127) {
				# BACKSPACE or DELETE
				returned.active.value = substr(returned.active.value, 0, size(returned.active.value) - 1);
			} elsif (keyCode == 10 or keyCode == 13) {
				# ENTER
				print('ENTER!!!');
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
				if (valid_key) returned.active.value ~= key;
				else return;
			}
			returned.active.update(returned.active, returned.active.value);
			setprop("/devices/status/keyboard/event/key", -1);
		});
		button.new(returned, group, 'acft_status', func(ret) { print('hi'); });
		button.new(returned, group, 'init_fuelload', func(ret) { ret.setPage(ret, 'fuelload'); });
		returned.widgets = [
			field.new(returned, group, 'from_airport', '/autopilot/route-manager/departure/airport', {}),
			field.new(returned, group, 'to_airport', '/autopilot/route-manager/destination/airport', {}),
			field.new(returned, group, 'altn_airport', '/autopilot/route-manager/alternate/airport', {}),
			field.new(returned, group, 'flt_nbr', '/fms/config/flight-number', { default: "" }),
			field.new(returned, group, 'crz_fl', '/autopilot/route-manager/cruise/flight-level', {letters: 0, punctuation: 0, format: "%d", numeric: 1}),
			field.new(returned, group, 'tropo', '/fms/config/tropo', {letters: 0, punctuation: 0, format: "%d", default: "36090", numeric: 1}),
			field.new(returned, group, 'ci', '/fms/config/ci', {letters: 0, punctuation: 0, format: "%d", default: "0", numeric: 1}),
			dropdown.new(returned, group, "init_mode", '/fms/config/mode', {
				options: ['econ', 'lrc']
			})
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
	setSection: func(returned, section) {
		var sections = {
			fms: ['active']
		};
		returned.section = section;
		var activeSections = sections[returned.app];
		foreach (var name; activeSections) {
			if (name != section) returned.group.getElementById(name).hide();
			else returned.group.getElementById(name).show();
		}
	},
	setPage: func(returned, page) {
		var pages = {
			'fms/active': ['init', 'fuelload']
		};
		var activePages = pages[returned.app ~ "/" ~ returned.section];
		foreach (var name; activePages) {
			if (name != page) returned.group.getElementById(name).hide();
			else returned.group.getElementById(name).show();
		}
	}
};
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
var field = {
	new: func(parent, group, element, prop, extra_options = nil) {
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
			ret.text.updateText(ret.value ~ cursor_character);
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
		if (prop) {
			ret.prop = props.globals.getNode(prop);
			if (ret.prop == nil) {
				setprop(prop, extra_options.default);
				ret.prop = props.globals.getNode(prop);
			}
			ret.value = ret.prop.getValue() ~ "";
		} else {
			ret.value = extra_options.get();
			ret.prop = nil;
		}
		var new_options = {
			format: nil,
			letters: 1,
			numbers: 1,
			numeric: 0,
			punctuation: 1
		};
		if (extra_options != nil) {
			foreach (k; keys(extra_options)) {
				new_options[k] = extra_options[k];
			}
		}
		ret.options = new_options;
		ret.active = 0;
		ret.update(ret, ret.value, ret.options.format);
		return ret;
	},
	blur: func(ret) {
		ret.active = 0;
		if (ret.prop != nil) ret.prop.setValue(ret.value);
		else ret.options.set(ret.value);
		ret.update(ret, ret.value, ret.options.format);
		ret.frame.setColor(1, 1, 1);
	},
	selected: func(ret) {},
	update: func(ret, value) {
		var format = ret.options.format;
		if (ret.options.numeric and value == "") value = "0";
		if (format != nil) var formatted = sprintf(format, value);
		else var formatted = value ~ "";
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
var dropdown = {
	new: func(parent, group, element, prop, extra_options = nil) {
		var ret = {parents: [dropdown]};
		ret.elementName = element;
		ret.parent = parent;
		ret.supportsKeyboard = 0;
		ret.element = group.getElementById(element);
		ret.parent = parent;
		ret.option_list = group.getElementById(element ~ "_options");
		ret.option_list.hide();
		ret.choices = {};
		foreach (var opt; extra_options.options) {
			ret.choices[opt] = group.getElementById(element ~ "_option_" ~ opt);
			me.makeOption(ret, group, opt);
		}
		ret.element.addEventListener('click', func(ev) {
			ev.stopPropagation();
			parent.setActive(parent, ret);
			ret.frame.setColor(0, 1, 1);
			ret.text.updateText(string.uc(ret.value));
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
		var new_options = {
			default: extra_options.options[0]
		};
		if (extra_options != nil) {
			foreach (k; keys(extra_options)) {
				new_options[k] = extra_options[k];
			}
		}
		ret.options = new_options;
		ret.active = 0;
		ret.value = ret.options.default;
		return ret;
	},
	blur: func(ret) {
		ret.parent.active = nil;
		ret.text.updateText(string.uc(ret.value));
		ret.active = 0;
		ret.option_list.hide();
		ret.frame.setColor(1, 1, 1);
	},
	selected: func(ret) {
		ret.option_list.show();
	},
	makeOption: func(object, group, option) {
		var element = group.getElementById(object.elementName ~ "_option_" ~ option);
		var frame = group.getElementById(object.elementName ~ "_option_" ~ option ~ "_frame");
		element.addEventListener('mouseenter', func() {
			frame.setColor(0, 1, 1);
		});
		element.addEventListener('mouseleave', func() {
			# 102, 102, 102
			frame.setColor(0.4, 0.4, 0.4);
		});
		element.addEventListener('click', func(ev) {
			object.value = option;
			print('blurring');
			object.blur(object);
			ev.stopPropagation();
		});
	}
};
var plan = flightplan();
var mfd_l = mfd.new('mfd1');