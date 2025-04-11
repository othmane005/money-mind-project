
import React, { useState } from 'react';
import { format } from 'date-fns';
import { Trash2 } from 'lucide-react';
import { Transaction, Category } from '@/types';
import { deleteTransaction, getCategories } from '@/services/dataService';
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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';

interface TransactionsListProps {
  transactions: Transaction[];
  onTransactionDeleted?: () => void;
}

const TransactionsList: React.FC<TransactionsListProps> = ({ 
  transactions,
  onTransactionDeleted
}) => {
  const { toast } = useToast();
  const categories = getCategories();
  const [searchTerm, setSearchTerm] = useState('');
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [transactionToDelete, setTransactionToDelete] = useState<string | null>(null);
  
  const categoryMap = new Map<string, Category>();
  categories.forEach(category => {
    categoryMap.set(category.id, category);
  });
  
  const filteredTransactions = transactions.filter(transaction => {
    const category = categoryMap.get(transaction.categoryId);
    const searchLower = searchTerm.toLowerCase();
    
    return !searchTerm || 
      transaction.description.toLowerCase().includes(searchLower) ||
      (category && category.name.toLowerCase().includes(searchLower));
  });
  
  const handleDelete = (id: string) => {
    setTransactionToDelete(id);
    setDeleteConfirmOpen(true);
  };
  
  const confirmDelete = () => {
    if (transactionToDelete) {
      deleteTransaction(transactionToDelete);
      setDeleteConfirmOpen(false);
      setTransactionToDelete(null);
      
      toast({
        title: "Success",
        description: "Transaction deleted successfully",
      });
      
      if (onTransactionDeleted) {
        onTransactionDeleted();
      }
    }
  };

  if (transactions.length === 0) {
    return (
      <div className="text-center py-8">
        <p className="text-gray-500">No transactions found. Add a transaction to get started.</p>
      </div>
    );
  }

  return (
    <div>
      <div className="mb-4">
        <Input
          placeholder="Search transactions..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="max-w-sm"
        />
      </div>
      
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Date</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Category</TableHead>
              <TableHead>Description</TableHead>
              <TableHead className="text-right">Amount</TableHead>
              <TableHead></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredTransactions.map((transaction) => {
              const category = categoryMap.get(transaction.categoryId);
              
              return (
                <TableRow key={transaction.id}>
                  <TableCell>
                    {format(new Date(transaction.date), 'MMM dd, yyyy')}
                  </TableCell>
                  <TableCell>
                    <span className={transaction.type === 'income' ? 'income-badge' : 'expense-badge'}>
                      {transaction.type === 'income' ? 'Income' : 'Expense'}
                    </span>
                  </TableCell>
                  <TableCell>
                    {category ? category.name : 'Uncategorized'}
                  </TableCell>
                  <TableCell>
                    {transaction.description || '-'}
                  </TableCell>
                  <TableCell className={`text-right font-medium ${
                    transaction.type === 'income' ? 'text-green-600' : 'text-red-600'
                  }`}>
                    {transaction.type === 'income' ? '+' : '-'}${transaction.amount.toFixed(2)}
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDelete(transaction.id)}
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
              Are you sure you want to delete this transaction? This action cannot be undone.
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

export default TransactionsList;
