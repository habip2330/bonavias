import React, { useState } from 'react';
import { PageLayout } from '../components/PageLayout';
import { DataTable, Column, Action } from '../components/ui/data-table';
import type { Order } from '../types';
import { cn } from '../lib/utils';
import {
  CheckCircle,
  XCircle,
  Utensils,
  Truck,
  Clock,
} from 'lucide-react';

const OrderStatusChip = ({ status }: { status: Order['status'] }) => {
  const getStatusConfig = (status: Order['status']) => {
    switch (status) {
      case 'pending':
        return {
          label: 'Pending',
          icon: Clock,
          className: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
        };
      case 'preparing':
        return {
          label: 'Preparing',
          icon: Utensils,
          className: 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
        };
      case 'ready':
        return {
          label: 'Ready',
          icon: CheckCircle,
          className: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
        };
      case 'delivered':
        return {
          label: 'Delivered',
          icon: Truck,
          className: 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200',
        };
      case 'cancelled':
        return {
          label: 'Cancelled',
          icon: XCircle,
          className: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
        };
    }
  };

  const config = getStatusConfig(status);
  const Icon = config.icon;

  return (
    <div className={cn(
      'inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium',
      config.className
    )}>
      <Icon className="w-4 h-4 mr-1" />
      {config.label}
    </div>
  );
};

const OrderItems = ({ items }: { items: Order['items'] }) => {
  return (
    <div className="space-y-1">
      {items.map((item, index) => (
        <div
          key={index}
          className="flex justify-between text-sm"
        >
          <span className="font-medium">
            {item.quantity}x {item.menuItem.name}
          </span>
          <span className="text-muted-foreground">
            ${(item.menuItem.price * item.quantity).toFixed(2)}
          </span>
        </div>
      ))}
    </div>
  );
};

const Orders: React.FC = () => {
  const [orders, setOrders] = useState<Order[]>([
    {
      id: '1',
      items: [
        {
          menuItem: {
            id: '1',
            name: 'Margherita Pizza',
            description: 'Classic tomato and mozzarella',
            price: 12.99,
            category: 'Pizza',
            isAvailable: true,
          },
          quantity: 2,
          notes: 'Extra cheese',
        },
      ],
      status: 'pending',
      totalAmount: 25.98,
      customerName: 'John Doe',
      tableNumber: 5,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
    // Add more mock orders as needed
  ]);

  const columns: Column<Order>[] = [
    {
      field: 'id',
      header: 'Order ID',
    },
    {
      field: 'customerName',
      header: 'Customer',
    },
    {
      field: 'items',
      header: 'Items',
      render: (value) => <OrderItems items={value} />,
    },
    {
      field: 'totalAmount',
      header: 'Total',
      render: (value) => (
        <span className="font-medium">
          ${value.toFixed(2)}
        </span>
      ),
    },
    {
      field: 'tableNumber',
      header: 'Table',
    },
    {
      field: 'status',
      header: 'Status',
      render: (value) => <OrderStatusChip status={value} />,
    },
    {
      field: 'createdAt',
      header: 'Created',
      render: (value) => (
        <span className="text-muted-foreground">
          {new Date(value).toLocaleString()}
        </span>
      ),
    },
  ];

  const handleStatusChange = (order: Order, newStatus: Order['status']) => {
    setOrders(
      orders.map((o) =>
        o.id === order.id
          ? { ...o, status: newStatus, updatedAt: new Date().toISOString() }
          : o
      )
    );
  };

  const actions: Action<Order>[] = [
    {
      label: 'Mark as Preparing',
      onClick: (order) => handleStatusChange(order, 'preparing'),
      icon: <Utensils className="h-4 w-4" />,
      hide: (order) => order.status !== 'pending',
      color: 'default',
    },
    {
      label: 'Mark as Ready',
      onClick: (order) => handleStatusChange(order, 'ready'),
      icon: <CheckCircle className="h-4 w-4" />,
      hide: (order) => order.status !== 'preparing',
      color: 'default',
    },
    {
      label: 'Mark as Delivered',
      onClick: (order) => handleStatusChange(order, 'delivered'),
      icon: <Truck className="h-4 w-4" />,
      hide: (order) => order.status !== 'ready',
      color: 'default',
    },
    {
      label: 'Cancel Order',
      onClick: (order) => handleStatusChange(order, 'cancelled'),
      icon: <XCircle className="h-4 w-4" />,
      hide: (order) => ['delivered', 'cancelled'].includes(order.status),
      color: 'destructive',
    },
  ];

  return (
    <PageLayout
      title="Orders"
      subtitle="Manage and track all orders in real-time"
    >
      <DataTable
        data={orders}
        columns={columns}
        actions={actions}
        pageSize={10}
      />
    </PageLayout>
  );
};

export default Orders; 