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
		var path = "Aircraft/A350XWB/Models/Instruments/Upper-ECAM/ecam.svg";
		# create an image child
		var group = display.createGroup('svg');
		canvas.parsesvg(group, path);
		foreach (elem; ["thr_text_l", "thr_needle_l", "donut_l", "thr_text_r", "thr_needle_r", "donut_r", "n1_left", "n1_right", "tat_temp", "sat_temp", "isa_temp", "utc"]) {
			me.svg_items[elem] = group.getElementById(elem);
		}
		foreach (elem; ["thr_text_l", "thr_text_r", "n1_left", "n1_right", "tat_temp", "sat_temp", "isa_temp", "utc"]) {
			print(elem);
			print(me.svg_items[elem]);
			me.svg_items[elem].enableUpdate();
		}
		me.svg_items["thr_needle_l"].setCenter(150.485, 75.63);
		me.svg_items["thr_needle_r"].setCenter(150.485, 75.63);
		me.svg_items["donut_l"].setCenter(150.485, 75.63);
		me.svg_items["donut_r"].setCenter(292.486, 75.63);
		setlistener("engines/engine/thr", func(value) {
			var thr = value.getValue();
			me.svg_items.thr_text_l.updateText(sprintf("%.1f", math.round(thr * 10) / 10));
			me.svg_items.thr_needle_l.setRotation((-120 + 210 * thr / 100) * math.pi / 180);
		}, 1, 0);
		setlistener("engines/engine[1]/thr", func(value) {
			var thr = value.getValue();
			me.svg_items.thr_text_r.updateText(sprintf("%.1f", math.round(thr * 10) / 10));
			me.svg_items.thr_needle_r.setRotation((-120 + 210 * thr / 100) * math.pi / 180);
		}, 1, 0);
		setlistener("engines/engine/n1", func(value) {
			var n1 = value.getValue();
			me.svg_items.n1_left.updateText(sprintf("%.1f", n1));
		});
		setlistener("engines/engine[1]/n1", func(value) {
			var n1 = value.getValue();
			me.svg_items.n1_right.updateText(sprintf("%.1f", n1));
		});
		setlistener("instrumentation/clock/indicated-string", func(value) {
			me.svg_items.utc.updateText(value.getValue());
		});
		me.pages['hyd'] = hyd_page.new(display, group);
		display.addPlacement({"node": name});
	},
	pages: {},
	svg_items: {}
};
var hyd_page = {
	new: func(draw, svg_group) {
		me.canvas = draw;
		foreach (elem; ["yellow_quantity", "green_quantity"]) {
			me.svg_items[elem] = svg_group.getElementById(elem);
		}
		foreach (elem; ["green", "yellow"]) {
			foreach (elem2; ["supply", "pump"]) {
				foreach (elem3; ["on", "off"]) {
					foreach (elem4; ["eng1", "eng2"]) {
						var name = elem4 ~ elem ~ elem2 ~ "_" ~ elem3;
						me.svg_items[name] = svg_group.getElementById(name);
					}
				}
			}
		}
	},
	svg_items: {}
};
var upper_ecam = ecam.new('upper_ecam');