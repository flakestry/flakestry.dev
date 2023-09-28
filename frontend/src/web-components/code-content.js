import DOMPurify from 'dompurify';
import hljs from 'highlight.js';

window.customElements.define('code-content', class extends HTMLElement {
  constructor() { super(); }

  connectedCallback() { this.highlightCode(); }

  attributeChangedCallback() { this.highlightCode(); };

  static get observedAttributes() { return ['content', 'lang']; };

  highlightCode() {
    const code = this.getAttribute("code");
    const lang = this.getAttribute("lang");

    const language = hljs.getLanguage(lang) ? lang : 'plaintext';
    const sanitized = DOMPurify.sanitize(hljs.highlight(code, { language, ignoreIllegals: true }).value);

    this.classList.add("block", "whitespace-pre", "hljs", `language-${lang}`);
    this.innerHTML = sanitized;
  }
})
