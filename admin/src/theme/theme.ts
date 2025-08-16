import { createTheme } from '@mui/material/styles';
import { alpha } from '@mui/material';

declare module '@mui/material/styles' {
  interface Palette {
    neutral: Palette['primary'];
  }
  interface PaletteOptions {
    neutral?: PaletteOptions['primary'];
  }
}

// Add DataGrid components to the theme type
declare module '@mui/material/styles' {
  interface Components {
    MuiDataGrid?: {
      styleOverrides?: {
        root?: any;
        // Add other DataGrid subcomponents as needed
      };
    };
  }
}

const theme = createTheme({
  palette: {
    primary: {
      main: '#2563eb',
      light: '#60a5fa',
      dark: '#1d4ed8',
      contrastText: '#ffffff',
    },
    secondary: {
      main: '#4f46e5',
      light: '#818cf8',
      dark: '#4338ca',
      contrastText: '#ffffff',
    },
    neutral: {
      main: '#64748b',
      light: '#94a3b8',
      dark: '#475569',
      contrastText: '#ffffff',
    },
    background: {
      default: '#f8fafc',
      paper: '#ffffff',
    },
    error: {
      main: '#ef4444',
      light: '#f87171',
      dark: '#dc2626',
    },
    success: {
      main: '#22c55e',
      light: '#4ade80',
      dark: '#16a34a',
    },
    warning: {
      main: '#f59e0b',
      light: '#fbbf24',
      dark: '#d97706',
    },
    info: {
      main: '#3b82f6',
      light: '#60a5fa',
      dark: '#2563eb',
    },
    text: {
      primary: '#0f172a',
      secondary: '#475569',
      disabled: '#94a3b8',
    },
    divider: '#e2e8f0',
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontWeight: 700,
      fontSize: '2.5rem',
      lineHeight: 1.2,
      letterSpacing: '-0.02em',
    },
    h2: {
      fontWeight: 600,
      fontSize: '2rem',
      lineHeight: 1.3,
      letterSpacing: '-0.01em',
    },
    h3: {
      fontWeight: 600,
      fontSize: '1.75rem',
      lineHeight: 1.3,
    },
    h4: {
      fontWeight: 600,
      fontSize: '1.5rem',
      lineHeight: 1.4,
    },
    h5: {
      fontWeight: 600,
      fontSize: '1.25rem',
      lineHeight: 1.4,
    },
    h6: {
      fontWeight: 600,
      fontSize: '1rem',
      lineHeight: 1.5,
    },
    subtitle1: {
      fontSize: '1rem',
      fontWeight: 500,
      lineHeight: 1.5,
    },
    subtitle2: {
      fontSize: '0.875rem',
      fontWeight: 500,
      lineHeight: 1.57,
    },
    body1: {
      fontSize: '1rem',
      lineHeight: 1.5,
    },
    body2: {
      fontSize: '0.875rem',
      lineHeight: 1.57,
    },
    button: {
      fontWeight: 600,
      textTransform: 'none',
      letterSpacing: '0.02em',
    },
    caption: {
      fontSize: '0.75rem',
      lineHeight: 1.66,
    },
    overline: {
      fontSize: '0.75rem',
      fontWeight: 600,
      textTransform: 'uppercase',
      letterSpacing: '0.08em',
    },
  },
  shape: {
    borderRadius: 12,
  },
  shadows: [
    'none',
    '0px 1px 2px rgba(0, 0, 0, 0.06), 0px 1px 3px rgba(0, 0, 0, 0.1)',
    '0px 2px 4px rgba(0, 0, 0, 0.06), 0px 4px 6px rgba(0, 0, 0, 0.1)',
    '0px 4px 8px rgba(0, 0, 0, 0.06), 0px 8px 16px rgba(0, 0, 0, 0.1)',
    '0px 6px 12px rgba(0, 0, 0, 0.06), 0px 12px 24px rgba(0, 0, 0, 0.1)',
    '0px 8px 16px rgba(0, 0, 0, 0.06), 0px 16px 32px rgba(0, 0, 0, 0.1)',
    '0px 10px 20px rgba(0, 0, 0, 0.06), 0px 20px 40px rgba(0, 0, 0, 0.1)',
    '0px 12px 24px rgba(0, 0, 0, 0.06), 0px 24px 48px rgba(0, 0, 0, 0.1)',
    '0px 14px 28px rgba(0, 0, 0, 0.06), 0px 28px 56px rgba(0, 0, 0, 0.1)',
    '0px 16px 32px rgba(0, 0, 0, 0.06), 0px 32px 64px rgba(0, 0, 0, 0.1)',
    '0px 18px 36px rgba(0, 0, 0, 0.06), 0px 36px 72px rgba(0, 0, 0, 0.1)',
    '0px 20px 40px rgba(0, 0, 0, 0.06), 0px 40px 80px rgba(0, 0, 0, 0.1)',
    '0px 22px 44px rgba(0, 0, 0, 0.06), 0px 44px 88px rgba(0, 0, 0, 0.1)',
    '0px 24px 48px rgba(0, 0, 0, 0.06), 0px 48px 96px rgba(0, 0, 0, 0.1)',
    '0px 26px 52px rgba(0, 0, 0, 0.06), 0px 52px 104px rgba(0, 0, 0, 0.1)',
    '0px 28px 56px rgba(0, 0, 0, 0.06), 0px 56px 112px rgba(0, 0, 0, 0.1)',
    '0px 30px 60px rgba(0, 0, 0, 0.06), 0px 60px 120px rgba(0, 0, 0, 0.1)',
    '0px 32px 64px rgba(0, 0, 0, 0.06), 0px 64px 128px rgba(0, 0, 0, 0.1)',
    '0px 34px 68px rgba(0, 0, 0, 0.06), 0px 68px 136px rgba(0, 0, 0, 0.1)',
    '0px 36px 72px rgba(0, 0, 0, 0.06), 0px 72px 144px rgba(0, 0, 0, 0.1)',
    '0px 38px 76px rgba(0, 0, 0, 0.06), 0px 76px 152px rgba(0, 0, 0, 0.1)',
    '0px 40px 80px rgba(0, 0, 0, 0.06), 0px 80px 160px rgba(0, 0, 0, 0.1)',
    '0px 42px 84px rgba(0, 0, 0, 0.06), 0px 84px 168px rgba(0, 0, 0, 0.1)',
    '0px 44px 88px rgba(0, 0, 0, 0.06), 0px 88px 176px rgba(0, 0, 0, 0.1)',
    '0px 46px 92px rgba(0, 0, 0, 0.06), 0px 92px 184px rgba(0, 0, 0, 0.1)',
  ],
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: '8px',
          textTransform: 'none',
          fontSize: '0.875rem',
          fontWeight: 600,
          boxShadow: 'none',
          '&:hover': {
            boxShadow: 'none',
          },
          transition: 'all 0.2s ease-in-out',
        },
        contained: {
          '&:hover': {
            boxShadow: 'none',
            transform: 'translateY(-1px)',
          },
        },
        outlined: {
          borderWidth: '2px',
          '&:hover': {
            borderWidth: '2px',
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: '16px',
          boxShadow: '0px 2px 4px rgba(0, 0, 0, 0.06), 0px 4px 6px rgba(0, 0, 0, 0.1)',
          transition: 'all 0.2s ease-in-out',
          '&:hover': {
            transform: 'translateY(-2px)',
            boxShadow: '0px 4px 8px rgba(0, 0, 0, 0.06), 0px 8px 16px rgba(0, 0, 0, 0.1)',
          },
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          backgroundImage: 'none',
          transition: 'all 0.2s ease-in-out',
        },
        elevation1: {
          boxShadow: '0px 2px 4px rgba(0, 0, 0, 0.06), 0px 4px 6px rgba(0, 0, 0, 0.1)',
        },
      },
    },
    MuiDrawer: {
      styleOverrides: {
        paper: {
          backgroundImage: 'none',
          borderRight: '1px solid',
          borderColor: '#e2e8f0',
        },
      },
    },
    MuiListItemButton: {
      styleOverrides: {
        root: {
          borderRadius: '8px',
          transition: 'all 0.2s ease-in-out',
          '&.Mui-selected': {
            backgroundColor: alpha('#2563eb', 0.08),
            '&:hover': {
              backgroundColor: alpha('#2563eb', 0.12),
            },
          },
          '&:hover': {
            backgroundColor: alpha('#2563eb', 0.04),
            transform: 'translateX(4px)',
          },
        },
      },
    },
    MuiDataGrid: {
      styleOverrides: {
        root: {
          border: 'none',
          backgroundColor: '#ffffff',
          '& .MuiDataGrid-main': {
            borderRadius: '16px',
            overflow: 'hidden',
          },
          '& .MuiDataGrid-columnHeaders': {
            backgroundColor: '#f8fafc',
            borderBottom: '2px solid #e2e8f0',
            '& .MuiDataGrid-columnHeader': {
              padding: '16px',
              '&:focus, &:focus-within': {
                outline: 'none',
              },
            },
            '& .MuiDataGrid-columnHeaderTitle': {
              fontWeight: 600,
              color: '#1e293b',
            },
          },
          '& .MuiDataGrid-cell': {
            borderColor: '#e2e8f0',
            padding: '16px',
            '&:focus, &:focus-within': {
              outline: 'none',
            },
          },
          '& .MuiDataGrid-row': {
            transition: 'all 0.2s ease-in-out',
            '&:hover': {
              backgroundColor: alpha('#2563eb', 0.04),
              transform: 'translateY(-1px)',
            },
            '&.Mui-selected': {
              backgroundColor: alpha('#2563eb', 0.08),
              '&:hover': {
                backgroundColor: alpha('#2563eb', 0.12),
              },
            },
          },
          '& .MuiDataGrid-footerContainer': {
            borderTop: '2px solid #e2e8f0',
            backgroundColor: '#f8fafc',
          },
          '& .MuiDataGrid-virtualScroller': {
            backgroundColor: '#ffffff',
          },
          '& .MuiDataGrid-toolbarContainer': {
            padding: '16px',
            backgroundColor: '#ffffff',
            '& .MuiButton-root': {
              marginRight: '8px',
              textTransform: 'none',
              fontWeight: 500,
            },
            '& .MuiFormControl-root': {
              minWidth: '200px',
            },
          },
          '& .MuiDataGrid-panel': {
            backgroundColor: '#ffffff',
          },
          '& .MuiDataGrid-columnSeparator': {
            color: '#e2e8f0',
          },
          '& .MuiTablePagination-root': {
            color: '#475569',
          },
          '& .MuiCheckbox-root': {
            color: '#64748b',
            '&.Mui-checked': {
              color: '#2563eb',
            },
          },
          '& .MuiDataGrid-selectedRowCount': {
            color: '#475569',
            fontWeight: 500,
          },
        },
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          borderRadius: '6px',
          fontWeight: 500,
          '&.MuiChip-sizeSmall': {
            height: '24px',
          },
        },
        label: {
          padding: '0 10px',
        },
      },
    },
    MuiTooltip: {
      styleOverrides: {
        tooltip: {
          backgroundColor: '#1e293b',
          color: '#ffffff',
          fontSize: '0.75rem',
          fontWeight: 500,
          padding: '8px 12px',
          borderRadius: '6px',
        },
        arrow: {
          color: '#1e293b',
        },
      },
    },
  },
});

export default theme; 