setlistener('/sim/signals/fdm-initialized', func() {
	var wow = getprop('/fdm/jsbsim/gear/wow');
	var autostart = getprop('/sim/autostart');
	print('wow');
	debug.dump(wow);
	print('autostart');
	debug.dump(autostart);
	if (autostart or !wow) {
		print('AUTOSTARTING!!!');
		#setprop('/controls/engines/engine/master-switch', 1);
		#setprop('/controls/engines/engine[1]/master-switch', 1);
		setprop('/engines/engine/running', 1);
		setprop('/engines/engine[1]/running', 1);
		setprop('/controls/electric/batteries/bat-1', 1);
		setprop('/controls/electric/batteries/bat-2', 1);
		setprop('/controls/electric/batteries/bat-emer-1', 1);
		setprop('/controls/electric/batteries/bat-emer-2', 1);
	}
});