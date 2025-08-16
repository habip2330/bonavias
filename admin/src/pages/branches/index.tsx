import React, { useState, useEffect } from 'react';
import { PageLayout } from '../../components/PageLayout';
import { DataTable } from '../../components/ui/data-table';
import { Button } from '../../components/ui/button';
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
import { MapPin, Plus, Map, Edit, Trash2 } from 'lucide-react';
import type { Branch, WorkingHours, DaySchedule } from '../../types';
import type { Column, Action } from '../../components/ui/data-table';
import { WorkingHoursEditor } from '../../components/WorkingHoursEditor';

const API_URL = 'http://localhost:3001/api/branches';

// Helper functions for working hours
const createDefaultWorkingHours = (): WorkingHours => ({
  monday: { day: 'Pazartesi', isOpen: true, openTime: '09:00', closeTime: '22:00' },
  tuesday: { day: 'Salı', isOpen: true, openTime: '09:00', closeTime: '22:00' },
  wednesday: { day: 'Çarşamba', isOpen: true, openTime: '09:00', closeTime: '22:00' },
  thursday: { day: 'Perşembe', isOpen: true, openTime: '09:00', closeTime: '22:00' },
  friday: { day: 'Cuma', isOpen: true, openTime: '09:00', closeTime: '22:00' },
  saturday: { day: 'Cumartesi', isOpen: true, openTime: '09:00', closeTime: '22:00' },
  sunday: { day: 'Pazar', isOpen: true, openTime: '09:00', closeTime: '22:00' }
});

const parseWorkingHours = (workingHoursStr: string | WorkingHours | undefined): WorkingHours => {
  if (!workingHoursStr) return createDefaultWorkingHours();
  if (typeof workingHoursStr === 'object') return workingHoursStr;
  
  try {
    return JSON.parse(workingHoursStr);
  } catch {
    return createDefaultWorkingHours();
  }
};

const workingHoursToString = (workingHours: WorkingHours): string => {
  return JSON.stringify(workingHours);
};

interface BranchFormData extends Omit<Branch, 'working_hours'> {
  working_hours_object: WorkingHours;
}

const BranchesPage: React.FC = () => {
  const [branches, setBranches] = useState<Branch[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedBranch, setSelectedBranch] = useState<Branch | null>(null);
  const { showConfirm, ConfirmDialogComponent } = useConfirmDialog();
  const [formData, setFormData] = useState<BranchFormData>({
    id: '',
    name: '',
    address: '',
    phone: '',
    email: '',
    latitude: '',
    longitude: '',
    opening_hours: '',
    location: '',
    is_active: true,
    working_hours_object: createDefaultWorkingHours()
  });

  useEffect(() => {
    fetchBranches();
  }, []);

  const fetchBranches = async () => {
    setIsLoading(true);
    try {
      const res = await fetch(API_URL);
      const data = await res.json();
      setBranches(data);
    } catch (e) {
      alert('Failed to fetch branches');
    } finally {
      setIsLoading(false);
    }
  };

  const handleAdd = () => {
    setSelectedBranch(null);
    setFormData({
      id: '',
      name: '',
      address: '',
      location: '',
      phone: '',
      email: '',
      latitude: '',
      longitude: '',
      opening_hours: '',
      is_active: true,
      working_hours_object: createDefaultWorkingHours()
    });
    setIsOpen(true);
  };

  const handleEdit = (branch: Branch) => {
    console.log('🔍 Edit branch data:', branch);
    setSelectedBranch(branch);
    
    // Veritabanı alan isimlerini form alan isimlerine dönüştür
    const mappedFormData: BranchFormData = {
      id: branch.id,
      name: branch.name || '',
      address: branch.address || '',
      location: branch.location || '',
      phone: branch.phone || '',
      email: branch.email || '',
      latitude: String(branch.latitude || ''), // Number'ı string'e çevir
      longitude: String(branch.longitude || ''), // Number'ı string'e çevir
      opening_hours: branch.opening_hours || '', 
      is_active: Boolean(branch.is_active),
      working_hours_object: parseWorkingHours(branch.working_hours)
    };
    
    console.log('🔧 Mapped form data:', mappedFormData);
    setFormData(mappedFormData);
    setIsOpen(true);
  };

  const handleDelete = async (branch: Branch) => {
    showConfirm({
      title: 'Şubeyi Sil',
      message: `"${branch.name}" şubesini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.`,
      confirmText: 'Sil',
      cancelText: 'İptal',
      variant: 'destructive',
      onConfirm: async () => {
        try {
          await fetch(`${API_URL}/${branch.id}`, { method: 'DELETE' });
          fetchBranches();
        } catch (e) {
          alert('Şube silinirken bir hata oluştu');
        }
      }
    });
  };

  const handleSubmit = async () => {
    try {
      // Form verisini API formatına dönüştür
      const submitData = {
        ...formData,
        working_hours: workingHoursToString(formData.working_hours_object)
      };
      
      // working_hours_object'i API'ye göndermek için kaldır
      const { working_hours_object, ...apiData } = submitData;
      
      if (selectedBranch) {
        await fetch(`${API_URL}/${selectedBranch.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(apiData)
        });
      } else {
        await fetch(API_URL, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(apiData)
        });
      }
      setIsOpen(false);
      fetchBranches();
    } catch (e) {
      alert('Failed to save branch');
    }
  };

  const handleViewMap = (branch: Branch) => {
    window.open(
      `https://www.google.com/maps?q=${branch.latitude},${branch.longitude}`,
      '_blank'
    );
  };

  const actions: Action<Branch>[] = [
    {
      label: 'Edit Branch',
      onClick: handleEdit,
      icon: <Edit className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'View Map',
      onClick: handleViewMap,
      icon: <Map className="h-4 w-4" />,
      color: 'default'
    },
    {
      label: 'Delete Branch',
      onClick: handleDelete,
      icon: <Trash2 className="h-4 w-4" />,
      color: 'destructive'
    }
  ];

  const columns: Column<Branch>[] = [
    { field: 'name', header: 'Name' },
    { field: 'address', header: 'Address' },
    { field: 'location', header: 'Location' },
    { field: 'phone', header: 'Phone' },
    { 
      field: 'working_hours', 
      header: 'Working Hours',
      render: (value: string | WorkingHours | undefined) => {
        if (!value) return 'Belirtilmemiş';
        
        try {
          const workingHours = typeof value === 'string' ? JSON.parse(value) : value;
          const openDays = Object.values(workingHours as WorkingHours)
            .filter((day: DaySchedule) => day.isOpen)
            .length;
          
          if (openDays === 0) return 'Kapalı';
          if (openDays === 7) {
            const firstOpenDay = Object.values(workingHours as WorkingHours)
              .find((day: DaySchedule) => day.isOpen);
            return `Her gün: ${firstOpenDay?.openTime} - ${firstOpenDay?.closeTime}`;
          }
          return `${openDays} gün açık`;
        } catch {
          return String(value);
        }
      }
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
      title="Branches"
      subtitle="Manage your restaurant branches"
      actions={
        <Button onClick={handleAdd}>
          <Plus className="mr-2 h-4 w-4" />
          Add Branch
        </Button>
      }
    >
      <Card>
        <CardHeader>
          <CardTitle>Branch Locations</CardTitle>
          <CardDescription>
            View and manage all your restaurant branches
          </CardDescription>
        </CardHeader>
        <CardContent>
          <DataTable<Branch>
            data={branches}
            columns={columns}
            actions={actions}
            pageSize={10}
          />
        </CardContent>
      </Card>

      <Sheet open={isOpen} onOpenChange={setIsOpen}>
        <SheetContent className="sm:max-w-[800px] overflow-y-auto">
          <SheetHeader>
            <SheetTitle>{selectedBranch ? 'Edit Branch' : 'Add Branch'}</SheetTitle>
            <SheetDescription>
              {selectedBranch
                ? 'Update the branch details below'
                : 'Fill in the branch details below'}
            </SheetDescription>
          </SheetHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="name">Branch Name</Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
                placeholder="Enter branch name"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="address">Address</Label>
              <Input
                id="address"
                value={formData.address}
                onChange={(e) =>
                  setFormData({ ...formData, address: e.target.value })
                }
                placeholder="Enter branch address"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="location">Location</Label>
              <Input
                id="location"
                value={formData.location || ''}
                onChange={(e) =>
                  setFormData({ ...formData, location: e.target.value })
                }
                placeholder="Enter location description"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="phone">Phone</Label>
                <Input
                  id="phone"
                  value={formData.phone}
                  onChange={(e) =>
                    setFormData({ ...formData, phone: e.target.value })
                  }
                  placeholder="Enter phone number"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) =>
                    setFormData({ ...formData, email: e.target.value })
                  }
                  placeholder="Enter email address"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="latitude">Latitude</Label>
                <Input
                  id="latitude"
                  value={formData.latitude}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      latitude: e.target.value
                    })
                  }
                  placeholder="Enter latitude"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="longitude">Longitude</Label>
                <Input
                  id="longitude"
                  value={formData.longitude}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      longitude: e.target.value
                    })
                  }
                  placeholder="Enter longitude"
                />
              </div>
            </div>
            <div className="space-y-4">
              <WorkingHoursEditor
                workingHours={formData.working_hours_object}
                onChange={(workingHours) =>
                  setFormData({ ...formData, working_hours_object: workingHours })
                }
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
          </div>
          <div className="mt-6 flex justify-end space-x-2">
            <Button variant="outline" onClick={() => setIsOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleSubmit}>
              {selectedBranch ? 'Update Branch' : 'Add Branch'}
            </Button>
          </div>
        </SheetContent>
      </Sheet>
      
      {ConfirmDialogComponent}
    </PageLayout>
  );
};

export default BranchesPage; 