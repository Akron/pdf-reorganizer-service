import ProgressAnnounce from './progress-announce.js';
import Announce from './announce.js';

export default class MessageCenter extends HTMLElement {

  constructor() {
    super();
    return this;
  }

  progress (msg) {
    let announce = new ProgressAnnounce(msg);
    this.appendChild(announce.elem);
    return announce;
  }

  info (msg) {
    let announce = new Announce(msg);
    announce.elem.classList.add("info");
    this.appendChild(announce.elem);
    announce.done();
    return announce;
  }
};

customElements.define('message-center', MessageCenter);

