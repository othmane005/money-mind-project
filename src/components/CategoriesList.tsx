
import React, { useState } from 'react';
import { Category } from '@/types';
import { deleteCategory, getTransactions } from '@/services/dataService';
import { useToast } from '@/hooks/use-toast';
import { Button } from '@/components/ui/button';
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import * as Icons from 'lucide-react';
import { Trash2 } from 'lucide-react';

interface CategoriesListProps {
  categories: Category[];
  onCategoryDeleted?: () => void;
}

const CategoriesList: React.FC<CategoriesListProps> = ({ 
  categories,
  onCategoryDeleted
}) => {
  const { toast } = useToast();
  const transactions = getTransactions();
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [categoryToDelete, setCategoryToDelete] = useState<string | null>(null);
  
  const getCategoryUsageCount = (categoryId: string) => {
    return transactions.filter(t => t.categoryId === categoryId).length;
  };
  
  const handleDelete = (id: string) => {
    setCategoryToDelete(id);
    setDeleteConfirmOpen(true);
  };
  
  const confirmDelete = () => {
    if (categoryToDelete) {
      // Check if category is in use
      const usageCount = getCategoryUsageCount(categoryToDelete);
      
      deleteCategory(categoryToDelete);
      setDeleteConfirmOpen(false);
      setCategoryToDelete(null);
      
      toast({
        title: "Success",
        description: usageCount > 0 
          ? `Category and ${usageCount} related transactions deleted successfully` 
          : "Category deleted successfully",
      });
      
      if (onCategoryDeleted) {
        onCategoryDeleted();
      }
    }
  };
  
  // Dynamically render icons from Lucide
  const renderIcon = (iconName: string) => {
    const IconComponent = (Icons as any)[iconName.charAt(0).toUpperCase() + iconName.slice(1)];
    return IconComponent ? <IconComponent className="h-5 w-5" /> : null;
  };

  if (categories.length === 0) {
    return (
      <div className="text-center py-8">
        <p className="text-gray-500">No categories found. Add a category to get started.</p>
      </div>
    );
  }

  return (
    <div>
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Icon</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Usage</TableHead>
              <TableHead></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {categories.map((category) => {
              const usageCount = getCategoryUsageCount(category.id);
              
              return (
                <TableRow key={category.id}>
                  <TableCell>
                    <div 
                      className="w-8 h-8 rounded-full flex items-center justify-center"
                      style={{ backgroundColor: category.color }}
                    >
                      {renderIcon(category.icon)}
                    </div>
                  </TableCell>
                  <TableCell className="font-medium">{category.name}</TableCell>
                  <TableCell>
                    <Badge
                      variant="outline"
                      className={`${
                        category.type === 'income' ? 'border-green-500 text-green-700' : 
                        category.type === 'expense' ? 'border-red-500 text-red-700' : 
                        'border-purple-500 text-purple-700'
                      }`}
                    >
                      {category.type === 'both' ? 'Income & Expense' : 
                       category.type.charAt(0).toUpperCase() + category.type.slice(1)}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    {usageCount > 0 ? (
                      <Badge variant="secondary">{usageCount} transactions</Badge>
                    ) : (
                      <span className="text-gray-500">Unused</span>
                    )}
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDelete(category.id)}
                    >
                      <Trash2 className="h-4 w-4 text-gray-500" />
                    </Button>
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </div>
      
      <Dialog open={deleteConfirmOpen} onOpenChange={setDeleteConfirmOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Confirm Deletion</DialogTitle>
            <DialogDescription>
              {categoryToDelete && getCategoryUsageCount(categoryToDelete) > 0 ? (
                `This category is used in ${getCategoryUsageCount(categoryToDelete)} transactions. Deleting it will also delete those transactions.`
              ) : (
                "Are you sure you want to delete this category?"
              )}
              This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteConfirmOpen(false)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={confirmDelete}>
              Delete
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default CategoriesList;
