import React, { useState } from 'react';
import {
  Box,
  Button,
  FormControl,
  FormLabel,
  Input,
  Switch,
  VStack,
  useToast
} from '@chakra-ui/react';
import { categoryApi } from '../../services/api';
import type { Category } from '../../types';

export function AddCategoryForm({ onSuccess }: { onSuccess?: () => void }) {
  const [isLoading, setIsLoading] = useState(false);
  const toast = useToast();
  
  const [formData, setFormData] = useState<Omit<Category, 'id' | 'created_at' | 'updated_at'>>({
    name: '',
    description: '',
    image_url: '',
    is_active: true,
    sort_order: 0
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    
    try {
      await categoryApi.create(formData);
      
      setFormData({
        name: '',
        description: '',
        image_url: '',
        is_active: true,
        sort_order: 0
      });
      
      toast({
        title: 'Category created successfully',
        status: 'success',
        duration: 3000,
        isClosable: true,
      });
      
      if (onSuccess) {
        onSuccess();
      }
    } catch (error) {
      toast({
        title: 'Error creating category',
        description: error instanceof Error ? error.message : 'An error occurred',
        status: 'error',
        duration: 3000,
        isClosable: true,
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <Box as="form" onSubmit={handleSubmit}>
      <VStack spacing={4} align="stretch">
        <FormControl isRequired>
          <FormLabel>Name</FormLabel>
          <Input
            name="name"
            value={formData.name}
            onChange={handleChange}
            placeholder="Category name"
          />
        </FormControl>

        <FormControl>
          <FormLabel>Description</FormLabel>
          <Input
            name="description"
            value={formData.description}
            onChange={handleChange}
            placeholder="Category description"
          />
        </FormControl>

        <FormControl>
          <FormLabel>Image URL</FormLabel>
          <Input
            name="image_url"
            value={formData.image_url}
            onChange={handleChange}
            placeholder="Image URL"
          />
        </FormControl>

        <FormControl display="flex" alignItems="center">
          <FormLabel htmlFor="is_active" mb="0">
            Active
          </FormLabel>
          <Switch
            id="is_active"
            name="is_active"
            isChecked={formData.is_active}
            onChange={handleChange}
          />
        </FormControl>

        <Button
          type="submit"
          colorScheme="blue"
          isLoading={isLoading}
          loadingText="Adding..."
        >
          Add Category
        </Button>
      </VStack>
    </Box>
  );
} 