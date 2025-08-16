import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { cn } from '../lib/utils';
import {
  LayoutDashboard,
  ShoppingCart,
  Users,
  Settings,
  Menu,
  LogOut,
  HelpCircle,
  Bell,
  Building2,
  ListTree,
  Megaphone,
  Package,
  Images,
  BellRing,
  MessageCircleQuestion,
} from 'lucide-react';
import { Sheet, SheetContent, SheetTrigger } from './ui/sheet';
import { Button } from './ui/button';

interface NavItem {
  title: string;
  href: string;
  icon: React.ElementType;
}

const navItems: NavItem[] = [
  {
    title: 'Dashboard',
    href: '/dashboard',
    icon: LayoutDashboard,
  },
  {
    title: 'Categories',
    href: '/categories',
    icon: ListTree,
  },
  {
    title: 'Products',
    href: '/products',
    icon: Package,
  },
  {
    title: 'Campaigns',
    href: '/campaigns',
    icon: Megaphone,
  },
  {
    title: 'Slider',
    href: '/slider',
    icon: Images,
  },
  {
    title: 'Hikayeler',
    href: '/stories',
    icon: Images,
  },
  {
    title: 'Notifications',
    href: '/notifications',
    icon: BellRing,
  },
  {
    title: 'Branches',
    href: '/branches',
    icon: Building2,
  },
  {
    title: 'FAQ',
    href: '/faq',
    icon: MessageCircleQuestion,
  },
];

interface SidebarNavProps {
  items: NavItem[];
}

function SidebarNav({ items }: SidebarNavProps) {
  const location = useLocation();

  return (
    <nav className="space-y-1">
      {items.map((item) => {
        const Icon = item.icon;
        const isActive = location.pathname === item.href;

        return (
          <Link
            key={item.href}
            to={item.href}
            className={cn(
              'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium hover:bg-accent hover:text-accent-foreground',
              isActive ? 'bg-accent text-accent-foreground' : 'transparent'
            )}
          >
            <Icon className="h-4 w-4" />
            {item.title}
          </Link>
        );
      })}
    </nav>
  );
}

interface LayoutProps {
  children: React.ReactNode;
}

export function Layout({ children }: LayoutProps) {
  const navigate = useNavigate();

  const handleLogout = () => {
    // Implement logout logic here
    navigate('/login');
  };

  return (
    <div className="relative flex min-h-screen">
      {/* Sidebar for desktop */}
      <aside className="hidden w-64 border-r bg-background lg:block">
        <div className="flex h-full flex-col">
          <div className="border-b p-6">
            <Link to="/" className="flex items-center gap-2">
              <span className="text-xl font-bold">Bonavias</span>
            </Link>
          </div>
          <div className="flex-1 overflow-auto p-4">
            <SidebarNav items={navItems} />
          </div>
          <div className="border-t p-4">
            <Button
              variant="outline"
              className="w-full justify-start gap-2"
              onClick={handleLogout}
            >
              <LogOut className="h-4 w-4" />
              Logout
            </Button>
          </div>
        </div>
      </aside>

      {/* Mobile sidebar */}
      <Sheet>
        <SheetTrigger asChild>
          <Button
            variant="outline"
            size="icon"
            className="absolute left-4 top-4 lg:hidden"
          >
            <Menu className="h-4 w-4" />
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="w-64 p-0">
          <div className="flex h-full flex-col">
            <div className="border-b p-6">
              <Link to="/" className="flex items-center gap-2">
                <span className="text-xl font-bold">Bonavias</span>
              </Link>
            </div>
            <div className="flex-1 overflow-auto p-4">
              <SidebarNav items={navItems} />
            </div>
            <div className="border-t p-4">
              <Button
                variant="outline"
                className="w-full justify-start gap-2"
                onClick={handleLogout}
              >
                <LogOut className="h-4 w-4" />
                Logout
              </Button>
            </div>
          </div>
        </SheetContent>
      </Sheet>

      {/* Main content */}
      <div className="flex-1">
        <header className="sticky top-0 z-10 border-b bg-background">
          <div className="flex h-16 items-center gap-4 px-6">
            <div className="flex-1 lg:ml-0" />
            <div className="flex items-center gap-4">
              <Button variant="outline" size="icon">
                <Bell className="h-4 w-4" />
              </Button>
              <Button
                variant="outline"
                size="sm"
                className="gap-2"
                onClick={handleLogout}
              >
                <LogOut className="h-4 w-4" />
                <span className="hidden sm:inline">Logout</span>
              </Button>
            </div>
          </div>
        </header>
        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  );
} 