import React, { useState } from 'react';
import { PageLayout } from '../components/PageLayout';
import { DataTable, Column, Action } from '../components/ui/data-table';
import type { User } from '../types';
import {
  UserPlus,
  Edit,
  Trash2,
  Mail,
  Shield,
  User as UserIcon,
} from 'lucide-react';
import { Button } from '../components/ui/button';
import { cn } from '../lib/utils';
import { useConfirmDialog } from '../components/ConfirmDialog';

const RoleBadge = ({ role }: { role: User['role'] }) => {
  const config = {
    admin: {
      label: 'Admin',
      className: 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200',
      icon: Shield,
    },
    staff: {
      label: 'Staff',
      className: 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
      icon: UserIcon,
    },
  };

  const { label, className, icon: Icon } = config[role];

  return (
    <div className={cn(
      'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium',
      className
    )}>
      <Icon className="w-3 h-3 mr-1" />
      {label}
    </div>
  );
};

const Users: React.FC = () => {
  const { showConfirm, ConfirmDialogComponent } = useConfirmDialog();
  const [users, setUsers] = useState<User[]>([
    {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'admin',
      createdAt: '2024-01-01T00:00:00Z',
    },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'staff',
      createdAt: '2024-01-02T00:00:00Z',
    },
    // Add more mock users as needed
  ]);

  const handleDeleteUser = (user: User) => {
    showConfirm({
      title: 'Kullanıcıyı Sil',
      message: `"${user.name}" kullanıcısını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.`,
      confirmText: 'Sil',
      cancelText: 'İptal',
      variant: 'destructive',
      onConfirm: () => {
        setUsers(users.filter((u) => u.id !== user.id));
      }
    });
  };

  const handleEditUser = (user: User) => {
    // Implement edit user logic
    console.log('Edit user:', user);
  };

  const handleEmailUser = (user: User) => {
    window.location.href = `mailto:${user.email}`;
  };

  const columns: Column<User>[] = [
    {
      field: 'name',
      header: 'Name',
    },
    {
      field: 'email',
      header: 'Email',
    },
    {
      field: 'role',
      header: 'Role',
      render: (value) => <RoleBadge role={value} />,
    },
    {
      field: 'createdAt',
      header: 'Created',
      render: (value) => (
        <span className="text-muted-foreground">
          {new Date(value).toLocaleDateString()}
        </span>
      ),
    },
  ];

  const actions: Action<User>[] = [
    {
      label: 'Email User',
      onClick: handleEmailUser,
      icon: <Mail className="h-4 w-4" />,
      color: 'outline',
    },
    {
      label: 'Edit User',
      onClick: handleEditUser,
      icon: <Edit className="h-4 w-4" />,
      color: 'default',
    },
    {
      label: 'Delete User',
      onClick: handleDeleteUser,
      icon: <Trash2 className="h-4 w-4" />,
      color: 'destructive',
      tooltip: 'Delete this user',
    },
  ];

  return (
    <PageLayout
      title="Users"
      subtitle="Manage your team members and their roles"
      actions={
        <Button className="gap-2">
          <UserPlus className="h-4 w-4" />
          Add User
        </Button>
      }
    >
      <DataTable
        data={users}
        columns={columns}
        actions={actions}
        pageSize={10}
      />
      
      {ConfirmDialogComponent}
    </PageLayout>
  );
};

export default Users; 