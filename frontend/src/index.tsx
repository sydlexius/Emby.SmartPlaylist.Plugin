import * as React from 'react';
import * as ReactDOM from 'react-dom';
import App from '~/app';

// Export a controller function that Emby's plugin system can instantiate
export default function() {
    const self = this;
    
    self.type = 'script';
    self.id = 'smartplaylist';
    
    console.log('[SmartPlaylist] Controller instantiated');
    
    // This is called by Emby when the plugin page is loaded
    self.show = function() {
        console.log('[SmartPlaylist] show() called');
        const appElements = document.querySelectorAll('#smartplaylist-root');
        console.log('[SmartPlaylist] Found elements:', appElements.length);
        const appElement = appElements[appElements.length - 1];
        
        if (appElement) {
            console.log('[SmartPlaylist] Mounting React app to:', appElement);
            const appId = appElement.getAttribute('data-app-id');
            console.log('[SmartPlaylist] App ID:', appId);
            ReactDOM.render(<App appId={appId} />, appElement);
            console.log('[SmartPlaylist] React app mounted successfully');
        } else {
            console.error('[SmartPlaylist] No smartplaylist-root element found!');
        }
    };
    
    // Try calling show() immediately to see if DOM is ready
    console.log('[SmartPlaylist] Attempting immediate show() call');
    setTimeout(() => {
        console.log('[SmartPlaylist] Delayed show() call via setTimeout');
        self.show();
    }, 100);
    
    // This is called by Emby when navigating away from the plugin page
    self.destroy = function() {
        const appElements = document.querySelectorAll('#smartplaylist-root');
        const appElement = appElements[appElements.length - 1];
        
        if (appElement) {
            ReactDOM.unmountComponentAtNode(appElement);
        }
    };
}

if (process.env.NODE_ENV !== 'production') {
    // tslint:disable-next-line:no-var-requires
    const { whyDidYouUpdate } = require('why-did-you-update');
    whyDidYouUpdate(React);
}
