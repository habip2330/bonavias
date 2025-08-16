import axios, { AxiosError } from 'axios';
import type { Campaign, Category } from '../types';

interface ApiError {
  error: string;
  message?: string;
}

const api = axios.create({
  baseURL: 'http://localhost:3001/api',
  headers: {
    'Content-Type': 'application/json',
  }
});

// Add request interceptor for logging
api.interceptors.request.use(
  (config) => {
    console.log('🚀 API Request:', {
      method: config.method?.toUpperCase(),
      url: config.url,
      baseURL: config.baseURL,
      data: config.data,
      headers: config.headers
    });
    return config;
  },
  (error) => {
    console.error('❌ API Request Error:', error);
    return Promise.reject(error);
  }
);

// Add response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    console.log('✅ API Response:', {
      status: response.status,
      statusText: response.statusText,
      data: response.data,
      headers: response.headers
    });
    return response;
  },
  (error: AxiosError<ApiError>) => {
    console.error('❌ API Error:', {
      message: error.message,
      status: error.response?.status,
      statusText: error.response?.statusText,
      data: error.response?.data,
      config: {
        method: error.config?.method?.toUpperCase(),
        url: error.config?.url,
        baseURL: error.config?.baseURL,
        data: error.config?.data
      }
    });
    return Promise.reject(error);
  }
);

export const campaignApi = {
  getAll: async (): Promise<Campaign[]> => {
    try {
      const response = await api.get<Campaign[]>('/campaigns');
      return response.data;
    } catch (error) {
      console.error('Error fetching campaigns:', error);
      throw error;
    }
  },
  
  create: async (data: Omit<Campaign, 'id' | 'created_at' | 'updated_at'>): Promise<Campaign> => {
    try {
      const response = await api.post<Campaign>('/campaigns', data);
      return response.data;
    } catch (error) {
      console.error('Error creating campaign:', error);
      throw error;
    }
  },
  
  update: async (id: string, data: Partial<Campaign>): Promise<Campaign> => {
    try {
      const response = await api.put<Campaign>(`/campaigns/${id}`, data);
      return response.data;
    } catch (error) {
      console.error('Error updating campaign:', error);
      throw error;
    }
  },
  
  delete: async (id: string): Promise<void> => {
    try {
      await api.delete(`/campaigns/${id}`);
    } catch (error) {
      console.error('Error deleting campaign:', error);
      throw error;
    }
  },
};

export const categoryApi = {
  getAll: async (): Promise<Category[]> => {
    try {
      const response = await api.get<Category[]>('/categories');
      return response.data;
    } catch (error) {
      console.error('Error fetching categories:', error);
      throw error;
    }
  },
  
  create: async (data: Omit<Category, 'id' | 'created_at' | 'updated_at'>): Promise<Category> => {
    try {
      const response = await api.post<Category>('/categories', data);
      return response.data;
    } catch (error) {
      console.error('Error creating category:', error);
      throw error;
    }
  },
  
  update: async (id: string, data: Partial<Category>): Promise<Category> => {
    try {
      const response = await api.put<Category>(`/categories/${id}`, data);
      return response.data;
    } catch (error) {
      console.error('Error updating category:', error);
      throw error;
    }
  },
  
  delete: async (id: string): Promise<void> => {
    try {
      await api.delete(`/categories/${id}`);
    } catch (error) {
      console.error('Error deleting category:', error);
      throw error;
    }
  },
};

// Add other API endpoints as needed

export default api; 