
import React from 'react';
import { ArrowDownRight, ArrowUpRight, Info } from 'lucide-react';
import { getTransactionSummary } from '@/services/dataService';
import { Card } from '@/components/ui/card';
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';

const DashboardSummary: React.FC = () => {
  const { totalIncome, totalExpense, balance } = getTransactionSummary();

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      <SummaryCard 
        title="Income" 
        amount={totalIncome} 
        icon={<ArrowUpRight className="h-5 w-5 text-green-500" />}
        className="border-l-4 border-green-500"
        tooltipText="Total income from all sources"
      />
      
      <SummaryCard 
        title="Expenses" 
        amount={totalExpense} 
        icon={<ArrowDownRight className="h-5 w-5 text-money-red" />}
        className="border-l-4 border-money-red"
        tooltipText="Total expenses from all categories"
      />
      
      <SummaryCard 
        title="Balance" 
        amount={balance} 
        icon={null}
        className={`border-l-4 ${balance >= 0 ? 'border-blue-500' : 'border-orange-500'}`}
        tooltipText="Your current balance (Income - Expenses)"
        highlightAmount={true}
      />
    </div>
  );
};

interface SummaryCardProps {
  title: string;
  amount: number;
  icon: React.ReactNode | null;
  className?: string;
  tooltipText?: string;
  highlightAmount?: boolean;
}

const SummaryCard: React.FC<SummaryCardProps> = ({ 
  title, 
  amount, 
  icon, 
  className = "",
  tooltipText,
  highlightAmount = false
}) => {
  return (
    <Card className={`p-4 ${className}`}>
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          <h3 className="text-lg font-medium text-gray-700">{title}</h3>
          
          {tooltipText && (
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Info className="h-4 w-4 ml-1 text-gray-400" />
                </TooltipTrigger>
                <TooltipContent>
                  <p>{tooltipText}</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          )}
        </div>
        
        {icon}
      </div>
      
      <p className={`text-2xl font-bold mt-2 ${highlightAmount ? (amount >= 0 ? 'text-blue-600' : 'text-orange-600') : ''}`}>
        ${amount.toFixed(2)}
      </p>
    </Card>
  );
};

export default DashboardSummary;
