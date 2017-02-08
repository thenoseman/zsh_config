var leftScreenRef = "0";
var rightScreenRef = "1";

slate.config("orderScreensLeftToRight", true);
slate.config("defaultToCurrentScreen", true);

var corner = function(divider, corner, screenId) {
  if(typeof corner === "undefined") {
    corner = "top-left";
  }

  if(typeof screenId === "undefined") {
    screenId = leftScreenRef;
  }

  return slate.operation("corner", {
    "direction": corner,
    "width": "screenSizeX/" + divider,
    "height": "screenSizeY",
    "screen": screenId
  });
};

var ifWindowTitle = function(regex, operationFunc, elseOperationFunc) {
  return function(windowObject) {
    if(regex.test(windowObject.title())) {
      windowObject.doOperation(operationFunc);
      return;
    }

    if(typeof elseOperationFunc === "function") {
      windowObject.doOperation(elseOperationFunc);
    }
  };
};

var opHangouts = slate.operation("move", {
  "x" : "screenOriginX+647",
  "y" : "0",
  "width" : "623",
  "height" : "471",
  "screen" : rightScreenRef
});

var opToTop = slate.operation("focus", {
  "direction" : "above"
});

var twoMonitorLayout = slate.layout("twoMonitors", {
  "Google Chrome": {
    "operations": [ ifWindowTitle(/Videoanruf/, opHangouts, corner("3*2")), ifWindowTitle(/Videoanruf/, opToTop) ],
    "ignore-fail" : true,
    "repeat" : true
  },
  "MacVim": {
    "operations": [ corner("3*2") ]
  },
  "iTerm2": {
    "operations": [ corner("3", "top-right") ]
  },
  "Slack": {
    "operations": [ corner("3", "top-left", rightScreenRef) ]
  },
  "Microsoft Outlook": {
    "operations": [ corner("3*2", "top-right", rightScreenRef) ]
  }
});

slate.bind("1:cmd;shift", corner("3*2"));
slate.bind("2:cmd;shift", corner("3", "top-right"));
slate.bind("3:cmd;shift", corner("2"));
slate.bind("4:cmd;shift", corner("2", "top-right"));
slate.bind("9:cmd;shift", slate.operation("layout", { "name" : twoMonitorLayout }));

slate.default(["2560x1440","2560x1440"], twoMonitorLayout);
