import PDFReorganizer from 'pdf-reorganizer';
import MessageCenter from './message-center.js'

export default class PDFDropper extends HTMLElement {

  constructor() {
    super();
    this.filename = "";

    // Create a single subdiv for dropping, that can be exchanged with the pdf arranger
    this.dropDiv = document.createElement('div');
    this.dropDiv.innerHTML = this.innerHTML;
    this.innerHTML = '';
    this.appendChild(this.dropDiv);

    // Create new reorganizer  
    this.reorganizer = new PDFReorganizer();

    this.reorganizer.addEventListener(
      'processed',
      this.process.bind(this)
    );
    
    this.reorganizer.style.display = "none";
    this.appendChild(this.reorganizer);

    this.notify = new MessageCenter();

    return this;
  }

  connectedCallback() {
    let drop = this.dropDiv;
    drop.addEventListener("drop", this.dropHandler.bind(this));
    drop.addEventListener("dragover", this.dragOverHandler.bind(this));
    drop.addEventListener("dragenter", this.dragEnterHandler.bind(this));
    drop.addEventListener("dragleave", this.dragLeaveHandler.bind(this));

    document.body.appendChild(this.notify);
  }

  allowUpload() {
    // TODO: Use hide and show!
    this.dropDiv.style.display = "block";
    this.reorganizer.style.display = "none";
  }
  
  // Handler for dropping in the main area
  dropHandler(ev) {

    let instance = this;
    
    // Prevent default behavior (Prevent file from being opened)
    ev.preventDefault();
    ev.target.classList.remove("dragin");  

    console.log("File(s) dropped");

    // arranger.onprocess = process;
    // arranger.css = '/main.css';

    let fileReader = new FileReader();
    let file = ev.dataTransfer.items[0].getAsFile();

    // Turn the file into a byte array
    fileReader.onload = function() {
      instance.reorganizer.loadDocument(this.result, file.name);

      // Replace with file
      instance.dropDiv.style.display = "none";
      instance.reorganizer.style.display = "block";
    };

    fileReader.readAsArrayBuffer(file);

    // This uses the ajax API instead of fetch, as it supports progress wildly
    var ajax = new XMLHttpRequest();
    ajax.open("POST","/");

    let progress = instance.notify.progress("Upload " + file.name);
    
    ajax.onload = () => {
      // window.location.replace(ajax.response);
      console.log("Fine!");
    };

    ajax.upload.onprogress = function(event) {
      var value = Math.floor(event.total / event.loaded);
      progress.value = value;
      // document.getElementById("upload").value = value;
      // console.log(`Uploaded ${event.loaded} of ${event.total}: ${value}`);
    };

    ajax.upload.onload = function() {
      // document.getElementById("upload").value = 100;
      progress.done();
    };

    ajax.upload.onerror = function() {
      // progress.done();
      console.error(`Error during the upload: ${xhr.status}`);
    };

    ajax.onloadend = function() {
      if (ajax.status == 200) {
        // instance.notify.info("success " + ajax.responseText);
        progress.done();
      } else {
        instance.notify.info("error " + this.status);
      }
    };

    if (ev.dataTransfer.items) {
      // Use DataTransferItemList interface to access the file(s)
      [...ev.dataTransfer.items].forEach((item, i) => {
        // If dropped items aren't files, reject them
        if (item.kind === "file") {
          const file = item.getAsFile();
          console.log(`… file[${i}].name = ${file.name}`);
          instance.filename = file.name;
          let formData = new FormData();
          formData.append("file", file, file.name);
          ajax.send(formData);
          // sendFile(file, file.name);
        };
      });
    } else {
      // Use DataTransfer interface to access the file(s)
      [...ev.dataTransfer.files].forEach((file, i) => {
        console.log(`… file[${i}].name = ${file.name}`);
      });
    }
  }

  dragOverHandler(ev) {
    ev.preventDefault();
    console.log("File(s) in drop zone");
    // Prevent default behavior (Prevent file from being opened)
  };

  dragEnterHandler(ev) {
    // Prevent default behavior (Prevent file from being opened)
    ev.preventDefault();
    ev.target.classList.add("dragin");
  };

  dragLeaveHandler(ev) {
    // Prevent default behavior (Prevent file from being opened)
    ev.preventDefault();
    ev.target.classList.remove("dragin");  
  };
  
  /**
   * Process the PDF server-side.
   */
  process (ev) {
    let instance = this;
    var ajax = new XMLHttpRequest();
    let proc = this.notify.progress("Process " + this.filename)
    ajax.onload = (ev2) => {
      // window.location.replace('/');
      proc.done();
      instance.allowUpload();
    };
    ajax.open("POST","/edit");
    ajax.setRequestHeader('Content-type', 'application/json; charset=UTF-8')
    ajax.send(JSON.stringify(ev.detail));
  }
};

customElements.define('pdf-drop', PDFDropper);
