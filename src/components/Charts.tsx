
import React from 'react';
import { 
  PieChart, 
  Pie, 
  Cell, 
  ResponsiveContainer, 
  Legend, 
  Tooltip,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid
} from 'recharts';
import { getCategorySummary, getCategories } from '@/services/dataService';
import { Card } from '@/components/ui/card';
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs';

const categoryMap = new Map(getCategories().map(c => [c.id, c]));

const ExpensePieChart: React.FC = () => {
  const expenseSummary = getCategorySummary('expense');
  
  const data = expenseSummary.map(item => ({
    name: categoryMap.get(item.category.id)?.name || 'Unknown',
    value: item.total,
    color: item.category.color
  }));
  
  if (data.length === 0) {
    return (
      <div className="h-[300px] flex items-center justify-center">
        <p className="text-gray-500">No expense data to display</p>
      </div>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          labelLine={false}
          label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
          outerRadius={80}
          fill="#8884d8"
          dataKey="value"
        >
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={entry.color} />
          ))}
        </Pie>
        <Tooltip 
          formatter={(value: number) => `$${value.toFixed(2)}`}
        />
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
};

const IncomePieChart: React.FC = () => {
  const incomeSummary = getCategorySummary('income');
  
  const data = incomeSummary.map(item => ({
    name: categoryMap.get(item.category.id)?.name || 'Unknown',
    value: item.total,
    color: item.category.color
  }));
  
  if (data.length === 0) {
    return (
      <div className="h-[300px] flex items-center justify-center">
        <p className="text-gray-500">No income data to display</p>
      </div>
    );
  }

  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie
          data={data}
          cx="50%"
          cy="50%"
          labelLine={false}
          label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
          outerRadius={80}
          fill="#8884d8"
          dataKey="value"
        >
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={entry.color} />
          ))}
        </Pie>
        <Tooltip 
          formatter={(value: number) => `$${value.toFixed(2)}`}
        />
        <Legend />
      </PieChart>
    </ResponsiveContainer>
  );
};

const CategoryBarChart: React.FC = () => {
  const expenseSummary = getCategorySummary('expense');
  const incomeSummary = getCategorySummary('income');
  
  const expenseData = expenseSummary.map(item => ({
    name: categoryMap.get(item.category.id)?.name || 'Unknown',
    value: item.total,
    color: item.category.color
  }));
  
  const incomeData = incomeSummary.map(item => ({
    name: categoryMap.get(item.category.id)?.name || 'Unknown',
    value: item.total,
    color: item.category.color
  }));
  
  if (expenseData.length === 0 && incomeData.length === 0) {
    return (
      <div className="h-[300px] flex items-center justify-center">
        <p className="text-gray-500">No data to display</p>
      </div>
    );
  }
  
  // Combine all category names
  const allCategories = [...new Set([
    ...expenseData.map(d => d.name),
    ...incomeData.map(d => d.name)
  ])];
  
  // Create data for the chart
  const data = allCategories.map(category => {
    const expense = expenseData.find(d => d.name === category)?.value || 0;
    const income = incomeData.find(d => d.name === category)?.value || 0;
    
    return {
      name: category,
      expense,
      income
    };
  });

  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart
        data={data}
        margin={{
          top: 20,
          right: 30,
          left: 20,
          bottom: 5,
        }}
      >
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip formatter={(value: number) => `$${value.toFixed(2)}`} />
        <Legend />
        <Bar dataKey="income" fill="#4CAF50" name="Income" />
        <Bar dataKey="expense" fill="#F44336" name="Expense" />
      </BarChart>
    </ResponsiveContainer>
  );
};

const Charts: React.FC = () => {
  return (
    <Card className="p-4">
      <h2 className="text-xl font-bold mb-4">Financial Overview</h2>
      
      <Tabs defaultValue="expense">
        <TabsList className="grid w-full grid-cols-3 mb-4">
          <TabsTrigger value="expense">Expenses</TabsTrigger>
          <TabsTrigger value="income">Income</TabsTrigger>
          <TabsTrigger value="comparison">Comparison</TabsTrigger>
        </TabsList>
        
        <TabsContent value="expense">
          <ExpensePieChart />
        </TabsContent>
        
        <TabsContent value="income">
          <IncomePieChart />
        </TabsContent>
        
        <TabsContent value="comparison">
          <CategoryBarChart />
        </TabsContent>
      </Tabs>
    </Card>
  );
};

export default Charts;
