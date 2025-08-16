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
import { Plus, Edit, Trash2, Bell } from 'lucide-react';
import type { Column, Action } from '../../components/ui/data-table';
import { useConfirmDialog } from '../../components/ConfirmDialog';

interface Notification {
  id: string;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  target_audience: 'all' | 'customers' | 'staff';
  scheduled_for: string;
  expires_at: string;
  is_active: boolean;
  is_read: boolean;
  created_at: string;
  send_push?: boolean;
}

const API_URL = 'http://192.168.1.105:3001/api/notifications';

const NotificationsPage: React.FC = () => {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedNotification, setSelectedNotification] = useState<Notification | null>(null);
  const { showConfirm, ConfirmDialogComponent } = useConfirmDialog();
  const [formData, setFormData] = useState<Notification>({
    id: '',
    title: '',
    message: '',
    type: 'info',
    target_audience: 'all',
    scheduled_for: new Date().toISOString().slice(0, 16),
    expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 16),
    is_active: true,
    is_read: false,
    created_at: '',
    send_push: false
  });

  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    setIsLoading(true);
    try {
      const res = await fetch(API_URL);
      const data = await res.json();
      setNotifications(
        data.map((n: any) => ({
          ...n,
          target_audience: n.target_audience || 'all',
          scheduled_for: n.scheduled_for || '',
          expires_at: n.expires_at || '',
          is_active: typeof n.is_active === 'boolean' ? n.is_active : true,
          is_read: typeof n.is_read === 'boolean' ? n.is_read : false,
          created_at: n.created_at || ''
        }))
      );
    } catch (e) {
      alert('Failed to fetch notifications');
    } finally {
      setIsLoading(false);
    }
  };

  const handleAdd = () => {
    setSelectedNotification(null);
    setFormData({
      id: '',
      title: '',
      message: '',
      type: 'info',
      target_audience: 'all',
      scheduled_for: new Date().toISOString().slice(0, 16),
      expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 16),
      is_active: true,
      is_read: false,
      created_at: '',
      send_push: false
    });
    setIsOpen(true);
  };

  const handleEdit = (notification: Notification) => {
    setSelectedNotification(notification);
    setFormData(notification);
    setIsOpen(true);
  };

  const handleDelete = async (notification: Notification) => {
    showConfirm({
      title: 'Bildirimi Sil',
      message: `"${notification.title}" bildirimini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.`,
      confirmText: 'Sil',
      cancelText: 'İptal',
      variant: 'destructive',
      onConfirm: async () => {
        try {
          await fetch(`${API_URL}/${notification.id}`, { method: 'DELETE' });
          fetchNotifications();
        } catch (e) {
          alert('Bildirim silinirken bir hata oluştu');
        }
      }
    });
  };

  const handleSubmit = async () => {
    try {
      // Form verilerini hazırla
      const notificationData = {
        title: formData.title,
        message: formData.message,
        type: formData.type,
        is_read: formData.is_read,
        target_audience: formData.target_audience,
        scheduled_for: formData.scheduled_for ? new Date(formData.scheduled_for).toISOString() : new Date().toISOString(),
        expires_at: formData.expires_at ? new Date(formData.expires_at).toISOString() : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        is_active: formData.is_active,
        send_push: formData.send_push,
        user_id: "all"
      };

      if (selectedNotification) {
        await fetch(`${API_URL}/${selectedNotification.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(notificationData)
        });
      } else {
        const response = await fetch(API_URL, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(notificationData)
        });
        
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.error || 'Failed to create notification');
        }
      }
      setIsOpen(false);
      fetchNotifications();
    } catch (e) {
      console.error('Notification save error:', e);
      alert(`Failed to save notification: ${e instanceof Error ? e.message : 'Unknown error'}`);
    }
  };

  const actions: Action<Notification>[] = [
    {
      label: 'Edit Notification',
      onClick: handleEdit,
      icon: <Edit className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'Delete Notification',
      onClick: handleDelete,
      icon: <Trash2 className="h-4 w-4" />,
      color: 'destructive'
    }
  ];

  const columns: Column<Notification>[] = [
    { field: 'title', header: 'Title' },
    { field: 'message', header: 'Message' },
    {
      field: 'type',
      header: 'Type',
      render: (value: string) => (
        <span
          className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
            value === 'info'
              ? 'bg-blue-100 text-blue-800'
              : value === 'success'
              ? 'bg-green-100 text-green-800'
              : value === 'warning'
              ? 'bg-yellow-100 text-yellow-800'
              : 'bg-red-100 text-red-800'
          }`}
        >
          {value.charAt(0).toUpperCase() + value.slice(1)}
        </span>
      ),
    },
    {
      field: 'target_audience',
      header: 'Audience',
      render: (value: string) => value.charAt(0).toUpperCase() + value.slice(1),
    },
    {
      field: 'scheduled_for',
      header: 'Scheduled For',
      render: (value: string) => new Date(value).toLocaleString(),
    },
    {
      field: 'expires_at',
      header: 'Expires At',
      render: (value: string) => new Date(value).toLocaleString(),
    },
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
      title="Notifications"
      subtitle="Manage your system notifications"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="mr-2 h-4 w-4" />
          Add Notification
        </Button>
      }
    >
      <Card>
        <CardHeader>
          <CardTitle>System Notifications</CardTitle>
          <CardDescription>
            View and manage all your system notifications
          </CardDescription>
        </CardHeader>
        <CardContent>
          <DataTable<Notification>
            data={notifications}
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
              {selectedNotification ? 'Edit Notification' : 'Add Notification'}
            </SheetTitle>
            <SheetDescription>
              {selectedNotification
                ? 'Update the notification details below'
                : 'Fill in the notification details below'}
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
                placeholder="Enter notification title"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="message">Message</Label>
              <Input
                id="message"
                value={formData.message}
                onChange={(e) =>
                  setFormData({ ...formData, message: e.target.value })
                }
                placeholder="Enter notification message"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="type">Type</Label>
                <select
                  id="type"
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  value={formData.type}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      type: e.target.value as Notification['type']
                    })
                  }
                >
                  <option value="info">Info</option>
                  <option value="success">Success</option>
                  <option value="warning">Warning</option>
                  <option value="error">Error</option>
                </select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="target_audience">Target Audience</Label>
                <select
                  id="target_audience"
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  value={formData.target_audience}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      target_audience: e.target.value as Notification['target_audience']
                    })
                  }
                >
                  <option value="all">All</option>
                  <option value="customers">Customers</option>
                  <option value="staff">Staff</option>
                </select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="scheduled_for">Schedule For</Label>
                <Input
                  id="scheduled_for"
                  type="datetime-local"
                  value={formData.scheduled_for.slice(0, 16)}
                  onChange={(e) =>
                    setFormData({ ...formData, scheduled_for: e.target.value })
                  }
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="expires_at">Expires At</Label>
                <Input
                  id="expires_at"
                  type="datetime-local"
                  value={formData.expires_at.slice(0, 16)}
                  onChange={(e) =>
                    setFormData({ ...formData, expires_at: e.target.value })
                  }
                />
              </div>
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
            <div className="flex items-center space-x-2">
              <Switch
                id="send_push"
                checked={formData.send_push}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, send_push: checked })
                }
              />
              <Label htmlFor="send_push">Send Push Notification</Label>
            </div>
            <Button className="mt-4" onClick={handleSubmit}>
              {selectedNotification ? 'Update Notification' : 'Add Notification'}
            </Button>
          </div>
        </SheetContent>
      </Sheet>
      
      {ConfirmDialogComponent}
    </PageLayout>
  );
};

export default NotificationsPage; 