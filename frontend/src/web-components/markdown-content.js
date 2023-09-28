import { Marked } from 'marked';
import { markedHighlight } from "marked-highlight";
import DOMPurify from 'dompurify';
import hljs from 'highlight.js';

window.customElements.define('markdown-content', class extends HTMLElement {
  constructor() {
    super();

    this._marked = new Marked(
      markedHighlight({
        langPrefix: 'hljs language-',
        highlight(code, lang) {
          const language = hljs.getLanguage(lang) ? lang : 'plaintext';
          return hljs.highlight(code, { language, ignoreIllegals: true }).value;
        }
      })
    );
  }

  connectedCallback() {
    this.parseAndSetMarkdown();
  }

  attributeChangedCallback() {
    this.parseAndSetMarkdown();
  };

  static get observedAttributes() { return ['markdown']; };

  parseAndSetMarkdown() {
    const markdown = this.getAttribute("markdown");
    const sanitized = DOMPurify.sanitize(this._marked.parse(markdown));

    this.classList.add("block");
    this.innerHTML = sanitized;
  }
})
