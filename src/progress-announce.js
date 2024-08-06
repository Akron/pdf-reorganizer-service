import Announce from './announce.js';

export default class ProgressAnnounce extends Announce {

  constructor(t) {
    super();
    this.elem = document.createElement('div');
    this.elem.classList.add("progress","announce");
    
    this.titleE = document.createElement('span');

    this.progress = document.createElement('progress');
    this.progress.setAttribute("max", 100);
    this.progress.setAttribute("value", 0);

    this.elem.appendChild(this.titleE);
    this.elem.appendChild(this.progress);
    this._title = t;
    this.titleE.innerText=this._title;
    this.value;
  }

  set value (v) {
    this.progress.setAttribute('value', v);
    if (v >= 100) {
      this.done();
    }
  }
}
