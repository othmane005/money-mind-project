
import React, { useState } from 'react';
import { getCategories } from '@/services/dataService';
import Header from '@/components/Header';
import CategoryForm from '@/components/CategoryForm';
import CategoriesList from '@/components/CategoriesList';
import { Button } from '@/components/ui/button';

const CategoriesPage: React.FC = () => {
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [showForm, setShowForm] = useState(false);
  
  const categories = getCategories();
  
  const handleDataChange = () => {
    setRefreshTrigger(prev => prev + 1);
  };

  return (
    <div className="min-h-screen pb-16 md:pb-0">
      <Header />
      
      <main className="container mx-auto px-4 py-6 max-w-6xl">
        <div className="flex flex-wrap items-center justify-between mb-6">
          <h1 className="text-3xl font-bold">Categories</h1>
          
          <Button 
            onClick={() => setShowForm(!showForm)}
            className="mt-2 sm:mt-0"
          >
            {showForm ? "Hide Form" : "Add Category"}
          </Button>
        </div>
        
        {showForm && (
          <div className="mb-6">
            <CategoryForm onCategoryAdded={() => {
              handleDataChange();
              setShowForm(false);
            }} />
          </div>
        )}
        
        <CategoriesList 
          categories={categories} 
          onCategoryDeleted={handleDataChange}
        />
      </main>
    </div>
  );
};

export default CategoriesPage;
