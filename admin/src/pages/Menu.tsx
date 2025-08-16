import React, { useState } from 'react';
import type { MenuItem, Category } from '../types';

const mockCategories: Category[] = [
  { 
    id: '1', 
    name: 'Hot Beverages', 
    description: 'Coffee, Tea, and more',
    is_active: true,
    sort_order: 1,
    image_url: '',
    created_at: new Date(),
    updated_at: new Date()
  },
  { 
    id: '2', 
    name: 'Cold Beverages', 
    description: 'Refreshing drinks',
    is_active: true,
    sort_order: 2,
    image_url: '',
    created_at: new Date(),
    updated_at: new Date()
  },
  { 
    id: '3', 
    name: 'Pastries', 
    description: 'Fresh baked goods',
    is_active: true,
    sort_order: 3,
    image_url: '',
    created_at: new Date(),
    updated_at: new Date()
  },
  { 
    id: '4', 
    name: 'Main Dishes', 
    description: 'Hearty meals',
    is_active: true,
    sort_order: 4,
    image_url: '',
    created_at: new Date(),
    updated_at: new Date()
  }
];

const mockMenuItems: MenuItem[] = [
  {
    id: '1',
    name: 'Cappuccino',
    description: 'Classic Italian coffee with steamed milk foam',
    price: 4.50,
    category: 'Hot Beverages',
    image: 'https://placehold.co/200x200',
    isAvailable: true,
  },
  {
    id: '2',
    name: 'Iced Latte',
    description: 'Chilled espresso with milk and ice',
    price: 5.00,
    category: 'Cold Beverages',
    image: 'https://placehold.co/200x200',
    isAvailable: true,
  },
  // Add more mock items as needed
];

const categories: Category[] = [
  { 
    id: '1', 
    name: 'Hot Beverages', 
    description: 'Coffee, Tea, and more',
    is_active: true,
    sort_order: 1,
    image_url: '',
    created_at: new Date(),
    updated_at: new Date()
  },
  { 
    id: '2', 
    name: 'Cold Beverages', 
    description: 'Refreshing drinks',
    is_active: true,
    sort_order: 2,
    image_url: '',
    created_at: new Date(),
    updated_at: new Date()
  },
  { 
    id: '3', 
    name: 'Pastries', 
    description: 'Fresh baked goods',
    is_active: true,
    sort_order: 3,
    image_url: '',
    created_at: new Date(),
    updated_at: new Date()
  },
  { 
    id: '4', 
    name: 'Main Dishes', 
    description: 'Hearty meals',
    is_active: true,
    sort_order: 4,
    image_url: '',
    created_at: new Date(),
    updated_at: new Date()
  }
];

const Menu: React.FC = () => {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [menuItems] = useState<MenuItem[]>(mockMenuItems);
  const [categories] = useState<Category[]>(mockCategories);

  const filteredItems = selectedCategory === 'all'
    ? menuItems
    : menuItems.filter(item => item.category === selectedCategory);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-semibold">Menu Items</h2>
        <button className="btn-primary">Add New Item</button>
      </div>

      {/* Category Filter */}
      <div className="flex gap-2 overflow-x-auto pb-2">
        <button
          className={`px-4 py-2 rounded-full ${
            selectedCategory === 'all'
              ? 'bg-primary-600 text-white'
              : 'bg-gray-100 text-gray-800 hover:bg-gray-200'
          }`}
          onClick={() => setSelectedCategory('all')}
        >
          All
        </button>
        {categories.map((category) => (
          <button
            key={category.id}
            className={`px-4 py-2 rounded-full whitespace-nowrap ${
              selectedCategory === category.name
                ? 'bg-primary-600 text-white'
                : 'bg-gray-100 text-gray-800 hover:bg-gray-200'
            }`}
            onClick={() => setSelectedCategory(category.name)}
          >
            {category.name}
          </button>
        ))}
      </div>

      {/* Menu Items Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {filteredItems.map((item) => (
          <div key={item.id} className="bg-white rounded-lg shadow overflow-hidden">
            <img
              src={item.image || 'https://placehold.co/200x200'}
              alt={item.name}
              className="w-full h-48 object-cover"
            />
            <div className="p-4">
              <div className="flex justify-between items-start">
                <h3 className="text-lg font-semibold">{item.name}</h3>
                <span className="text-primary-600 font-semibold">${item.price.toFixed(2)}</span>
              </div>
              <p className="text-gray-600 text-sm mt-1">{item.description}</p>
              <div className="mt-4 flex justify-between items-center">
                <span className={`text-sm ${item.isAvailable ? 'text-green-600' : 'text-red-600'}`}>
                  {item.isAvailable ? 'Available' : 'Unavailable'}
                </span>
                <div className="flex gap-2">
                  <button className="text-primary-600 hover:text-primary-900">Edit</button>
                  <button className="text-gray-600 hover:text-gray-900">Delete</button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Menu; 