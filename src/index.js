'use strict';

import { Elm } from "./Main.elm";

export class PhoenixLiveViewDropzone {
  mounted() {
    var node = document.createElement("div");
    this.el.appendChild(node);

    var liveView = this;

    var generateUrl, statusUpdate;

    if (this.el.dataset.target) {
      var target = this.el.dataset.target;
      generateUrl = (data) => liveView.pushEventTo(target, "phx-dropzone", ["generate-url", data]);
      statusUpdate = (data) => liveView.pushEventTo(target, "phx-dropzone", ["file-status", data]);
    } else {
      generateUrl = (data) => liveView.pushEvent("phx-dropzone", ["generate-url", data]);
      statusUpdate = (data) => liveView.pushEvent("phx-dropzone", ["file-status", data]);
    }

    var flags = {};

    if (this.el.dataset.buttonText) {
      flags.buttonText = this.el.dataset.buttonText;
    }

    if (this.el.dataset.fileTypes) {
      flags.fileTypes = this.el.dataset.fileTypes.split(",");
    }

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
