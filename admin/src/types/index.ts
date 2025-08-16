export interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'staff';
  createdAt: string;
}

export interface MenuItem {
  id: string;
  name: string;
  description: string;
  price: number;
  category: string;
  image?: string;
  isAvailable: boolean;
}

export interface Order {
  id: string;
  items: OrderItem[];
  status: 'pending' | 'preparing' | 'ready' | 'delivered' | 'cancelled';
  totalAmount: number;
  customerName: string;
  tableNumber: number;
  createdAt: string;
  updatedAt: string;
}

export interface OrderItem {
  menuItem: MenuItem;
  quantity: number;
  notes?: string;
}

export interface Category {
  id: string;
  name: string;
  description?: string;
  is_active: boolean;
  image_url?: string;
  created_at: Date;
  updated_at: Date;
}

export interface Product {
  name: string;
  description: string;
  price: number;
  category_id: string;
  image_url: string;
  is_available: boolean;
}

export interface Campaign {
  id: string;
  title: string;
  description?: string;
  start_date: Date;
  end_date: Date;
  is_active: boolean;
  image_url?: string;
  created_at: Date;
  updated_at: Date;
}

export interface Notification {
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  is_read: boolean;
}

export interface SliderItem {
  title: string;
  description: string;
  image_url: string;
  link: string;
  display_order: number;
  is_active: boolean;
}

export interface FAQ {
  id: string;
  question: string;
  answer: string;
  category_id: string;
  category?: string;
  display_order: number;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface DaySchedule {
  day: string;
  isOpen: boolean;
  openTime: string;
  closeTime: string;
}

export interface WorkingHours {
  monday: DaySchedule;
  tuesday: DaySchedule;
  wednesday: DaySchedule;
  thursday: DaySchedule;
  friday: DaySchedule;
  saturday: DaySchedule;
  sunday: DaySchedule;
}

export interface Branch {
  id: string;
  name: string;
  address: string;
  location?: string;
  phone: string;
  email: string;
  latitude: string | number;
  longitude: string | number;
  opening_hours: string;
  working_hours?: string | WorkingHours; // Veritabanından gelen alan (string) veya parsed object
  is_active: boolean;
} 