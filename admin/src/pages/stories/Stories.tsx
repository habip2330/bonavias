import React, { useEffect, useState } from 'react';
import { PageLayout } from '../../components/PageLayout';
import { DataTable, Column, Action } from '../../components/ui/data-table';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Switch } from '../../components/ui/switch';
import { Textarea } from '../../components/ui/textarea';
import { Card } from '../../components/ui/card';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetDescription } from '../../components/ui/sheet';
import { Plus, Edit, Trash2 } from 'lucide-react';
import { useConfirmDialog } from '../../components/ConfirmDialog';
import axios from 'axios';
// DND-KIT importları
import {
  DndContext,
  closestCenter,
  PointerSensor,
  useSensor,
  useSensors,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

interface Story {
  id: string;
  title: string;
  description: string;
  image_url: string;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

interface StoryItemForm {
  imageFile: File | null;
  image_url?: string;
  description: string;
  display_order: number;
  is_active: boolean;
  previewUrl?: string;
}

const API_URL = 'http://localhost:3001/api/stories';

// Sadece gerekli alanları içeren payload oluşturucu
function getStoryPayload(form: Partial<Story>, imageUrl: string) {
  return {
    title: form.title || '',
    description: form.description || '',
    image_url: imageUrl,
    display_order: form.display_order || 1,
    is_active: form.is_active ?? true
  };
}

const Stories: React.FC = () => {
  const [stories, setStories] = useState<Story[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedStory, setSelectedStory] = useState<Story | null>(null);
  const { showConfirm, ConfirmDialogComponent } = useConfirmDialog();
  const [form, setForm] = useState<Partial<Story>>({});
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [storyItems, setStoryItems] = useState<StoryItemForm[]>([]);
  // Modal için ek state
  const [modalImage, setModalImage] = useState<string | null>(null);

  useEffect(() => {
    fetchStories();
  }, []);



  const fetchStories = async () => {
    setIsLoading(true);
    try {
      const res = await axios.get(API_URL);
      setStories(res.data);
    } catch (err) {
      // error handling
    } finally {
      setIsLoading(false);
    }
  };

  const handleAdd = () => {
    setSelectedStory(null);
    setForm({ is_active: true, display_order: stories.length + 1 });
    setImageFile(null);
    setStoryItems([]); // yeni hikaye için item'ları sıfırla
    setIsOpen(true);
  };

  const handleEdit = async (story: Story) => {
    setSelectedStory(story);
    setForm(story);
    setImageFile(null);
    // Story item'ları fetch et
    try {
      const res = await axios.get('http://localhost:3001/api/story-items', {
        params: { story_id: story.id }
      });
      setStoryItems(
        res.data.map((item: any) => ({
          imageFile: null,
          image_url: item.image_url,
          description: item.description,
          display_order: item.display_order,
          is_active: item.is_active
        }))
      );
    } catch (err) {
      setStoryItems([]);
    }
    setIsOpen(true);
  };

  const handleDelete = async (story: Story) => {
    showConfirm({
      title: 'Hikaye Sil',
      message: `"${story.title}" hikayesini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.`,
      confirmText: 'Sil',
      cancelText: 'İptal',
      variant: 'destructive',
      onConfirm: async () => {
        try {
          await axios.delete(`${API_URL}/${story.id}`);
          fetchStories();
        } catch (error) {
          // error handling
        }
      }
    });
  };

  const handleAddStoryItem = () => {
    setStoryItems(items => [
      ...items,
      { imageFile: null, image_url: '', description: '', display_order: items.length + 1, is_active: true }
    ]);
  };
  const handleStoryItemChange = (idx: number, field: keyof StoryItemForm, value: any) => {
    setStoryItems((items: StoryItemForm[]) => items.map((item, i) => i === idx ? { ...item, [field]: value } : item));
  };
  const handleStoryItemImage = (idx: number, file: File | null) => {
    setStoryItems((items: StoryItemForm[]) => items.map((item, i) => {
      if (i !== idx) return item;
      let previewUrl = item.previewUrl;
      if (file) {
        previewUrl = URL.createObjectURL(file);
      } else {
        previewUrl = undefined;
      }
      return { ...item, imageFile: file, previewUrl };
    }));
  };
  const handleRemoveStoryItem = (idx: number) => {
    setStoryItems((items: StoryItemForm[]) => items.filter((_, i) => i !== idx));
  };

  // DND sensors
  const sensors = useSensors(useSensor(PointerSensor));

  const handleDragEnd = (event: any) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;
    const oldIndex = Number(active.id);
    const newIndex = Number(over.id);
    const newItems = arrayMove(storyItems, oldIndex, newIndex).map((item, idx) => ({ ...item, display_order: idx + 1 }));
    setStoryItems(newItems);
  };

  const handleSubmit = async () => {
    try {
      let imageUrl = form.image_url || '';
      if (imageFile) {
        const formData = new FormData();
        formData.append('image', imageFile);
        formData.append('folder', 'stories');
        const uploadRes = await axios.post('http://localhost:3001/api/upload', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        });
        imageUrl = uploadRes.data.url;
      }
      const payload = getStoryPayload(form, imageUrl);
      let storyId = selectedStory?.id;
      if (selectedStory) {
        await axios.put(`${API_URL}/${selectedStory.id}`, payload);
        // --- EKLENDİ: Eski story_items'ları sil ---
        await axios.delete(`http://localhost:3001/api/story-items`, { params: { story_id: selectedStory.id } });
      } else {
        const res = await axios.post(API_URL, payload);
        storyId = res.data.id;
      }
      // Story item'ları ekle
      for (let i = 0; i < storyItems.length; i++) {
        let itemImageUrl = storyItems[i].image_url || '';
        if (storyItems[i].imageFile) {
          const formData = new FormData();
          formData.append('image', storyItems[i].imageFile!);
          formData.append('folder', 'story-items');
          const uploadRes = await axios.post('http://localhost:3001/api/upload', formData, {
            headers: { 'Content-Type': 'multipart/form-data' },
          });
          itemImageUrl = uploadRes.data.url;
          if (!itemImageUrl) {
            alert('Story item görseli yüklenemedi, kayıt yapılmadı!');
            continue;
          }
        }
        await axios.post('http://localhost:3001/api/story-items', {
          story_id: storyId,
          image_url: itemImageUrl,
          description: storyItems[i].description,
          display_order: storyItems[i].display_order,
          is_active: storyItems[i].is_active
        });
      }
      setIsOpen(false);
      fetchStories();
    } catch (error: any) {
      console.error('Submit error:', error);
      alert('Bir hata oluştu: ' + (error.response?.data?.error || error.message));
    }
  };

  const columns: Column<Story>[] = [
    {
      field: 'image_url',
      header: 'Görsel',
      render: (value: string) => (
        <img src={`http://localhost:3001${value}`} alt="Story" className="h-10 w-10 rounded object-cover" />
      ),
    },
    { field: 'title', header: 'Başlık' },
    { field: 'description', header: 'Açıklama' },
    {
      field: 'display_order',
      header: 'Sıra',
      render: (value: number) => <span className="text-center">{value}</span>,
    },
    {
      field: 'is_active',
      header: 'Aktif',
      render: (value: boolean) => (
        <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${value ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>{value ? 'Evet' : 'Hayır'}</span>
      ),
    },
  ];

  const actions: Action<Story>[] = [
    {
      label: 'Düzenle',
      onClick: handleEdit,
      icon: <Edit className="h-4 w-4" />, color: 'default'
    },
    {
      label: 'Sil',
      onClick: handleDelete,
      icon: <Trash2 className="h-4 w-4" />, color: 'destructive'
    }
  ];

  return (
    <PageLayout
      title="Hikayeler"
      subtitle="Uygulamanızda gösterilecek hikayeleri yönetin."
      actions={
        <Button onClick={handleAdd}>
          <Plus className="mr-2 h-4 w-4" />
          Yeni Hikaye
        </Button>
      }
    >
      <DataTable<Story>
        data={stories}
        columns={columns}
        actions={actions}
        pageSize={10}
      />
      
      <Sheet open={isOpen} onOpenChange={setIsOpen}>
        <SheetContent className="sm:max-w-[540px] flex flex-col h-full">
          <SheetHeader>
            <SheetTitle>{selectedStory ? 'Hikaye Düzenle' : 'Yeni Hikaye Ekle'}</SheetTitle>
            <SheetDescription>
              {selectedStory ? 'Hikaye bilgilerini güncelleyin.' : 'Yeni bir hikaye ekleyin.'}
            </SheetDescription>
          </SheetHeader>
          <div className="flex-1 overflow-y-auto">
            <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="title">Başlık</Label>
              <Input id="title" name="title" value={form.title || ''} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} required />
            </div>
            <div className="space-y-2">
              <Label htmlFor="description">Açıklama</Label>
              <Textarea id="description" name="description" value={form.description || ''} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="image">Görsel</Label>
              <Input id="image" type="file" accept="image/*" onChange={e => { if (e.target.files && e.target.files[0]) setImageFile(e.target.files[0]); }} />
              {form.image_url && !imageFile && (
                <div className="mt-2"><img src={form.image_url} alt="" className="w-16 rounded" /></div>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="display_order">Sıra</Label>
              <Input id="display_order" name="display_order" type="number" value={form.display_order || 1} onChange={e => setForm(f => ({ ...f, display_order: Number(e.target.value) }))} required className="w-24" />
            </div>
            <div className="flex items-center gap-2">
              <Switch id="is_active" checked={!!form.is_active} onCheckedChange={v => setForm(f => ({ ...f, is_active: v }))} />
              <Label htmlFor="is_active">Aktif</Label>
            </div>
            <div className="space-y-4">
              <Label>Hikaye İçerikleri</Label>
              <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
                <SortableContext items={storyItems.map((_, idx) => String(idx))} strategy={verticalListSortingStrategy}>
                  {storyItems.map((item, idx) => (
                    <SortableItem key={idx} id={String(idx)}>
                      <div className="border rounded p-3 mb-2 bg-gray-50 flex flex-col gap-2">
                        <div className="flex gap-2 items-center mb-2">
                          <label className="flex items-center gap-2 w-full">
                            <input
                              type="file"
                              accept="image/*"
                              style={{ display: 'none' }}
                              onChange={e => handleStoryItemImage(idx, e.target.files?.[0] || null)}
                            />
                            <span className="border px-2 py-1 rounded bg-white text-gray-700 cursor-pointer">
                              Dosya Seç
                            </span>
                            <span className="text-gray-500 text-sm">
                              {storyItems[idx].imageFile?.name || (storyItems[idx].image_url ? storyItems[idx].image_url.split('/').pop() : 'Dosya seçilmedi')}
                            </span>
                          </label>
                          {(storyItems[idx].previewUrl || storyItems[idx].image_url) && (
                            <img
                              src={
                                (storyItems[idx].previewUrl ||
                                (storyItems[idx].image_url
                                  ? storyItems[idx].image_url.startsWith('/public/uploads/')
                                    ? `http://localhost:3001${storyItems[idx].image_url}`
                                    : `http://localhost:3001/public/uploads/stories/story-items/${storyItems[idx].image_url}`
                                  : null)) ?? undefined
                              }
                              alt="Önizleme"
                              className="w-12 h-12 rounded object-cover border cursor-pointer"
                              style={{ minWidth: 48, minHeight: 48 }}
                              onClick={() => setModalImage(
                                storyItems[idx].previewUrl ||
                                (storyItems[idx].image_url
                                  ? storyItems[idx].image_url.startsWith('/public/uploads/')
                                    ? `http://localhost:3001${storyItems[idx].image_url}`
                                    : `http://localhost:3001/public/uploads/stories/story-items/${storyItems[idx].image_url}`
                                  : null)
                              )}
                            />
                          )}
                          <Button type="button" variant="destructive" size="sm" onClick={() => handleRemoveStoryItem(idx)}>Sil</Button>
                          <span className="cursor-move text-gray-400 ml-2">⇅</span>
                        </div>
                        <Input placeholder="Açıklama" value={item.description} onChange={e => handleStoryItemChange(idx, 'description', e.target.value)} className="mb-2" />
                        <Input type="number" placeholder="Sıra" value={item.display_order} onChange={e => handleStoryItemChange(idx, 'display_order', Number(e.target.value))} className="w-24 mb-2" />
                        <div className="flex items-center gap-2">
                          <Switch checked={item.is_active} onCheckedChange={v => handleStoryItemChange(idx, 'is_active', v)} />
                          <Label>Aktif</Label>
                        </div>
                      </div>
                    </SortableItem>
                  ))}
                </SortableContext>
              </DndContext>
              <Button type="button" onClick={handleAddStoryItem} variant="outline">+ İçerik Ekle</Button>
            </div>
            
            <Button className="mt-4" onClick={handleSubmit}>
              {selectedStory ? 'Kaydet' : 'Ekle'}
            </Button>
          </div>
          </div>
        </SheetContent>
      </Sheet>
      
      {ConfirmDialogComponent}
      {modalImage && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            width: '100vw',
            height: '100vh',
            background: 'rgba(0,0,0,0.7)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000
          }}
          onClick={() => setModalImage(null)}
        >
          <div style={{ position: 'relative', maxWidth: '90vw', maxHeight: '90vh' }} onClick={e => e.stopPropagation()}>
            <img src={modalImage} alt="Büyük Önizleme" style={{ maxWidth: '90vw', maxHeight: '90vh', borderRadius: 8, boxShadow: '0 2px 16px #0008' }} />
            <button
              style={{ position: 'absolute', top: 8, right: 8, background: '#fff', border: 'none', borderRadius: 4, padding: '4px 8px', cursor: 'pointer', fontWeight: 'bold' }}
              onClick={() => setModalImage(null)}
            >Kapat</button>
          </div>
        </div>
      )}
    </PageLayout>
  );
};

// SortableItem bileşeni
type SortableItemProps = {
  id: string;
  children: React.ReactNode;
};
function SortableItem({ id, children }: SortableItemProps) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id });
  return (
    <div
      ref={setNodeRef}
      style={{
        transform: CSS.Transform.toString(transform),
        transition,
        opacity: isDragging ? 0.5 : 1,
        zIndex: isDragging ? 100 : undefined,
      }}
      {...attributes}
      {...listeners}
    >
      {children}
    </div>
  );
}

export default Stories; 