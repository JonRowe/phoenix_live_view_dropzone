'use strict';

import { Elm } from "./Main.elm";

const eventName = "phx-dropzone";

export class PhoenixLiveViewDropzone {
  mounted() {
    var node = document.createElement("div");
    this.el.appendChild(node);

    var liveView = this;

    var generateUrl, pushEvent, statusUpdate;

    pushEvent = (event) => {
      var target = liveView.el.dataset.target;
      if (target) {
        liveView.pushEventTo(target, eventName, event)
      } else {
        liveView.pushEvent(eventName, event)
      }
    }

    generateUrl = (data) => pushEvent(["generate-url", data]);
    statusUpdate = (data) => pushEvent(["file-status", data]);

    var flags = {};

    if (this.el.dataset.buttonClass) {
      flags.buttonClass = this.el.dataset.buttonClass;
    }

    if (this.el.dataset.buttonText) {
      flags.buttonText = this.el.dataset.buttonText;
    }

    if (this.el.dataset.fileTypes) {
      flags.fileTypes = this.el.dataset.fileTypes.split(",");
    }

    if (this.el.dataset.multiple == "false") { flags.multiple = false }
    if (this.el.dataset.multiple == "true") { flags.multiple = true }

    if (this.el.dataset.text) {
      flags.text = this.el.dataset.text;
    }

    this.app = Elm.Main.init({flags: flags, node: node});
    this.app.ports.requestUrl.subscribe(generateUrl);
    this.app.ports.uploadStatus.subscribe(statusUpdate);

    this.dataId = this.el.dataset.id;
    this.dataUrl = this.el.dataset.url;
  }

  updated() {
    var dataset = this.el.dataset;
    if (dataset && this.dataId !== dataset.id && this.dataUrl !== dataset.url) {
      this.dataId = dataset.id;
      this.dataUrl = dataset.url;
      this.app.ports.addUploadUrl.send({id: this.dataId, url: this.dataUrl});
    }
  }
}

export default PhoenixLiveViewDropzone;
