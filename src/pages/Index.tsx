
import React, { useState } from 'react';
import { getTransactions } from '@/services/dataService';
import Header from '@/components/Header';
import DashboardSummary from '@/components/DashboardSummary';
import TransactionForm from '@/components/TransactionForm';
import TransactionsList from '@/components/TransactionsList';
import Charts from '@/components/Charts';

const Dashboard: React.FC = () => {
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const transactions = getTransactions();
  
  // Get only the latest 5 transactions
  const recentTransactions = [...transactions]
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
    .slice(0, 5);
  
  const handleDataChange = () => {
    setRefreshTrigger(prev => prev + 1);
  };

  return (
    <div className="min-h-screen pb-16 md:pb-0">
      <Header />
      
      <main className="container mx-auto px-4 py-6 max-w-6xl">
        <h1 className="text-3xl font-bold mb-6">Dashboard</h1>
        
        <DashboardSummary />
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-8">
          <TransactionForm onTransactionAdded={handleDataChange} />
          <Charts />
        </div>
        
        <div className="mt-8">
          <h2 className="text-xl font-bold mb-4">Recent Transactions</h2>
          <TransactionsList 
            transactions={recentTransactions} 
            onTransactionDeleted={handleDataChange}
          />
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
