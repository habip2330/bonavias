import React from 'react';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from './table';
import { Button } from './button';
import { Card } from './card';
import {
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
} from 'lucide-react';

export interface Column<T> {
  field: keyof T;
  header: string;
  render?: (value: any, row: T) => React.ReactNode;
}

export interface Action<T> {
  label: string;
  onClick: (item: T) => void;
  icon?: React.ReactNode;
  color?: 'default' | 'destructive' | 'outline';
  hide?: (item: T) => boolean;
  disabled?: (item: T) => boolean;
  tooltip?: string;
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  actions?: Action<T>[];
  pageSize?: number;
  className?: string;
}

export function DataTable<T extends { id: string | number }>({
  data,
  columns,
  actions,
  pageSize = 10,
  className,
}: DataTableProps<T>) {
  const [page, setPage] = React.useState(1);
  const [rowsPerPage, setRowsPerPage] = React.useState(pageSize);

  const totalPages = Math.ceil(data.length / rowsPerPage);
  const startIndex = (page - 1) * rowsPerPage;
  const endIndex = startIndex + rowsPerPage;
  const currentData = data.slice(startIndex, endIndex);

  return (
    <Card className={className}>
      <div className="relative w-full overflow-auto">
        <Table>
          <TableHeader>
            <TableRow>
              {columns.map((column) => (
                <TableHead key={String(column.field)}>{column.header}</TableHead>
              ))}
              {actions && actions.length > 0 && (
                <TableHead className="text-right">Actions</TableHead>
              )}
            </TableRow>
          </TableHeader>
          <TableBody>
            {currentData.map((row, rowIndex) => (
              <TableRow key={row.id}>
                {columns.map((column) => (
                  <TableCell key={String(column.field)}>
                    {column.render
                      ? column.render(row[column.field], row)
                      : String(row[column.field])}
                  </TableCell>
                ))}
                {actions && actions.length > 0 && (
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      {actions.map(
                        (action, actionIndex) =>
                          (!action.hide || !action.hide(row)) && (
                            <Button
                              key={actionIndex}
                              variant={action.color || 'default'}
                              size="sm"
                              onClick={() => action.onClick(row)}
                              disabled={action.disabled && action.disabled(row)}
                              title={action.tooltip}
                            >
                              {action.icon}
                              <span className="sr-only">{action.label}</span>
                            </Button>
                          )
                      )}
                    </div>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
      {totalPages > 1 && (
        <div className="flex items-center justify-between px-4 py-4 border-t">
          <div className="text-sm text-muted-foreground">
            Showing {startIndex + 1} to {Math.min(endIndex, data.length)} of{' '}
            {data.length} entries
          </div>
          <div className="flex items-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(1)}
              disabled={page === 1}
            >
              <ChevronsLeft className="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(page - 1)}
              disabled={page === 1}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <div className="text-sm font-medium">
              Page {page} of {totalPages}
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(page + 1)}
              disabled={page === totalPages}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage(totalPages)}
              disabled={page === totalPages}
            >
              <ChevronsRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      )}
    </Card>
  );
} 