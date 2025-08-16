import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import { Card, CardContent, CardHeader } from './ui/card';
import { Button } from './ui/button';
import { cn } from '../lib/utils';

interface PageLayoutProps {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  actions?: React.ReactNode;
  breadcrumbs?: Array<{
    label: string;
    href?: string;
  }>;
}

export const PageLayout: React.FC<PageLayoutProps> = ({
  title,
  subtitle,
  children,
  actions,
  breadcrumbs,
}) => {
  return (
    <div className="p-6">
      <Card>
        <CardHeader className="border-b">
          {breadcrumbs && breadcrumbs.length > 0 && (
            <nav className="mb-4">
              <ol className="flex items-center space-x-2">
                {breadcrumbs.map((crumb, index) => (
                  <li key={index} className="flex items-center">
                    {index > 0 && (
                      <span className="mx-2 text-muted-foreground">/</span>
                    )}
                    {crumb.href ? (
                      <RouterLink
                        to={crumb.href}
                        className={cn(
                          'text-sm transition-colors hover:text-primary',
                          index === breadcrumbs.length - 1
                            ? 'text-foreground font-medium'
                            : 'text-muted-foreground'
                        )}
                      >
                        {crumb.label}
                      </RouterLink>
                    ) : (
                      <span className="text-sm text-foreground font-medium">
                        {crumb.label}
                      </span>
                    )}
                  </li>
                ))}
              </ol>
            </nav>
          )}
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
              {subtitle && (
                <p className="text-sm text-muted-foreground mt-1 max-w-2xl">
                  {subtitle}
                </p>
              )}
            </div>
            {actions && (
              <div className="flex items-center space-x-2">
                {actions}
              </div>
            )}
          </div>
        </CardHeader>
        <CardContent className="p-6">{children}</CardContent>
      </Card>
    </div>
  );
};

export { Button as ActionButton }; 