#======
# INIT
#======

Engines = {};

Engines.new = func {
  var obj = {
    parents : [Engines],
  };
  
  obj.init();
  
  return obj;
}

Engines.init = func {
  me.startengine = {0:0, 1:0};
  setlistener("/engines/engine/start-ready", func(node) {
    if (node.getValue()) {
      print('starting engine 1');
      me.startengine[0] = 1;
    } else {
      me.startengine[0] = 0;
    }
  }, 0, 0);
  setlistener("/engines/engine[1]/start-ready", func(node) {
    if (node.getValue()) {
      print('starting engine 2');
      me.startengine[1] = 1;
    } else {
      me.startengine[0] = 0;
    }
  }, 0, 0);
  if (getprop("/controls/engines/autostarted")) {
    setprop("/controls/engines/autostarted", 0);
    setprop("/controls/engines/engine/master", 1);
    setprop("/controls/engines/engine[1]/master", 1);
  }
}

Engines.autostart = func {
  setprop('/controls/electric/batteries/bat-1', 1);
  setprop('/controls/electric/batteries/bat-2', 1);
  setprop('/controls/electric/batteries/bat-emer-1', 1);
  setprop('/controls/electric/batteries/bat-emer-2', 1);
  setprop("/controls/engines/autostart", 1);
  setprop("/controls/engine-mode-switch", 2);
  setprop("/controls/engines/engine/master", 1);
  setprop("/controls/engines/engine[1]/master", 1);
  return;
  if ( ! getprop('/engines/engine[0]/running') ) {
    me.startengine[0] = 1;
  }
  if ( ! getprop('/engines/engine[1]/running') ) {
    me.startengine[1] = 1;
  }
}

Engines.schedule = func {
  if ( me.startengine[0] ) {
    if ( ! getprop('/engines/engine[0]/starter') ) {
      setprop('/controls/engines/engine[0]/starter', 1);
    }
    if ( getprop('/engines/engine[0]/n2') > 5 ) {
      if ( getprop('/controls/engines/engine[0]/cutoff' ) ) {
        setprop('/controls/engines/engine[0]/cutoff', 0);
      }
    } else {
      if ( ! getprop('/controls/engines/engine[0]/cutoff' ) ) {
        setprop('/controls/engines/engine[0]/cutoff', 1);
      }
    }
    if ( getprop('/engines/engine[0]/n2') >= 60 )  {
      me.startengine[0] = 0;
      setprop('/controls/engines/engine[0]/starter', 0);
      setprop("/controls/engines/autostart", 1);
    }
  } else {
    if (getprop("/controls/engines/engine/master") == 0) {
      setprop('/controls/engines/engine[0]/cutoff', 1);
    } else {
      setprop('/controls/engines/engine[0]/cutoff', 0);
    }
  }
  if ( me.startengine[1] ) {
    if ( ! getprop('/engines/engine[1]/starter') ) {
      setprop('/controls/engines/engine[1]/starter', 1);
    }
    if ( getprop('/engines/engine[1]/n2') > 5 ) {
      if ( getprop('/controls/engines/engine[1]/cutoff' ) ) {
        setprop('/controls/engines/engine[1]/cutoff', 0);
      }
    } else {
      if ( ! getprop('/controls/engines/engine[1]/cutoff' ) ) {
        setprop('/controls/engines/engine[1]/cutoff', 1);
      }
    }
    if ( getprop('/engines/engine[1]/n2') >= 60 ) {
      me.startengine[1] = 0;
      setprop('/controls/engine[1]/starter', 0);
      setprop("/controls/engines/autostart", 1);
    }
  } else {
    if (getprop("/controls/engines/engine[1]/master") == 0) {
      setprop('/controls/engines/engine[1]/cutoff', 1);
    } else {
      setprop('/controls/engines/engine[1]/cutoff', 0);
    }
  }
}
