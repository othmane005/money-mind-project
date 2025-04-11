
import React, { useState } from 'react';
import { useToast } from '@/hooks/use-toast';
import { addCategory } from '@/services/dataService';
import { TransactionType } from '@/types';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { 
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover';
import { Palette } from 'lucide-react';

const ICON_OPTIONS = [
  'home', 'shopping-cart', 'car', 'utensils', 'tv', 'gift', 
  'phone', 'book', 'banknote', 'trending-up', 'activity', 'coffee'
];

const COLOR_OPTIONS = [
  '#4CAF50', '#2196F3', '#FF9800', '#E91E63', 
  '#9C27B0', '#607D8B', '#795548', '#00BCD4'
];

interface CategoryFormProps {
  onCategoryAdded?: () => void;
}

const CategoryForm: React.FC<CategoryFormProps> = ({ onCategoryAdded }) => {
  const { toast } = useToast();
  
  const [name, setName] = useState('');
  const [icon, setIcon] = useState(ICON_OPTIONS[0]);
  const [color, setColor] = useState(COLOR_OPTIONS[0]);
  const [type, setType] = useState<TransactionType | 'both'>('expense');
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!name) {
      toast({
        title: "Error",
        description: "Category name is required",
        variant: "destructive"
      });
      return;
    }
    
    addCategory({
      name,
      icon,
      color,
      type
    });
    
    // Reset form
    setName('');
    setIcon(ICON_OPTIONS[0]);
    setColor(COLOR_OPTIONS[0]);
    setType('expense');
    
    toast({
      title: "Success",
      description: "Category added successfully",
    });
    
    // Notify parent component
    if (onCategoryAdded) {
      onCategoryAdded();
    }
  };

  return (
    <Card className="p-4">
      <h2 className="text-xl font-bold mb-4">Add Category</h2>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="name">Category Name</Label>
          <Input
            id="name"
            placeholder="Enter category name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>
        
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="type">Type</Label>
            <Select
              value={type}
              onValueChange={(value) => setType(value as TransactionType | 'both')}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="income">Income</SelectItem>
                <SelectItem value="expense">Expense</SelectItem>
                <SelectItem value="both">Both</SelectItem>
              </SelectContent>
            </Select>
          </div>
          
          <div className="space-y-2">
            <Label htmlFor="icon">Icon</Label>
            <Select
              value={icon}
              onValueChange={setIcon}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select icon" />
              </SelectTrigger>
              <SelectContent>
                {ICON_OPTIONS.map((iconOption) => (
                  <SelectItem key={iconOption} value={iconOption}>
                    {iconOption.charAt(0).toUpperCase() + iconOption.slice(1)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>
        
        <div className="space-y-2">
          <Label>Color</Label>
          <Popover>
            <PopoverTrigger asChild>
              <Button 
                variant="outline" 
                className="w-full justify-between"
              >
                <div className="flex items-center">
                  <div 
                    className="w-4 h-4 rounded-full mr-2" 
                    style={{ backgroundColor: color }}
                  />
                  <span>{color}</span>
                </div>
                <Palette className="h-4 w-4" />
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-64">
              <div className="grid grid-cols-4 gap-2">
                {COLOR_OPTIONS.map((colorOption) => (
                  <div
                    key={colorOption}
                    className="w-full aspect-square rounded-md cursor-pointer border-2 transition-all"
                    style={{ 
                      backgroundColor: colorOption,
                      borderColor: color === colorOption ? 'white' : colorOption
                    }}
                    onClick={() => setColor(colorOption)}
                  />
                ))}
              </div>
            </PopoverContent>
          </Popover>
        </div>
        
        <Button type="submit" className="w-full">
          Add Category
        </Button>
      </form>
    </Card>
  );
};

export default CategoryForm;
