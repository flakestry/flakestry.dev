import { Marked } from 'marked';
import markedAlert from 'marked-alert'
import { markedHighlight } from 'marked-highlight';
import DOMPurify from 'dompurify';
import hljs from 'highlight.js';

window.customElements.define('highlight-code', class extends HTMLElement {
  constructor() { super(); }

  connectedCallback() { this.render(); }

  render() {
    const code = this.getAttribute('code');
    const lang = this.getAttribute('language') ?? 'markdown';
    const baseUrl = this.getAttribute('baseUrl') ?? '';
    const rawBaseUrl = this.getAttribute('rawBaseUrl') ?? '';

    switch (lang) {
      case 'markdown':
        this.parseMarkdown(code, baseUrl, rawBaseUrl);
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

  parseMarkdown(markdown, baseUrl = '', rawBaseUrl = '') {
    if (baseUrl) {
      this.DOMPurify.addHook('afterSanitizeAttributes', function(node) {
        if (node.hasAttribute('href')) {
          const url = new URL(
            removeRootPath(node.getAttribute('href')),
            baseUrl,
          );
          node.setAttribute('href', url.toString());
        }

        if (node.hasAttribute('src')) {
          const src = new URL(
            removeRootPath(node.getAttribute('src')),
            rawBaseUrl || baseUrl,
          );
          node.setAttribute('src', src.toString());
        }
      });
    }

    const sanitized = this.DOMPurify.sanitize(this.marked.parse(markdown));

    this.classList.add('block');
    this.innerHTML = sanitized;
  }

  highlightCode(code, lang) {
    const language = hljs.getLanguage(lang) ? lang : 'plaintext';
    return hljs.highlight(code, { language, ignoreIllegals: true }).value;
  }

  get marked() {
    if (this._marked) {
      return this._marked;
    }

    this._marked =
      new Marked(
        markedHighlight({
          langPrefix: 'hljs language-',
          highlight: this.highlightCode
        })
      ).use(markedAlert());

    return this._marked;
  }

  get DOMPurify() {
    if (this._DOMPurify) {
      return this._DOMPurify;
    }

    this._DOMPurify = DOMPurify();

    return this._DOMPurify;
  }
})

function removeRootPath(path = '') {
  if (path.startsWith('/')) {
    return path.substring(1);
  }

  return path;
}
