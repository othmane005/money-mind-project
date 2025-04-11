
import React, { useState } from 'react';
import { getTransactions } from '@/services/dataService';
import Header from '@/components/Header';
import TransactionForm from '@/components/TransactionForm';
import TransactionsList from '@/components/TransactionsList';
import { Button } from '@/components/ui/button';
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { CalendarIcon, FilterIcon, SlidersHorizontal } from 'lucide-react';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';

const TransactionsPage: React.FC = () => {
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [filterType, setFilterType] = useState<string>("all");
  const [dateFrom, setDateFrom] = useState<Date | undefined>(undefined);
  const [dateTo, setDateTo] = useState<Date | undefined>(undefined);
  const [showForm, setShowForm] = useState(false);
  
  const allTransactions = getTransactions();
  
  // Filter transactions
  const filteredTransactions = allTransactions.filter(transaction => {
    // Filter by type
    if (filterType !== "all" && transaction.type !== filterType) {
      return false;
    }
    
    // Filter by date range
    if (dateFrom && new Date(transaction.date) < dateFrom) {
      return false;
    }
    
    if (dateTo) {
      // Add one day to include the end date
      const adjustedDateTo = new Date(dateTo);
      adjustedDateTo.setDate(adjustedDateTo.getDate() + 1);
      
      if (new Date(transaction.date) > adjustedDateTo) {
        return false;
      }
    }
    
    return true;
  }).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  
  const handleDataChange = () => {
    setRefreshTrigger(prev => prev + 1);
  };
  
  const resetFilters = () => {
    setFilterType("all");
    setDateFrom(undefined);
    setDateTo(undefined);
  };

  return (
    <div className="min-h-screen pb-16 md:pb-0">
      <Header />
      
      <main className="container mx-auto px-4 py-6 max-w-6xl">
        <div className="flex flex-wrap items-center justify-between mb-6">
          <h1 className="text-3xl font-bold">Transactions</h1>
          
          <Button 
            onClick={() => setShowForm(!showForm)}
            className="mt-2 sm:mt-0"
          >
            {showForm ? "Hide Form" : "Add Transaction"}
          </Button>
        </div>
        
        {showForm && (
          <div className="mb-6">
            <TransactionForm onTransactionAdded={() => {
              handleDataChange();
              setShowForm(false);
            }} />
          </div>
        )}
        
        <div className="flex flex-wrap items-center gap-4 mb-6">
          <div className="flex items-center">
            <SlidersHorizontal className="mr-2 h-4 w-4" />
            <span className="text-sm font-medium">Filters:</span>
          </div>
          
          <Select
            value={filterType}
            onValueChange={setFilterType}
          >
            <SelectTrigger className="w-[140px]">
              <SelectValue placeholder="Transaction type" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Types</SelectItem>
              <SelectItem value="income">Income</SelectItem>
              <SelectItem value="expense">Expense</SelectItem>
            </SelectContent>
          </Select>
          
          <div className="flex items-center gap-2">
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  className={cn(
                    "w-[140px] justify-start text-left font-normal",
                    !dateFrom && "text-muted-foreground"
                  )}
                >
                  <CalendarIcon className="mr-2 h-4 w-4" />
                  {dateFrom ? format(dateFrom, "PPP") : "Date from"}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0">
                <Calendar
                  mode="single"
                  selected={dateFrom}
                  onSelect={setDateFrom}
                  initialFocus
                />
              </PopoverContent>
            </Popover>
            
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  className={cn(
                    "w-[140px] justify-start text-left font-normal",
                    !dateTo && "text-muted-foreground"
                  )}
                >
                  <CalendarIcon className="mr-2 h-4 w-4" />
                  {dateTo ? format(dateTo, "PPP") : "Date to"}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0">
                <Calendar
                  mode="single"
                  selected={dateTo}
                  onSelect={setDateTo}
                  initialFocus
                />
              </PopoverContent>
            </Popover>
          </div>
          
          {(filterType !== "all" || dateFrom || dateTo) && (
            <Button variant="ghost" onClick={resetFilters} size="sm">
              Reset filters
            </Button>
          )}
        </div>
        
        <TransactionsList 
          transactions={filteredTransactions} 
          onTransactionDeleted={handleDataChange}
        />
      </main>
    </div>
  );
};

export default TransactionsPage;
