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
import { campaignApi } from '../../services/api';
import type { Campaign as ApiCampaign } from '../../types';
import { useConfirmDialog } from '../../components/ConfirmDialog';

interface CampaignFormData {
  title: string;
  description?: string;
  start_date: string;
  end_date: string;
  is_active: boolean;
  image_url?: string;
  campaign_type?: string;
  required_count?: number;
  reward_count?: number;
  reward_product_id?: string;
}

const CampaignsPage: React.FC = () => {
  const [campaigns, setCampaigns] = useState<ApiCampaign[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedCampaign, setSelectedCampaign] = useState<ApiCampaign | null>(null);
  const { showConfirm, ConfirmDialogComponent } = useConfirmDialog();
  const [formData, setFormData] = useState<CampaignFormData>({
    title: '',
    description: '',
    start_date: '',
    end_date: '',
    is_active: true,
    image_url: '',
    campaign_type: 'general',
    required_count: 1,
    reward_count: 1,
    reward_product_id: ''
  });
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    fetchCampaigns();
  }, []);

  const fetchCampaigns = async () => {
    try {
      setIsLoading(true);
      const data = await campaignApi.getAll();
      setCampaigns(data);
    } catch (error) {
      alert('Failed to fetch campaigns');
    } finally {
      setIsLoading(false);
    }
  };

  const handleAdd = () => {
    setSelectedCampaign(null);
    setFormData({
      title: '',
      description: '',
      start_date: '',
      end_date: '',
      is_active: true,
      image_url: '',
      campaign_type: 'general',
      required_count: 1,
      reward_count: 1,
      reward_product_id: ''
    });
    setIsOpen(true);
  };

  const handleEdit = (campaign: ApiCampaign) => {
    setSelectedCampaign(campaign);
    setFormData({
      ...campaign,
      start_date: new Date(campaign.start_date).toISOString().split('T')[0],
      end_date: new Date(campaign.end_date).toISOString().split('T')[0]
    });
    setIsOpen(true);
  };

  const handleDelete = async (campaign: ApiCampaign) => {
    showConfirm({
      title: 'Kampanyayı Sil',
      message: `"${campaign.title}" kampanyasını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.`,
      confirmText: 'Sil',
      cancelText: 'İptal',
      variant: 'destructive',
      onConfirm: async () => {
        try {
          await campaignApi.delete(campaign.id);
          fetchCampaigns();
          alert('Kampanya başarıyla silindi');
        } catch (error) {
          alert('Kampanya silinirken bir hata oluştu');
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
      const campaignData = {
        ...formData,
        start_date: new Date(formData.start_date),
        end_date: new Date(formData.end_date)
      };

      if (selectedCampaign) {
        await campaignApi.update(selectedCampaign.id, campaignData);
        alert('Campaign updated successfully');
      } else {
        await campaignApi.create(campaignData);
        alert('Campaign created successfully');
      }
      setIsOpen(false);
      fetchCampaigns();
    } catch (error) {
      alert(selectedCampaign ? 'Failed to update campaign' : 'Failed to create campaign');
    }
  };

  const actions: Action<ApiCampaign>[] = [
    {
      label: 'Edit Campaign',
      onClick: handleEdit,
      icon: <Edit className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'Delete Campaign',
      onClick: handleDelete,
      icon: <Trash2 className="h-4 w-4" />,
      color: 'destructive'
    }
  ];

  const columns: Column<ApiCampaign>[] = [
    {
      field: 'image_url',
      header: 'Image',
      render: (value: string) => (
        <img
          src={value}
          alt="Campaign"
          className="h-10 w-10 rounded-full object-cover"
        />
      ),
    },
    { field: 'title', header: 'Name' },
    { field: 'description', header: 'Description' },
    {
      field: 'start_date',
      header: 'Start Date',
      render: (value: Date) => new Date(value).toLocaleDateString(),
    },
    {
      field: 'end_date',
      header: 'End Date',
      render: (value: Date) => new Date(value).toLocaleDateString(),
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
      title="Campaigns"
      subtitle="Manage your promotional campaigns"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="mr-2 h-4 w-4" />
          Add Campaign
        </Button>
      }
    >
      <Card>
        <CardHeader>
          <CardTitle>Promotional Campaigns</CardTitle>
          <CardDescription>
            View and manage all your promotional campaigns
          </CardDescription>
        </CardHeader>
        <CardContent>
          <DataTable<ApiCampaign>
            data={campaigns}
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
              {selectedCampaign ? 'Edit Campaign' : 'Add Campaign'}
            </SheetTitle>
            <SheetDescription>
              {selectedCampaign
                ? 'Update the campaign details below'
                : 'Fill in the campaign details below'}
            </SheetDescription>
          </SheetHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="title">Campaign Title</Label>
              <Input
                id="title"
                value={formData.title}
                onChange={(e) =>
                  setFormData({ ...formData, title: e.target.value })
                }
                placeholder="Enter campaign title"
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
                placeholder="Enter campaign description"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="start_date">Start Date</Label>
              <Input
                id="start_date"
                type="date"
                value={formData.start_date}
                onChange={(e) =>
                  setFormData({ ...formData, start_date: e.target.value })
                }
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="end_date">End Date</Label>
              <Input
                id="end_date"
                type="date"
                value={formData.end_date}
                onChange={(e) =>
                  setFormData({ ...formData, end_date: e.target.value })
                }
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
                  formDataImg.append('folder', 'campaigns');
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
            
            <div className="space-y-2">
              <Label htmlFor="campaign_type">Campaign Type</Label>
              <select
                id="campaign_type"
                value={formData.campaign_type}
                onChange={(e) =>
                  setFormData({ ...formData, campaign_type: e.target.value })
                }
                className="w-full p-2 border border-gray-300 rounded-md"
              >
                <option value="general">General</option>
                <option value="buy_x_get_y">Buy X Get Y</option>
                <option value="loyalty">Loyalty</option>
              </select>
            </div>
            
            {formData.campaign_type === 'buy_x_get_y' && (
              <>
                <div className="space-y-2">
                  <Label htmlFor="required_count">Required Count (X)</Label>
                  <Input
                    id="required_count"
                    type="number"
                    min="1"
                    value={formData.required_count}
                    onChange={(e) =>
                      setFormData({ ...formData, required_count: parseInt(e.target.value) || 1 })
                    }
                    placeholder="e.g., 9"
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="reward_count">Reward Count (Y)</Label>
                  <Input
                    id="reward_count"
                    type="number"
                    min="1"
                    value={formData.reward_count}
                    onChange={(e) =>
                      setFormData({ ...formData, reward_count: parseInt(e.target.value) || 1 })
                    }
                    placeholder="e.g., 1"
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="reward_product_id">Reward Product ID</Label>
                  <Input
                    id="reward_product_id"
                    value={formData.reward_product_id}
                    onChange={(e) =>
                      setFormData({ ...formData, reward_product_id: e.target.value })
                    }
                    placeholder="Product ID for reward"
                  />
                </div>
              </>
            )}
            
            <Button className="mt-4" onClick={handleSubmit} disabled={uploading}>
              {selectedCampaign ? 'Update Campaign' : 'Add Campaign'}
            </Button>
          </div>
        </SheetContent>
      </Sheet>
      
      {ConfirmDialogComponent}
    </PageLayout>
  );
};

export default CampaignsPage; 