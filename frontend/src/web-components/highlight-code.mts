import { Marked } from 'marked';
import markedAlert from 'marked-alert'
import { markedHighlight } from 'marked-highlight';
import DOMPurify from 'dompurify';
import hljs from 'highlight.js';

window.customElements.define('highlight-code', class extends HTMLElement {
  // Cached instances
  private _marked: Marked | undefined;
  private _DOMPurify: DOMPurify.DOMPurifyI | undefined;

  constructor() { super(); }

  connectedCallback() { this.render(); }

  render() {
    const code = this.getAttribute('code') ?? '';
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

  parseCode(code: string, lang: string) {
    const sanitized = DOMPurify.sanitize(this.highlightCode(code, lang));

    this.classList.add('block', 'whitespace-pre', 'hljs', `language-${lang}`);
    this.innerHTML = sanitized;
  }

  async parseMarkdown(markdown: string, baseUrl = '', rawBaseUrl = '') {
    if (baseUrl) {
      this.DOMPurify.addHook('afterSanitizeAttributes', function(node) {
        let href = node.getAttribute('href');
        if (href !== null) {
          const newHref = new URL(removeRootPath(href), baseUrl);
          node.setAttribute('href', newHref.toString());
        }

        let src = node.getAttribute('src');
        if (src !== null) {
          const newSrc = new URL(removeRootPath(src), rawBaseUrl || baseUrl);
          node.setAttribute('src', newSrc.toString());
        }
      });
    }

    const parsed = await this.marked.parse(markdown);
    const sanitized = this.DOMPurify.sanitize(parsed);

    this.classList.add('block');
    this.innerHTML = sanitized;
  }

  highlightCode(code: string, lang: string): string {
    const language = hljs.getLanguage(lang) ? lang : 'plaintext';
    return hljs.highlight(code, { language, ignoreIllegals: true }).value;
  }

  get marked(): Marked {
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

  get DOMPurify(): DOMPurify.DOMPurifyI {
    if (this._DOMPurify) {
      return this._DOMPurify;
    }

    this._DOMPurify = DOMPurify();

    return this._DOMPurify;
  }
})

function removeRootPath(path = ''): string {
  if (path.startsWith('/')) {
    return path.substring(1);
  }

  return path;
}
