
import React, { useState } from 'react';
import { useToast } from '@/hooks/use-toast';
import { addTransaction, getCategories } from '@/services/dataService';
import { TransactionType } from '@/types';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Calendar } from 'lucide-react';

const TransactionForm: React.FC<{ onTransactionAdded?: () => void }> = ({ 
  onTransactionAdded 
}) => {
  const { toast } = useToast();
  const categories = getCategories();
  
  const [transactionType, setTransactionType] = useState<TransactionType>('expense');
  const [amount, setAmount] = useState<string>('');
  const [categoryId, setCategoryId] = useState<string>('');
  const [description, setDescription] = useState<string>('');
  const [date, setDate] = useState<string>(new Date().toISOString().split('T')[0]);
  
  const filteredCategories = categories.filter(
    c => c.type === transactionType || c.type === 'both'
  );

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!amount || !categoryId) {
      toast({
        title: "Error",
        description: "Amount and category are required",
        variant: "destructive"
      });
      return;
    }
    
    const parsedAmount = parseFloat(amount);
    
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      toast({
        title: "Error",
        description: "Please enter a valid amount",
        variant: "destructive"
      });
      return;
    }
    
    addTransaction({
      amount: parsedAmount,
      type: transactionType,
      categoryId,
      description,
      date
    });
    
    // Reset form
    setAmount('');
    setCategoryId('');
    setDescription('');
    setDate(new Date().toISOString().split('T')[0]);
    
    toast({
      title: "Success",
      description: "Transaction added successfully",
    });
    
    // Notify parent component
    if (onTransactionAdded) {
      onTransactionAdded();
    }
  };

  return (
    <Card className="p-4">
      <h2 className="text-xl font-bold mb-4">Add Transaction</h2>
      
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="type">Type</Label>
            <Select
              value={transactionType}
              onValueChange={(value) => setTransactionType(value as TransactionType)}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="income">Income</SelectItem>
                <SelectItem value="expense">Expense</SelectItem>
              </SelectContent>
            </Select>
          </div>
          
          <div className="space-y-2">
            <Label htmlFor="amount">Amount ($)</Label>
            <Input
              id="amount"
              type="number"
              step="0.01"
              min="0.01"
              placeholder="0.00"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              required
            />
          </div>
        </div>
        
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="category">Category</Label>
            <Select
              value={categoryId}
              onValueChange={setCategoryId}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select category" />
              </SelectTrigger>
              <SelectContent>
                {filteredCategories.map((category) => (
                  <SelectItem key={category.id} value={category.id}>
                    {category.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          
          <div className="space-y-2">
            <Label htmlFor="date">Date</Label>
            <div className="relative">
              <Input
                id="date"
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                required
              />
              <Calendar className="absolute right-3 top-2.5 h-4 w-4 text-gray-400" />
            </div>
          </div>
        </div>
        
        <div className="space-y-2">
          <Label htmlFor="description">Description</Label>
          <Textarea
            id="description"
            placeholder="Transaction description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={2}
          />
        </div>
        
        <Button type="submit" className="w-full">
          Add Transaction
        </Button>
      </form>
    </Card>
  );
};

export default TransactionForm;
