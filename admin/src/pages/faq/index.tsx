import React, { useState, useEffect } from 'react';
import { PageLayout } from '../../components/PageLayout';
import { DataTable } from '../../components/ui/data-table';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { Switch } from '../../components/ui/switch';
import { Textarea } from '../../components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../components/ui/select';
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
import { Plus, Edit, Trash2, ArrowUp, ArrowDown } from 'lucide-react';
import type { Column, Action } from '../../components/ui/data-table';
import { useConfirmDialog } from '../../components/ConfirmDialog';

interface FAQ {
  id: string;
  question: string;
  answer: string;
  category: string;
  display_order: number;
  is_active: boolean;
  created_at: string;
}

const faqCategories = [
  { value: 'general', label: 'General', color: 'blue' },
  { value: 'orders', label: 'Orders', color: 'purple' },
  { value: 'menu', label: 'Menu', color: 'green' },
  { value: 'delivery', label: 'Delivery', color: 'cyan' },
  { value: 'payment', label: 'Payment', color: 'yellow' },
];

const API_URL = 'http://localhost:3001/api/faqs';

const FAQPage: React.FC = () => {
  const [faqs, setFaqs] = useState<FAQ[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedFAQ, setSelectedFAQ] = useState<FAQ | null>(null);
  const { showConfirm, ConfirmDialogComponent } = useConfirmDialog();
  const [formData, setFormData] = useState<FAQ>({
    id: '',
    question: '',
    answer: '',
    category: '',
    display_order: 1,
    is_active: true,
    created_at: ''
  });

  useEffect(() => {
    fetchFaqs();
  }, []);

  const fetchFaqs = async () => {
    setIsLoading(true);
    try {
      const res = await fetch(API_URL);
      const data = await res.json();
      setFaqs(data);
    } catch (e) {
      alert('Failed to fetch FAQs');
    } finally {
      setIsLoading(false);
    }
  };

  const handleAdd = () => {
    setSelectedFAQ(null);
    setFormData({
      id: '',
      question: '',
      answer: '',
      category: 'general',
      display_order: Math.max(0, ...faqs.map(faq => faq.display_order)) + 1,
      is_active: true,
      created_at: ''
    });
    setIsOpen(true);
  };

  const handleEdit = (faq: FAQ) => {
    setSelectedFAQ(faq);
    setFormData(faq);
    setIsOpen(true);
  };

  const handleDelete = async (faq: FAQ) => {
    showConfirm({
      title: 'FAQ Sil',
      message: `"${faq.question}" sorusunu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.`,
      confirmText: 'Sil',
      cancelText: 'İptal',
      variant: 'destructive',
      onConfirm: async () => {
        try {
          await fetch(`${API_URL}/${faq.id}`, { method: 'DELETE' });
          fetchFaqs();
        } catch (e) {
          alert('FAQ silinirken bir hata oluştu');
        }
      }
    });
  };

  const handleMoveUp = (faq: FAQ) => {
    if (faq.display_order <= 1) return;
    const newFaqs = faqs.map(f => {
      if (f.id === faq.id) {
        return { ...f, display_order: f.display_order - 1 };
      }
      if (f.display_order === faq.display_order - 1) {
        return { ...f, display_order: f.display_order + 1 };
      }
      return f;
    });
    setFaqs(newFaqs.sort((a, b) => a.display_order - b.display_order));
  };

  const handleMoveDown = (faq: FAQ) => {
    const maxOrder = Math.max(...faqs.map(f => f.display_order));
    if (faq.display_order >= maxOrder) return;
    const newFaqs = faqs.map(f => {
      if (f.id === faq.id) {
        return { ...f, display_order: f.display_order + 1 };
      }
      if (f.display_order === faq.display_order + 1) {
        return { ...f, display_order: f.display_order - 1 };
      }
      return f;
    });
    setFaqs(newFaqs.sort((a, b) => a.display_order - b.display_order));
  };

  const handleSubmit = async () => {
    try {
      if (selectedFAQ) {
        await fetch(`${API_URL}/${selectedFAQ.id}`, {
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
      fetchFaqs();
    } catch (e) {
      alert('Failed to save FAQ');
    }
  };

  const actions: Action<FAQ>[] = [
    {
      label: 'Move Up',
      onClick: handleMoveUp,
      icon: <ArrowUp className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'Move Down',
      onClick: handleMoveDown,
      icon: <ArrowDown className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'Edit FAQ',
      onClick: handleEdit,
      icon: <Edit className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'Delete FAQ',
      onClick: handleDelete,
      icon: <Trash2 className="h-4 w-4" />,
      color: 'destructive'
    }
  ];

  const columns: Column<FAQ>[] = [
    { field: 'question', header: 'Question' },
    { 
      field: 'answer',
      header: 'Answer',
      render: (value: string) => (
        <div className="max-w-xl whitespace-normal">{value}</div>
      )
    },
    {
      field: 'category',
      header: 'Category',
      render: (value: string) => {
        const category = faqCategories.find(c => c.value === value);
        return category ? (
          <span
            className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium bg-${category.color}-100 text-${category.color}-800`}
          >
            {category.label}
          </span>
        ) : value;
      }
    },
    { field: 'display_order', header: 'Order' },
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
      title="FAQ"
      subtitle="Manage your frequently asked questions"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="mr-2 h-4 w-4" />
          Add FAQ
        </Button>
      }
    >
      <Card>
        <CardHeader>
          <CardTitle>Frequently Asked Questions</CardTitle>
          <CardDescription>
            View and manage all your FAQs
          </CardDescription>
        </CardHeader>
        <CardContent>
          <DataTable<FAQ>
            data={faqs}
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
              {selectedFAQ ? 'Edit FAQ' : 'Add FAQ'}
            </SheetTitle>
            <SheetDescription>
              {selectedFAQ
                ? 'Update the FAQ details below'
                : 'Fill in the FAQ details below'}
            </SheetDescription>
          </SheetHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="question">Question</Label>
              <Input
                id="question"
                value={formData.question}
                onChange={(e) =>
                  setFormData({ ...formData, question: e.target.value })
                }
                placeholder="Enter FAQ question"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="answer">Answer</Label>
              <Textarea
                id="answer"
                value={formData.answer}
                onChange={(e) =>
                  setFormData({ ...formData, answer: e.target.value })
                }
                placeholder="Enter FAQ answer"
                className="min-h-[100px]"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="category">Category</Label>
              <Select
                value={formData.category}
                onValueChange={(value) =>
                  setFormData({ ...formData, category: value })
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select a category" />
                </SelectTrigger>
                <SelectContent>
                  {faqCategories.map((category) => (
                    <SelectItem key={category.value} value={category.value}>
                      {category.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label htmlFor="display_order">Display Order</Label>
              <Input
                id="display_order"
                type="number"
                value={formData.display_order}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    display_order: parseInt(e.target.value) || 0
                  })
                }
                placeholder="Enter display order"
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
              {selectedFAQ ? 'Update FAQ' : 'Add FAQ'}
            </Button>
          </div>
        </SheetContent>
      </Sheet>
      
      {ConfirmDialogComponent}
    </PageLayout>
  );
};

export default FAQPage; 