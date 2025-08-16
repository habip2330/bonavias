import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalBody,
  ModalCloseButton,
  FormControl,
  FormLabel,
  Input,
  VStack,
  Button,
  NumberInput,
  NumberInputField,
  NumberInputStepper,
  NumberIncrementStepper,
  NumberDecrementStepper,
  Switch,
  Box,
  useToast
} from '@chakra-ui/react';
import { useState } from 'react';
import { campaignApi } from '../../services/api';
import type { Campaign } from '../../types';

interface AddCampaignModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess?: () => void;
  campaign: Campaign | null;
}

export function AddCampaignModal({ isOpen, onClose, onSuccess, campaign }: AddCampaignModalProps) {
  const [isLoading, setIsLoading] = useState(false);
  const toast = useToast();

  const [formData, setFormData] = useState<Omit<Campaign, 'id' | 'created_at' | 'updated_at'>>({
    title: campaign?.title ?? '',
    description: campaign?.description ?? '',
    start_date: campaign?.start_date ?? new Date(),
    end_date: campaign?.end_date ?? new Date(),
    discount: campaign?.discount ?? 0,
    image_url: campaign?.image_url ?? '',
    is_active: campaign?.is_active ?? true
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      if (campaign) {
        await campaignApi.update(campaign.id, formData);
        toast({
          title: 'Campaign updated successfully',
          status: 'success',
          duration: 3000,
          isClosable: true,
        });
      } else {
        await campaignApi.create(formData);
        toast({
          title: 'Campaign created successfully',
          status: 'success',
          duration: 3000,
          isClosable: true,
        });
      }
      
      if (onSuccess) {
        onSuccess();
      }
      onClose();
    } catch (error) {
      toast({
        title: 'Error',
        description: error instanceof Error ? error.message : 'An error occurred',
        status: 'error',
        duration: 3000,
        isClosable: true,
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (field: keyof typeof formData) => (
    value: string | number | boolean | Date
  ) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} size="xl">
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>{campaign ? 'Edit Campaign' : 'Add Campaign'}</ModalHeader>
        <ModalCloseButton />
        <ModalBody pb={6}>
          <Box as="form" onSubmit={handleSubmit}>
            <VStack spacing={4}>
              <FormControl isRequired>
                <FormLabel>Title</FormLabel>
                <Input
                  value={formData.title}
                  onChange={e => handleChange('title')(e.target.value)}
                  placeholder="Campaign title"
                />
              </FormControl>

              <FormControl>
                <FormLabel>Description</FormLabel>
                <Input
                  value={formData.description}
                  onChange={e => handleChange('description')(e.target.value)}
                  placeholder="Campaign description"
                />
              </FormControl>

              <FormControl isRequired>
                <FormLabel>Start Date</FormLabel>
                <Input
                  type="datetime-local"
                  value={new Date(formData.start_date).toISOString().slice(0, 16)}
                  onChange={e => handleChange('start_date')(new Date(e.target.value))}
                />
              </FormControl>

              <FormControl isRequired>
                <FormLabel>End Date</FormLabel>
                <Input
                  type="datetime-local"
                  value={new Date(formData.end_date).toISOString().slice(0, 16)}
                  onChange={e => handleChange('end_date')(new Date(e.target.value))}
                />
              </FormControl>

              <FormControl isRequired>
                <FormLabel>Discount (%)</FormLabel>
                <NumberInput
                  value={formData.discount}
                  onChange={(_, value) => handleChange('discount')(value)}
                  min={0}
                  max={100}
                >
                  <NumberInputField />
                  <NumberInputStepper>
                    <NumberIncrementStepper />
                    <NumberDecrementStepper />
                  </NumberInputStepper>
                </NumberInput>
              </FormControl>

              <FormControl>
                <FormLabel>Image URL</FormLabel>
                <Input
                  value={formData.image_url}
                  onChange={e => handleChange('image_url')(e.target.value)}
                  placeholder="Image URL"
                />
              </FormControl>

              <FormControl display="flex" alignItems="center">
                <FormLabel htmlFor="is_active" mb="0">
                  Active
                </FormLabel>
                <Switch
                  id="is_active"
                  isChecked={formData.is_active}
                  onChange={e => handleChange('is_active')(e.target.checked)}
                />
              </FormControl>

              <Button
                type="submit"
                colorScheme="blue"
                isLoading={isLoading}
                width="full"
              >
                {campaign ? 'Update Campaign' : 'Add Campaign'}
              </Button>
            </VStack>
          </Box>
        </ModalBody>
      </ModalContent>
    </Modal>
  );
} 