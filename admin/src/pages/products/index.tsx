import React, { useState, useEffect } from 'react';
import { PageLayout } from '../../components/PageLayout';
import { DataTable } from '../../components/ui/data-table';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Switch } from '../../components/ui/switch';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '../../components/ui/card';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '../../components/ui/sheet';
import { Plus, Edit, Trash2 } from 'lucide-react';
import type { Column, Action } from '../../components/ui/data-table';
import { categoryApi } from '../../services/api';
import { useConfirmDialog } from '../../components/ConfirmDialog';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  category_id: string;
  image_url: string;
  is_available: boolean;
  is_popular: boolean;
  ingredients: string[];
}

const API_URL = 'http://localhost:3001/api/products';

const INGREDIENT_OPTIONS = [
  { value: 'gluten', label: 'Gluten (Buğday, çavdar, arpa, yulaf vb.)' },
  { value: 'egg', label: 'Yumurta ve yumurta ürünleri' },
  { value: 'peanut', label: 'Yer fıstığı ve ürünleri' },
  { value: 'milk', label: 'Süt ve süt ürünleri (laktoz dahil)' },
  { value: 'nuts', label: 'Sert kabuklu yemişler (badem, fındık, ceviz, kaju, Antep fıstığı vb.)' },
];

const ProductsPage: React.FC = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const { showConfirm, ConfirmDialogComponent } = useConfirmDialog();
  const [formData, setFormData] = useState<Product>({
    id: '',
    name: '',
    description: '',
    price: 0,
    category_id: '',
    image_url: '',
    is_available: true,
    is_popular: false,
    ingredients: [],
  });
  const [categories, setCategories] = useState<{ id: string; name: string }[]>([]);

  useEffect(() => {
    fetchProducts();
    fetchCategories();
  }, []);

  const fetchProducts = async () => {
    setIsLoading(true);
    try {
      const res = await fetch(API_URL);
      const data = await res.json();
      setProducts(data.map((p: { ingredients: any; }) => ({
        ...p,
        ingredients: Array.isArray(p.ingredients) ? p.ingredients : []
      })));
    } catch (e) {
      alert('Failed to fetch products');
    } finally {
      setIsLoading(false);
    }
  };

  const fetchCategories = async () => {
    try {
      const data = await categoryApi.getAll();
      setCategories(data.map((cat: any) => ({ id: cat.id, name: cat.name })));
    } catch (e) {
      alert('Failed to fetch categories');
    }
  };

  const handleAdd = () => {
    setSelectedProduct(null);
    setFormData({
      id: '',
      name: '',
      description: '',
      price: 0,
      category_id: '',
      image_url: '',
      is_available: true,
      is_popular: false,
      ingredients: [],
    });
    setIsOpen(true);
  };

  const handleEdit = (product: Product) => {
    setSelectedProduct(product);
    setFormData({
      ...product,
      ingredients: Array.isArray(product.ingredients) ? product.ingredients : []
    });
    setIsOpen(true);
  };

  const handleDelete = async (product: Product) => {
    showConfirm({
      title: 'Ürünü Sil',
      message: `"${product.name}" ürününü silmek istediğinize emin misiniz? Bu işlem geri alınamaz.`,
      confirmText: 'Sil',
      cancelText: 'İptal',
      variant: 'destructive',
      onConfirm: async () => {
        try {
          await fetch(`${API_URL}/${product.id}`, { method: 'DELETE' });
          fetchProducts();
        } catch (error) {
          alert('Ürün silinirken bir hata oluştu');
        }
      }
    });
  };

  const handleSubmit = async () => {
    console.log('Submitting product data:', formData);
    
    // Validasyon kontrolleri
    if (!formData.name.trim()) {
      alert('Ürün adı gereklidir!');
      return;
    }
    
    if (!formData.category_id) {
      alert('Kategori seçimi gereklidir!');
      return;
    }
    
    if (!formData.image_url) {
      alert('Ürün resmi gereklidir!');
      return;
    }

    try {
      let response;
      
      if (selectedProduct) {
        console.log('Updating product:', selectedProduct.id);
        response = await fetch(`${API_URL}/${selectedProduct.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(formData)
        });
      } else {
        console.log('Creating new product with data:', formData);
        response = await fetch(API_URL, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(formData)
        });
      }
      
      console.log('Response status:', response.status);
      
      if (!response.ok) {
        const errorData = await response.json();
        console.error('Server error:', errorData);
        alert(`Server error: ${errorData.error || 'Unknown error'}`);
        return;
      }
      
      const result = await response.json();
      console.log('Server response:', result);
      
      alert(selectedProduct ? 'Ürün başarıyla güncellendi!' : 'Ürün başarıyla eklendi!');
      setIsOpen(false);
      fetchProducts();
    } catch (e) {
      console.error('Error saving product:', e);
      alert(`Failed to save product: ${e.message}`);
    }
  };

  const actions: Action<Product>[] = [
    {
      label: 'Edit Product',
      onClick: handleEdit,
      icon: <Edit className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'Delete Product',
      onClick: handleDelete,
      icon: <Trash2 className="h-4 w-4" />,
      color: 'destructive'
    }
  ];

  const columns: Column<Product>[] = [
    {
      field: 'image_url',
      header: 'Image',
      render: (value: string) => {
        let imageUrl = '/placeholder-image.png';
        
        if (value) {
          if (value.startsWith('http')) {
            // Full URL
            imageUrl = value;
          } else if (value.startsWith('/public/uploads/')) {
            // New format - direct public path
            imageUrl = `http://localhost:3001${value}`;
          } else if (value.startsWith('/public/products/')) {
            // Old database format - convert to new path
            const filename = value.replace('/public/products/', '');
            imageUrl = `http://localhost:3001/public/uploads/products/${filename}`;
          } else if (value.startsWith('/uploads/')) {
            // Old upload endpoint format
            imageUrl = `http://localhost:3001${value}`;
          } else {
            // Relative path - assume products folder
            imageUrl = `http://localhost:3001/public/uploads/products/${value}`;
          }
        }
        
        return (
          <img
            src={imageUrl}
            alt="Product"
            className="h-10 w-10 rounded-full object-cover"
            onError={(e) => {
              const img = e.target as HTMLImageElement;
              img.src = '/placeholder-image.png';
            }}
          />
        );
      },
    },
    { field: 'name', header: 'Name' },
    { field: 'description', header: 'Description' },
    {
      field: 'price',
      header: 'Price',
      render: (value: any) => {
        const num = typeof value === 'number' ? value : parseFloat(value);
        return isNaN(num) ? '-' : `${num.toFixed(2)} ₺`;
      },
    },
    {
      field: 'is_available',
      header: 'Status',
      render: (value: boolean) => (
        <span
          className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
            value
              ? 'bg-green-100 text-green-800'
              : 'bg-red-100 text-red-800'
          }`}
        >
          {value ? 'Available' : 'Unavailable'}
        </span>
      ),
    },
    {
      field: 'is_popular',
      header: 'Popular',
      render: (value: boolean) => (
        <span
          className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
            value
              ? 'bg-yellow-100 text-yellow-800'
              : 'bg-gray-100 text-gray-800'
          }`}
        >
          {value ? '⭐ Popular' : 'Regular'}
        </span>
      ),
    }
  ];

  return (
    <PageLayout
      title="Products"
      subtitle="Manage your menu items"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="mr-2 h-4 w-4" />
          Add Product
        </Button>
      }
    >
      <Card>
        <CardHeader>
          <CardTitle>Menu Items</CardTitle>
          <CardDescription>
            View and manage all your menu items
          </CardDescription>
        </CardHeader>
        <CardContent>
          <DataTable<Product>
            data={products}
            columns={columns}
            actions={actions}
            pageSize={10}
          />
        </CardContent>
      </Card>

      <Sheet open={isOpen} onOpenChange={setIsOpen}>
        <SheetContent className="sm:max-w-[540px]">
          <SheetHeader>
            <SheetTitle>
              {selectedProduct ? 'Edit Product' : 'Add Product'}
            </SheetTitle>
            <SheetDescription>
              {selectedProduct
                ? 'Update the product details below'
                : 'Fill in the product details below'}
            </SheetDescription>
          </SheetHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="name">Product Name</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
                placeholder="Enter product name"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Input
                id="description"
                value={formData.description}
                onChange={(e) =>
                  setFormData({ ...formData, description: e.target.value })
                }
                placeholder="Enter product description"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="price">Price</Label>
                <Input
                  id="price"
                  type="number"
                  step="0.01"
                  value={formData.price}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      price: parseFloat(e.target.value) || 0
                    })
                  }
                  placeholder="Enter price"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="category_id">Category</Label>
                <select
                  id="category_id"
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  value={formData.category_id}
                  onChange={(e) =>
                    setFormData({ ...formData, category_id: e.target.value })
                  }
                >
                  <option value="">Select category</option>
                  {categories.map((cat) => (
                    <option key={cat.id} value={cat.id}>{cat.name}</option>
                  ))}
                </select>
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="image_file">Product Image</Label>
              <Input
                id="image_file"
                type="file"
                accept="image/*"
                onChange={async (e) => {
                  const file = e.target.files?.[0];
                  if (!file) return;
                  setUploading(true);
                  const formDataImg = new FormData();
                  formDataImg.append('image', file);
                  formDataImg.append('folder', 'products');
                  try {
                    const res = await fetch('http://localhost:3001/api/upload', {
                      method: 'POST',
                      body: formDataImg,
                    });
                    const data = await res.json();
                    if (data.url) {
                      setFormData((prev) => ({
                        ...prev,
                        image_url: data.url,
                      }));
                      alert('Resim yüklendi!');
                    } else {
                      alert('Resim yüklenemedi!');
                    }
                  } catch (err) {
                    alert('Yükleme sırasında hata oluştu!');
                  }
                  setUploading(false);
                }}
              />
              {uploading && <div>Yükleniyor...</div>}
              {formData.image_url && (
                <img src={`http://localhost:3001${formData.image_url}`} alt="Preview" style={{ maxWidth: 120, marginTop: 8 }} />
              )}
            </div>
            <div className="space-y-2">
              <Label>İçindekiler</Label>
              <div className="flex flex-col gap-2">
                {INGREDIENT_OPTIONS.map(opt => (
                  <label
                    key={opt.value}
                    className={`
                      flex items-center gap-3 p-2 rounded-lg border
                      cursor-pointer transition
                      ${formData.ingredients.includes(opt.value)
                        ? 'bg-amber-100 border-amber-400'
                        : 'bg-white border-gray-300 hover:border-amber-400'}
                    `}
                  >
                    <input
                      type="checkbox"
                      checked={formData.ingredients.includes(opt.value)}
                      onChange={e => {
                        if (e.target.checked) {
                          setFormData(prev => ({
                            ...prev,
                            ingredients: [...prev.ingredients, opt.value]
                          }));
                        } else {
                          setFormData(prev => ({
                            ...prev,
                            ingredients: prev.ingredients.filter(i => i !== opt.value)
                          }));
                        }
                      }}
                      className="accent-amber-500 w-5 h-5 rounded focus:ring-2 focus:ring-amber-400"
                    />
                    <span className="text-base font-medium">{opt.label}</span>
                  </label>
                ))}
              </div>
            </div>
            <div className="flex items-center space-x-2">
              <Switch
                id="is_available"
                checked={formData.is_available}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, is_available: checked })
                }
              />
              <Label htmlFor="is_available">Available</Label>
            </div>
            <div className="flex items-center space-x-2">
              <Switch
                id="is_popular"
                checked={formData.is_popular}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, is_popular: checked })
                }
              />
              <Label htmlFor="is_popular">Popular Product</Label>
            </div>
            <Button className="mt-4" onClick={handleSubmit}>
              {selectedProduct ? 'Update Product' : 'Add Product'}
            </Button>
          </div>
        </SheetContent>
      </Sheet>
      
      {ConfirmDialogComponent}
    </PageLayout>
  );
};

export default ProductsPage; 