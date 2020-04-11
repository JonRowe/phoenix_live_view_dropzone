'use strict';

const setup = ({node, generateUrl, onStatusUpdate}) => {
  var app = Elm.Main.init({flags: {}, node: document.getElementById(node)});

  app.ports.requestUrl.subscribe(function(fileId) {
    app.ports.addUploadUrl.send(generateUrl(fileId));
  });

  app.ports.notifyUploadStatus.subscribe(onStatusUpdate);
};

var target;

if (typeof(module) != "undefined") {
  target = module.exports;
} else {
  target = this;
}

target.PhoenixLiveViewDropzone = {setup: setup};
