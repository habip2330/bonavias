import React, { useState, useEffect } from 'react';
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import {
  useSortable,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { PageLayout } from '../../components/PageLayout';
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
import { Plus, Edit, Trash2, GripVertical } from 'lucide-react';

interface Slide {
  id: string;
  title: string;
  description: string;
  image_url: string;
  link_url: string;
  is_active: boolean;
  sort_order: number;
}

// Sortable Item Component
function SortableItem({ slide, onEdit, onDelete }: { 
  slide: Slide; 
  onEdit: (slide: Slide) => void; 
  onDelete: (slide: Slide) => void; 
}) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: slide.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`flex items-center p-4 bg-white border rounded-lg shadow-sm ${
        isDragging ? 'shadow-lg' : ''
      }`}
    >
      <div
        {...attributes}
        {...listeners}
        className="mr-4 text-gray-400 hover:text-gray-600 cursor-grab"
      >
        <GripVertical className="h-5 w-5" />
      </div>
      
      <div className="mr-4">
        <img
          src={slide.image_url.startsWith('http') ? slide.image_url : `http://localhost:3001${slide.image_url}`}
          alt={slide.title}
          className="h-16 w-28 object-cover rounded"
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = 'https://via.placeholder.com/112x64?text=No+Image';
          }}
        />
      </div>
      
      <div className="flex-1">
        <h3 className="font-semibold text-lg">{slide.title}</h3>
        <p className="text-gray-600 text-sm">{slide.description}</p>
        <div className="flex items-center gap-2 mt-1">
          <span className="text-xs text-gray-500">Order: {slide.sort_order}</span>
          <span
            className={`inline-flex items-center rounded-full px-2 py-1 text-xs font-medium ${
              slide.is_active
                ? 'bg-green-100 text-green-800'
                : 'bg-red-100 text-red-800'
            }`}
          >
            {slide.is_active ? 'Active' : 'Inactive'}
          </span>
        </div>
      </div>
      
      <div className="flex gap-2">
        <Button
          variant="outline"
          size="sm"
          onClick={() => onEdit(slide)}
          className="hover:bg-blue-50 hover:border-blue-300"
        >
          <Edit className="h-4 w-4" />
        </Button>
        <Button
          variant="outline"
          size="sm"
          onClick={() => onDelete(slide)}
          className="text-red-600 hover:text-red-700 hover:bg-red-50 hover:border-red-300 transition-colors"
        >
          <Trash2 className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}

const API_URL = 'http://localhost:3001/api/sliders';

const SliderPage: React.FC = () => {
  const [slides, setSlides] = useState<Slide[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedSlide, setSelectedSlide] = useState<Slide | null>(null);
  const [formData, setFormData] = useState<Slide>({
    id: '',
    title: '',
    description: '',
    image_url: '',
    link_url: '',
    is_active: true,
    sort_order: 0,
  });

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  useEffect(() => {
    fetchSlides();
  }, []);

  const fetchSlides = async () => {
    setIsLoading(true);
    try {
      const res = await fetch(API_URL);
      const data = await res.json();
      setSlides(data);
    } catch (e) {
      alert('Failed to fetch slides');
    } finally {
      setIsLoading(false);
    }
  };

  const handleAdd = () => {
    setSelectedSlide(null);
    const nextSortOrder = slides.length > 0 ? Math.max(...slides.map(s => s.sort_order)) + 1 : 1;
    setFormData({
      id: '',
      title: '',
      description: '',
      image_url: '',
      link_url: '',
      is_active: true,
      sort_order: nextSortOrder,
    });
    setIsOpen(true);
  };

  const handleEdit = (slide: Slide) => {
    setSelectedSlide(slide);
    setFormData(slide);
    setIsOpen(true);
  };

  const handleDelete = async (slide: Slide) => {
    if (!confirm(`Are you sure you want to delete "${slide.title}"? This action cannot be undone.`)) return;
    
    setIsLoading(true);
    try {
      const response = await fetch(`${API_URL}/${slide.id}`, { method: 'DELETE' });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      // Başarılı silme sonrası slides'ı güncelle
      await fetchSlides();
      
      // Başarı mesajı (opsiyonel)
      console.log(`Slide "${slide.title}" deleted successfully`);
      
    } catch (e) {
      console.error('Delete error:', e);
      alert(`Failed to delete slide: ${e instanceof Error ? e.message : 'Unknown error'}`);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event;
    console.log('Drag ended:', { active: active.id, over: over?.id });
    
    if (!over) {
      console.log('No destination, drag cancelled');
      return;
    }

    if (active.id === over.id) {
      console.log('Same position, no change needed');
      return;
    }

    const oldIndex = slides.findIndex(slide => slide.id === active.id);
    const newIndex = slides.findIndex(slide => slide.id === over.id);
    
    console.log(`Moving from index ${oldIndex} to ${newIndex}`);

    const newSlides = arrayMove(slides, oldIndex, newIndex);

    // Yeni sıralama ile sort_order'ları güncelle
    const updatedItems = newSlides.map((item, index) => ({
      ...item,
      sort_order: index + 1
    }));

    console.log('Updated items:', updatedItems.map(i => ({ id: i.id, title: i.title, order: i.sort_order })));

    // Optimistic update
    setSlides(updatedItems);

    // Backend'e gönder
    try {
      const updatePromises = updatedItems.map(item => {
        console.log(`Updating slide ${item.id} with order ${item.sort_order}`);
        return fetch(`${API_URL}/${item.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(item)
        });
      });
      
      await Promise.all(updatePromises);
      console.log('All slides updated successfully');
    } catch (e) {
      console.error('Failed to update slide order:', e);
      alert('Failed to update slide order');
      fetchSlides(); // Hata durumunda yenile
    }
  };

  const handleSubmit = async () => {
    try {
      if (selectedSlide) {
        await fetch(`${API_URL}/${selectedSlide.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(formData)
        });
      } else {
        await fetch(API_URL, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(formData)
        });
      }
      setIsOpen(false);
      fetchSlides();
    } catch (e) {
      alert('Failed to save slide');
    }
  };

  return (
    <PageLayout
      title="Slider"
      subtitle="Manage your promotional banners"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="mr-2 h-4 w-4" />
          Add Slide
        </Button>
      }
    >
      <Card>
        <CardHeader>
          <CardTitle>Banner Slides</CardTitle>
          <CardDescription>
            View and manage your promotional banner slides
          </CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="flex justify-center items-center h-32">
              <div className="text-gray-500">Loading slides...</div>
            </div>
          ) : slides.length === 0 ? (
            <div className="flex justify-center items-center h-32">
              <div className="text-gray-500">No slides found. Click "Add Slide" to create your first slide.</div>
            </div>
          ) : (
            <DndContext
              sensors={sensors}
              collisionDetection={closestCenter}
              onDragEnd={handleDragEnd}
            >
              <SortableContext items={slides.map(s => s.id)} strategy={verticalListSortingStrategy}>
                <div className="space-y-4">
                  {slides.map((slide) => (
                    <SortableItem
                      key={slide.id}
                      slide={slide}
                      onEdit={handleEdit}
                      onDelete={handleDelete}
                    />
                  ))}
                </div>
              </SortableContext>
            </DndContext>
          )}
        </CardContent>
      </Card>

      <Sheet open={isOpen} onOpenChange={setIsOpen}>
        <SheetContent className="sm:max-w-[540px]">
          <SheetHeader>
            <SheetTitle>
              {selectedSlide ? 'Edit Slide' : 'Add Slide'}
            </SheetTitle>
            <SheetDescription>
              {selectedSlide
                ? 'Update the slide details below'
                : 'Fill in the slide details below'}
            </SheetDescription>
          </SheetHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="title">Title</Label>
              <Input
                id="title"
                value={formData.title}
                onChange={(e) =>
                  setFormData({ ...formData, title: e.target.value })
                }
                placeholder="Enter slide title"
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
                placeholder="Enter slide description"
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="image_file">Slide Image</Label>
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
                  formDataImg.append('folder', 'slider');
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
              <Label htmlFor="link_url">Link URL (Optional)</Label>
              <Input
                id="link_url"
                value={formData.link_url}
                onChange={(e) =>
                  setFormData({ ...formData, link_url: e.target.value })
                }
                placeholder="Enter link URL (optional)"
              />
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
              {selectedSlide ? 'Update Slide' : 'Add Slide'}
            </Button>
          </div>
        </SheetContent>
      </Sheet>
    </PageLayout>
  );
};

export default SliderPage; 