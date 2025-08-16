import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalBody,
  ModalCloseButton,
} from '@chakra-ui/react';
import { AddCategoryForm } from './AddCategoryForm';

interface AddCategoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess?: () => void;
}

export function AddCategoryModal({ isOpen, onClose, onSuccess }: AddCategoryModalProps) {
  const handleSuccess = () => {
    if (onSuccess) {
      onSuccess();
    }
    onClose();
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} size="xl">
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>Add New Category</ModalHeader>
        <ModalCloseButton />
        <ModalBody pb={6}>
          <AddCategoryForm onSuccess={handleSuccess} />
        </ModalBody>
      </ModalContent>
    </Modal>
  );
} 