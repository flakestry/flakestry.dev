import Clipboard from 'clipboard';

import './index.css';
import './web-components/highlight-code';

// This is called BEFORE your Elm app starts up
// 
// The value returned here will be passed as flags 
// into your `Shared.init` function.
export const flags = ({ env }) => {
    return {}
}

// This is called AFTER your Elm app starts up
//
// Here you can work with `app.ports` to send messages
// to your Elm application, or subscribe to incoming
// messages from Elm
export const onReady = ({ app, env }) => {
    const clipboard = new Clipboard('.clipboard');

    clipboard.on('success', function(e) {
        const el = document.createElement('span');
        el.className = 'bg-gray-100 border border-gray-300 p-1 text-sm text-gray-900 rounded-md absolute m-4 mx-auto';
        el.innerText = 'Copied!';
        e.trigger.appendChild(el);
        e.clearSelection();
    });
}
