export default class Announce {

  constructor(msg) {
    this.elem = document.createElement('div');
    this.elem.classList.add("announce");
    this.titleE = document.createElement('span');
    this.elem.appendChild(this.titleE);
    this._title = msg;
    this.titleE.innerText=this._title;
  }

  get title () {
    return this._title;
  }

  set title (t) {
    this._title = t;
    this.titleE.innerText = t;
  }

  done () {
    this.elem.classList.add('done');
    setTimeout(function(obj) { obj.elem.remove() }, 1000, this);
  }
}
