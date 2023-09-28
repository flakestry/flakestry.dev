import { Marked } from 'marked';
import { markedHighlight } from 'marked-highlight';
import DOMPurify from 'dompurify';
import hljs from 'highlight.js';

window.customElements.define('code-content', class extends HTMLElement {
  constructor() { super(); }

  connectedCallback() { this.render(); }

  attributeChangedCallback() { this.render(); };

  static get observedAttributes() { return ['code', 'lang']; };

  render() {
    const code = this.getAttribute('code');
    const lang = this.getAttribute('lang') ?? 'markdown';

    switch (lang) {
      case 'markdown':
        this.parseMarkdown(code);
        break;
      default:
        this.parseCode(code, lang);
        break;
    }
  }

  parseCode(code, lang) {
    const sanitized = DOMPurify.sanitize(this.highlightCode(code, lang));

    this.classList.add('block', 'whitespace-pre', 'hljs', `language-${lang}`);
    this.innerHTML = sanitized;
  }

  parseMarkdown(markdown) {
    const sanitized = DOMPurify.sanitize(this._marked.parse(markdown));

    this.classList.add('block');
    this.innerHTML = sanitized;
  }

  highlightCode(code, lang) {
    const language = hljs.getLanguage(lang) ? lang : 'plaintext';
    return hljs.highlight(code, { language, ignoreIllegals: true }).value;
  }

  get _marked() {
    if (this.__marked) {
      return this.__marked;
    }

    this.__marked = new Marked(
      markedHighlight({
        langPrefix: 'hljs language-',
        highlight: this.highlightCode
      })
    );

    return this.__marked;
  }
})
