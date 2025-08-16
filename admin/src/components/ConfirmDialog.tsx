import React, { useState } from 'react';
import { Button } from './ui/button';
import { Modal } from './Modal';

interface ConfirmDialogProps {
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm: () => void;
  onCancel?: () => void;
  isOpen: boolean;
  variant?: 'destructive' | 'default';
}

export const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
  title,
  message,
  confirmText = 'Sil',
  cancelText = 'İptal',
  onConfirm,
  onCancel,
  isOpen,
  variant = 'destructive'
}) => {
  const handleConfirm = () => {
    onConfirm();
  };

  const handleCancel = () => {
    if (onCancel) {
      onCancel();
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={handleCancel} title={title}>
      <div className="space-y-4">
        <p className="text-sm text-gray-600">{message}</p>
        <div className="flex justify-end space-x-2">
          <Button
            variant="outline"
            onClick={handleCancel}
          >
            {cancelText}
          </Button>
          <Button
            variant={variant}
            onClick={handleConfirm}
          >
            {confirmText}
          </Button>
        </div>
      </div>
    </Modal>
  );
};

// Hook for easier usage
export const useConfirmDialog = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [config, setConfig] = useState<{
    title: string;
    message: string;
    onConfirm: () => void;
    confirmText?: string;
    cancelText?: string;
    variant?: 'destructive' | 'default';
  } | null>(null);

  const showConfirm = (options: {
    title: string;
    message: string;
    onConfirm: () => void;
    confirmText?: string;
    cancelText?: string;
    variant?: 'destructive' | 'default';
  }) => {
    setConfig(options);
    setIsOpen(true);
  };

  const hideConfirm = () => {
    setIsOpen(false);
    setConfig(null);
  };

  const ConfirmDialogComponent = config ? (
    <ConfirmDialog
      {...config}
      isOpen={isOpen}
      onCancel={hideConfirm}
      onConfirm={() => {
        config.onConfirm();
        hideConfirm();
      }}
    />
  ) : null;

  return {
    showConfirm,
    hideConfirm,
    ConfirmDialogComponent
  };
}; 