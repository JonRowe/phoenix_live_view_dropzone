'use strict';

import { Elm } from "./Main.elm";

export class PhoenixLiveViewDropzone {
  mounted() {
    var node = document.createElement("div");
    this.el.appendChild(node);

    this.target = this.el.dataset.target;

    this.generateUrl = (data) => {
      if (this.target) {
        this.pushEventTo(this.target, "phx-dropzone", ["generate-url", data]);
      } else {
        this.pushEvent("phx-dropzone", ["generate-url", data]);
      }
    }

    this.statusUpdate = (data) => {
      if (this.target) {
          this.pushEventTo(this.target, "phx-dropzone", ["file-status", data]);
        } else {
          this.pushEvent("phx-dropzone", ["file-status", data]);
      }
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
    this.app.ports.requestUrl.subscribe(this.generateUrl);
    this.app.ports.uploadStatus.subscribe(this.statusUpdate);

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

    if (dataset && this.target !== dataset.target) {
      this.target = dataset.target;
    }
  }
}

export default PhoenixLiveViewDropzone;
