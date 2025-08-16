import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Layout } from './components/Layout';
import Dashboard from './pages/Dashboard';
import Orders from './pages/Orders';
import Menu from './pages/Menu';
import Categories from './pages/categories';
import Products from './pages/products';
import Campaigns from './pages/campaigns';
import Notifications from './pages/notifications';
import Slider from './pages/slider';
import FAQ from './pages/faq';
import Branches from './pages/branches';
import Stories from './pages/stories/Stories';
import './styles/globals.css';

console.log('App component starting...');

// Placeholder components for remaining pages
const Staff = () => <div className="p-4">Staff Management Page (Coming Soon)</div>;
const Settings = () => <div className="p-4">Settings Page (Coming Soon)</div>;

function App() {
  console.log('App component rendering...');
  
  return (
    <Router>
      <div className="min-h-screen bg-background font-sans antialiased">
        <Layout>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/orders" element={<Orders />} />
            <Route path="/menu" element={<Menu />} />
            <Route path="/categories" element={<Categories />} />
            <Route path="/products" element={<Products />} />
            <Route path="/campaigns" element={<Campaigns />} />
            <Route path="/notifications" element={<Notifications />} />
            <Route path="/slider" element={<Slider />} />
            <Route path="/faq" element={<FAQ />} />
            <Route path="/branches" element={<Branches />} />
            <Route path="/stories" element={<Stories />} />
            <Route path="/staff" element={<Staff />} />
            <Route path="/settings" element={<Settings />} />
          </Routes>
        </Layout>
      </div>
    </Router>
  );
}

console.log('App component defined');

export default App;
