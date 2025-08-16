import React from 'react';
import { PageLayout } from '../components/PageLayout';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import {
  Users,
  DollarSign,
  ShoppingBag,
  ArrowUpRight,
  ArrowDownRight,
  TrendingUp,
} from 'lucide-react';
import { cn } from '../lib/utils';

interface StatCardProps {
  title: string;
  value: string;
  description: string;
  icon: React.ElementType;
  trend: {
    value: string;
    isPositive: boolean;
  };
}

const StatCard = ({ title, value, description, icon: Icon, trend }: StatCardProps) => (
  <Card>
    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
      <CardTitle className="text-sm font-medium">{title}</CardTitle>
      <Icon className="h-4 w-4 text-muted-foreground" />
    </CardHeader>
    <CardContent>
      <div className="text-2xl font-bold">{value}</div>
      <div className="flex items-center space-x-2">
        <span
          className={cn(
            'flex items-center text-xs',
            trend.isPositive ? 'text-green-600' : 'text-red-600'
          )}
        >
          {trend.isPositive ? (
            <ArrowUpRight className="h-3 w-3" />
          ) : (
            <ArrowDownRight className="h-3 w-3" />
          )}
          {trend.value}
        </span>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
    </CardContent>
  </Card>
);

const RecentOrdersCard = () => (
  <Card className="col-span-2">
    <CardHeader>
      <CardTitle>Recent Orders</CardTitle>
    </CardHeader>
    <CardContent>
      <div className="space-y-8">
        {[
          {
            name: 'John Doe',
            items: '2x Margherita Pizza',
            value: '$25.98',
            time: '2 minutes ago',
          },
          {
            name: 'Jane Smith',
            items: '1x Pepperoni Pizza, 1x Coke',
            value: '$18.99',
            time: '5 minutes ago',
          },
          {
            name: 'Bob Johnson',
            items: '3x Garlic Bread',
            value: '$12.99',
            time: '10 minutes ago',
          },
        ].map((order, index) => (
          <div key={index} className="flex items-center">
            <div className="space-y-1">
              <p className="text-sm font-medium leading-none">{order.name}</p>
              <p className="text-sm text-muted-foreground">{order.items}</p>
            </div>
            <div className="ml-auto text-right">
              <p className="text-sm font-medium">{order.value}</p>
              <p className="text-xs text-muted-foreground">{order.time}</p>
            </div>
          </div>
        ))}
      </div>
    </CardContent>
  </Card>
);

const PopularItemsCard = () => (
  <Card className="col-span-2">
    <CardHeader>
      <CardTitle>Popular Items</CardTitle>
    </CardHeader>
    <CardContent>
      <div className="space-y-8">
        {[
          {
            name: 'Margherita Pizza',
            orders: '145 orders',
            trend: '+12.3%',
            isPositive: true,
          },
          {
            name: 'Pepperoni Pizza',
            orders: '132 orders',
            trend: '+8.1%',
            isPositive: true,
          },
          {
            name: 'Garlic Bread',
            orders: '98 orders',
            trend: '-2.5%',
            isPositive: false,
          },
        ].map((item, index) => (
          <div key={index} className="flex items-center">
            <div className="space-y-1">
              <p className="text-sm font-medium leading-none">{item.name}</p>
              <p className="text-sm text-muted-foreground">{item.orders}</p>
            </div>
            <div className="ml-auto">
              <span
                className={cn(
                  'flex items-center text-xs',
                  item.isPositive ? 'text-green-600' : 'text-red-600'
                )}
              >
                {item.isPositive ? (
                  <ArrowUpRight className="h-3 w-3" />
                ) : (
                  <ArrowDownRight className="h-3 w-3" />
                )}
                {item.trend}
              </span>
            </div>
          </div>
        ))}
      </div>
    </CardContent>
  </Card>
);

const Dashboard: React.FC = () => {
  return (
    <PageLayout
      title="Dashboard"
      subtitle="Overview of your restaurant's performance"
    >
      <div className="space-y-8">
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <StatCard
            title="Total Revenue"
            value="$45,231.89"
            description="compared to last month"
            icon={DollarSign}
            trend={{ value: '+20.1%', isPositive: true }}
          />
          <StatCard
            title="Total Orders"
            value="2,345"
            description="compared to last month"
            icon={ShoppingBag}
            trend={{ value: '+12.2%', isPositive: true }}
          />
          <StatCard
            title="Active Users"
            value="1,234"
            description="compared to last month"
            icon={Users}
            trend={{ value: '+8.4%', isPositive: true }}
          />
          <StatCard
            title="Sales Growth"
            value="15.2%"
            description="compared to last month"
            icon={TrendingUp}
            trend={{ value: '+4.3%', isPositive: true }}
          />
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <RecentOrdersCard />
          <PopularItemsCard />
        </div>
      </div>
    </PageLayout>
  );
};

export default Dashboard; 