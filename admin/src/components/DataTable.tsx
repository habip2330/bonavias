import React from 'react';
import {
  Box,
  IconButton,
  Typography,
  Paper,
  Tooltip,
  useTheme,
} from '@mui/material';
import {
  DataGrid,
  GridColDef,
  GridRenderCellParams,
  GridToolbar,
  GridAlignment,
} from '@mui/x-data-grid';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material';

export interface Column<T> {
  field: keyof T;
  headerName: string;
  width?: number;
  flex?: number;
  renderCell?: (params: GridRenderCellParams) => React.ReactNode;
  align?: GridAlignment;
  minWidth?: number;
  maxWidth?: number;
  valueGetter?: (params: any) => any;
  sortable?: boolean;
  filterable?: boolean;
  hideable?: boolean;
}

export interface Action<T> {
  label: string;
  onClick: (item: T) => void;
  icon: React.ReactNode | string;
  color?: 'primary' | 'secondary' | 'error' | 'info' | 'success' | 'warning';
  disabled?: (item: T) => boolean;
  hide?: (item: T) => boolean;
  tooltip?: string;
}

export interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  onEdit?: (item: T) => void;
  onDelete?: (item: T) => void;
  actions?: Action<T>[];
  isLoading?: boolean;
  title?: string;
  subtitle?: string;
  hideToolbar?: boolean;
  hideFooter?: boolean;
  autoHeight?: boolean;
  minHeight?: number;
  maxHeight?: number;
}

export function DataTable<T extends { id: string | number }>({
  data,
  columns,
  onEdit,
  onDelete,
  actions = [],
  isLoading = false,
  title,
  subtitle,
  hideToolbar = false,
  hideFooter = false,
  autoHeight = false,
  minHeight = 400,
  maxHeight = 800,
}: DataTableProps<T>) {
  const theme = useTheme();

  const finalColumns: GridColDef[] = [
    ...columns.map((col) => ({
      field: col.field as string,
      headerName: col.headerName,
      width: col.width,
      flex: col.flex,
      renderCell: col.renderCell,
      align: col.align,
      minWidth: col.minWidth,
      maxWidth: col.maxWidth,
      valueGetter: col.valueGetter,
      sortable: col.sortable ?? true,
      filterable: col.filterable ?? true,
      hideable: col.hideable ?? true,
    })),
    ...(onEdit || onDelete || actions.length > 0
      ? [
          {
            field: 'actions',
            headerName: 'Actions',
            width: 120 + (actions.length * 40),
            sortable: false,
            filterable: false,
            hideable: false,
            align: 'center' as GridAlignment,
            renderCell: (params: GridRenderCellParams) => (
              <Box sx={{ 
                display: 'flex', 
                gap: 1,
                justifyContent: 'center',
                width: '100%'
              }}>
                {onEdit && (
                  <Tooltip title="Edit" arrow>
                    <IconButton
                      size="small"
                      onClick={(e) => {
                        e.stopPropagation();
                        onEdit(params.row);
                      }}
                      sx={{
                        color: theme.palette.primary.main,
                        '&:hover': {
                          backgroundColor: theme.palette.primary.light + '20',
                        },
                      }}
                    >
                      <EditIcon fontSize="small" />
                    </IconButton>
                  </Tooltip>
                )}
                {onDelete && (
                  <Tooltip title="Delete" arrow>
                    <IconButton
                      size="small"
                      onClick={(e) => {
                        e.stopPropagation();
                        onDelete(params.row);
                      }}
                      sx={{
                        color: theme.palette.error.main,
                        '&:hover': {
                          backgroundColor: theme.palette.error.light + '20',
                        },
                      }}
                    >
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </Tooltip>
                )}
                {actions.map((action, index) => {
                  if (action.hide?.(params.row)) return null;
                  const disabled = action.disabled?.(params.row);
                  
                  return (
                    <Tooltip key={index} title={action.tooltip || action.label} arrow>
                      <span>
                        <IconButton
                          size="small"
                          onClick={(e) => {
                            e.stopPropagation();
                            action.onClick(params.row);
                          }}
                          disabled={disabled}
                          sx={{
                            color: theme.palette[action.color || 'primary'].main,
                            '&:hover': {
                              backgroundColor: theme.palette[action.color || 'primary'].light + '20',
                            },
                          }}
                        >
                          {typeof action.icon === 'string' ? (
                            <span className="material-icons">{action.icon}</span>
                          ) : (
                            action.icon
                          )}
                        </IconButton>
                      </span>
                    </Tooltip>
                  );
                })}
              </Box>
            ),
          },
        ]
      : []),
  ];

  return (
    <Paper
      elevation={0}
      sx={{
        width: '100%',
        backgroundColor: 'background.paper',
        borderRadius: 3,
        border: '1px solid',
        borderColor: 'divider',
        overflow: 'hidden',
      }}
    >
      {(title || subtitle) && (
        <Box 
          sx={{ 
            p: 3, 
            borderBottom: '1px solid', 
            borderColor: 'divider',
            background: theme.palette.background.default
          }}
        >
          {title && (
            <Typography variant="h5" component="h2" gutterBottom={!!subtitle}>
              {title}
            </Typography>
          )}
          {subtitle && (
            <Typography variant="body2" color="text.secondary">
              {subtitle}
            </Typography>
          )}
        </Box>
      )}
      <DataGrid
        rows={data}
        columns={finalColumns}
        loading={isLoading}
        disableRowSelectionOnClick
        slots={{
          toolbar: hideToolbar ? undefined : GridToolbar,
        }}
        slotProps={{
          toolbar: {
            showQuickFilter: true,
            quickFilterProps: { debounceMs: 500 },
          },
        }}
        sx={{
          border: 'none',
          '& .MuiDataGrid-main': {
            minHeight: autoHeight ? 'auto' : minHeight,
            maxHeight: autoHeight ? 'auto' : maxHeight,
          },
          '& .MuiDataGrid-columnHeaders': {
            backgroundColor: theme.palette.background.default,
            borderBottom: `1px solid ${theme.palette.divider}`,
          },
          '& .MuiDataGrid-columnHeader': {
            '&:focus, &:focus-within': {
              outline: 'none',
            },
          },
          '& .MuiDataGrid-cell': {
            borderColor: theme.palette.divider,
            '&:focus, &:focus-within': {
              outline: 'none',
            },
          },
          '& .MuiDataGrid-row': {
            '&:hover': {
              backgroundColor: theme.palette.action.hover,
            },
            '&.Mui-selected': {
              backgroundColor: theme.palette.primary.light + '20',
              '&:hover': {
                backgroundColor: theme.palette.primary.light + '30',
              },
            },
          },
          '& .MuiDataGrid-footerContainer': {
            borderTop: `1px solid ${theme.palette.divider}`,
            backgroundColor: theme.palette.background.default,
          },
          '& .MuiDataGrid-toolbarContainer': {
            padding: 2,
            backgroundColor: theme.palette.background.default,
            borderBottom: `1px solid ${theme.palette.divider}`,
          },
        }}
        initialState={{
          pagination: {
            paginationModel: {
              pageSize: 10,
            },
          },
        }}
        pageSizeOptions={[5, 10, 25, 50, 100]}
        hideFooter={hideFooter}
      />
    </Paper>
  );
} 