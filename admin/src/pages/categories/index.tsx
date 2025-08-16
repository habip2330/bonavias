import React, { useState, useEffect } from 'react';
import { PageLayout } from '../../components/PageLayout';
import { Button } from '../../components/ui/button';
import { DataTable } from '../../components/ui/data-table';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Switch } from '../../components/ui/switch';
import { useConfirmDialog } from '../../components/ConfirmDialog';
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
  SheetTrigger,
} from '../../components/ui/sheet';
import { Plus, Edit, Trash2 } from 'lucide-react';
import type { Column, Action } from '../../components/ui/data-table';
import { categoryApi } from '../../services/api';
import type { Category } from '../../types';

const CategoriesPage: React.FC = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(null);
  const { showConfirm, ConfirmDialogComponent } = useConfirmDialog();
  const [formData, setFormData] = useState<Omit<Category, 'id' | 'created_at' | 'updated_at'>>({
    name: '',
    description: '',
    image_url: '',
    is_active: true
  });
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    fetchCategories();
  }, []);

  const fetchCategories = async () => {
    try {
      setIsLoading(true);
      const data = await categoryApi.getAll();
      setCategories(data);
    } catch (error) {
      alert('Failed to fetch categories');
    } finally {
      setIsLoading(false);
    }
  };

  const handleAdd = () => {
    setSelectedCategory(null);
    setFormData({
      name: '',
      description: '',
      image_url: '',
      is_active: true
    });
    setIsOpen(true);
  };

  const handleEdit = (category: Category) => {
    setSelectedCategory(category);
    setFormData({
      name: category.name,
      description: category.description || '',
      image_url: category.image_url || '',
      is_active: category.is_active
    });
    setIsOpen(true);
  };

  const handleDelete = async (category: Category) => {
    showConfirm({
      title: 'Kategoriyi Sil',
      message: `"${category.name}" kategorisini silmek istediğinize emin misiniz? Bu kategoriye ait ürünler varsa bu işlem gerçekleştirilemez.`,
      confirmText: 'Sil',
      cancelText: 'İptal',
      variant: 'destructive',
      onConfirm: async () => {
        try {
          await categoryApi.delete(category.id);
          alert('Kategori başarıyla silindi');
          fetchCategories();
        } catch (error) {
          alert('Kategori silinirken bir hata oluştu');
        }
      }
    });
  };

  const handleSubmit = async () => {
    if (!formData.image_url) {
      alert('Lütfen önce bir resim seçip yükleyin!');
      return;
    }
    try {
      if (selectedCategory) {
        await categoryApi.update(selectedCategory.id, formData);
        alert('Category updated successfully');
      } else {
        await categoryApi.create(formData);
        alert('Category created successfully');
      }
      setIsOpen(false);
      fetchCategories();
    } catch (error) {
      alert(selectedCategory ? 'Failed to update category' : 'Failed to create category');
    }
  };

  const actions: Action<Category>[] = [
    {
      label: 'Edit Category',
      onClick: handleEdit,
      icon: <Edit className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'Delete Category',
      onClick: handleDelete,
      icon: <Trash2 className="h-4 w-4" />,
      color: 'destructive'
    }
  ];

  const columns: Column<Category>[] = [
    { field: 'name', header: 'Name' },
    { field: 'description', header: 'Description' },
    {
      field: 'is_active',
      header: 'Status',
      render: (value: boolean) => (
        <span
          className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
            value
              ? 'bg-green-100 text-green-800'
              : 'bg-red-100 text-red-800'
          }`}
        >
          {value ? 'Active' : 'Inactive'}
        </span>
      ),
    }
  ];

  return (
    <PageLayout
      title="Categories"
      subtitle="Manage your product categories"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="mr-2 h-4 w-4" />
          Add Category
        </Button>
      }
    >
      <Card>
        <CardHeader>
          <CardTitle>Product Categories</CardTitle>
          <CardDescription>
            View and manage all your product categories
          </CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="flex justify-center items-center h-32">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
            </div>
          ) : (
            <DataTable<Category>
              data={categories}
              columns={columns}
              actions={actions}
              pageSize={10}
            />
          )}
        </CardContent>
      </Card>

      <Sheet open={isOpen} onOpenChange={setIsOpen}>
        <SheetContent className="sm:max-w-[540px]">
          <SheetHeader>
            <SheetTitle>
              {selectedCategory ? 'Edit Category' : 'Add Category'}
            </SheetTitle>
            <SheetDescription>
              {selectedCategory
                ? 'Update the category details below'
                : 'Fill in the category details below'}
            </SheetDescription>
          </SheetHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="name">Name</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
                placeholder="Enter category name"
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
                placeholder="Enter category description"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="image_file">Image File</Label>
              <Input
                id="image_file"
                type="file"
                accept="image/*"
                onChange={async (e) => {
                  const file = e.target.files?.[0];
                  if (!file) return;
                  setUploading(true);
                  setFormData((prev) => ({ ...prev, image_url: '' }));
                  const formDataImg = new FormData();
                  formDataImg.append('image', file);
                  formDataImg.append('folder', 'categories');
                  try {
                    const res = await fetch('http://localhost:3001/api/upload', {
                      method: 'POST',
                      body: formDataImg,
                    });
                    const data = await res.json();
                    console.log('Upload response:', data);
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
                    console.error('Upload error:', err);
                  }
                  setUploading(false);
                }}
              />
              {formData.image_url && (
                <img src={formData.image_url} alt="Preview" style={{ maxWidth: 120, marginTop: 8 }} />
              )}
            </div>
            <div className="flex items-center space-x-2">
              <Switch
                id="is_active"
                checked={formData.is_active}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, is_active: checked })
                }
              />
              <Label htmlFor="is_active">Active</Label>
            </div>
            <Button className="mt-4" onClick={handleSubmit}>
              {selectedCategory ? 'Update Category' : 'Add Category'}
            </Button>
          </div>
        </SheetContent>
      </Sheet>
      
      {ConfirmDialogComponent}
    </PageLayout>
  );
};

export default CategoriesPage; 