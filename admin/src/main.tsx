import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App'

console.log('React application starting...');

const rootElement = document.getElementById('root');
console.log('Root element:', rootElement);

if (!rootElement) {
  console.error('Root element not found!');
  throw new Error('Root element not found!');
}

const root = createRoot(rootElement);
console.log('Root created');

root.render(
  <StrictMode>
    <App />
  </StrictMode>,
);

console.log('React application rendered');
