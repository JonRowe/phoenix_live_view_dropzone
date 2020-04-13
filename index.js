'use strict';

import { Elm } from "./elm.js";

export class PhoenixLiveViewDropzone {
  mounted() {
    var node = document.createElement("div");
    this.el.appendChild(node);

    var liveView = this;

    var generateUrl = (fileId) => liveView.pushEvent("phx-dropzone-generate-file-url", fileId);
    var onStatusUpdate = (result) => liveView.pushEvent("phx-dropzone-status", result);

    this.app = Elm.Main.init({flags: {}, node: node});
    this.app.ports.requestUrl.subscribe(generateUrl);
    this.app.ports.notifyUploadStatus.subscribe(onStatusUpdate);

    this.dataId = this.el.dataset.id;
    this.dataUrl = this.el.dataset.url;
  }

  updated() {
    var dataset = this.el.dataset;
    consolg.log(dataset)
    if (dataset && this.dataId !== dataset.id && this.dataUrl !== dataset.url) {
      this.dataId = dataset.id;
      this.dataUrl = dataset.url;
      this.app.ports.addUploadUrl.send(this.dataUrl);
    }
  }
}

export default PhoenixLiveViewDropzone;
