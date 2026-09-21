// MathJax handles delimited mathematics, but not LaTeX text-mode commands.
// Convert a small, explicit set of text commands without injecting HTML.
(() => {
  const tags = {
    textsuperscript: 'sup',
    textsubscript: 'sub',
    textbf: 'strong',
    textit: 'em',
    emph: 'em',
    underline: 'u'
  };

  function closingBrace(text, start) {
    let depth = 1;
    for (let i = start; i < text.length; i += 1) {
      if (text[i] === '\\') {
        i += 1;
      } else if (text[i] === '{') {
        depth += 1;
      } else if (text[i] === '}') {
        depth -= 1;
        if (depth === 0) return i;
      }
    }
    return -1;
  }

  function escaped(text, index) {
    let backslashes = 0;
    for (let i = index - 1; i >= 0 && text[i] === '\\'; i -= 1) backslashes += 1;
    return backslashes % 2 === 1;
  }

  function mathRanges(text) {
    const ranges = [];
    for (let i = 0; i < text.length;) {
      let open = '';
      let close = '';
      if (!escaped(text, i)) {
        if (text.startsWith('$$', i)) [open, close] = ['$$', '$$'];
        else if (text[i] === '$') [open, close] = ['$', '$'];
        else if (text.startsWith('\\(', i)) [open, close] = ['\\(', '\\)'];
        else if (text.startsWith('\\[', i)) [open, close] = ['\\[', '\\]'];
      }
      if (!open) {
        i += 1;
        continue;
      }
      let end = i + open.length;
      while (end < text.length && (!text.startsWith(close, end) || escaped(text, end))) end += 1;
      if (end < text.length) {
        ranges.push([i, end + close.length]);
        i = end + close.length;
      } else {
        i += open.length;
      }
    }
    return ranges;
  }

  function convert(text) {
    const command = /\\(textsuperscript|textsubscript|textbf|textit|emph|underline)\{/g;
    const maths = mathRanges(text);
    const fragment = document.createDocumentFragment();
    let last = 0;
    let changed = false;
    let match;

    while ((match = command.exec(text)) !== null) {
      if (escaped(text, match.index)) continue;
      if (maths.some(([start, end]) => match.index >= start && match.index < end)) continue;
      const end = closingBrace(text, command.lastIndex);
      if (end < 0) continue;

      fragment.append(document.createTextNode(text.slice(last, match.index)));
      const element = document.createElement(tags[match[1]]);
      const inner = text.slice(command.lastIndex, end);
      element.append(convert(inner) || document.createTextNode(inner));
      fragment.append(element);
      last = end + 1;
      command.lastIndex = last;
      changed = true;
    }

    if (!changed) return null;
    fragment.append(document.createTextNode(text.slice(last)));
    return fragment;
  }

  const root = document.querySelector('.site-main');
  if (!root) return;
  const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
  const nodes = [];
  while (walker.nextNode()) {
    const node = walker.currentNode;
    if (node.nodeValue.includes('\\') && !node.parentElement.closest('script, style, pre, code, textarea')) {
      nodes.push(node);
    }
  }
  for (const node of nodes) {
    const replacement = convert(node.nodeValue);
    if (replacement) node.replaceWith(replacement);
  }
})();
