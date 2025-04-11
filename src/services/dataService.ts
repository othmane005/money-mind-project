
import { Transaction, Category } from "@/types";

// Mock data for categories
const initialCategories: Category[] = [
  {
    id: "cat1",
    name: "Salary",
    icon: "banknote",
    color: "#4CAF50",
    type: "income"
  },
  {
    id: "cat2",
    name: "Investments",
    icon: "trending-up",
    color: "#2196F3",
    type: "income"
  },
  {
    id: "cat3",
    name: "Groceries",
    icon: "shopping-cart",
    color: "#FF9800",
    type: "expense"
  },
  {
    id: "cat4",
    name: "Transport",
    icon: "car",
    color: "#607D8B",
    type: "expense"
  },
  {
    id: "cat5",
    name: "Entertainment",
    icon: "tv",
    color: "#9C27B0",
    type: "expense"
  },
  {
    id: "cat6",
    name: "Dining",
    icon: "utensils",
    color: "#E91E63",
    type: "expense"
  }
];

// Mock data for transactions
const initialTransactions: Transaction[] = [
  {
    id: "t1",
    amount: 3000,
    type: "income",
    categoryId: "cat1",
    description: "Monthly salary",
    date: "2025-04-01"
  },
  {
    id: "t2",
    amount: 500,
    type: "income",
    categoryId: "cat2",
    description: "Dividend payment",
    date: "2025-04-05"
  },
  {
    id: "t3",
    amount: 150,
    type: "expense",
    categoryId: "cat3",
    description: "Weekly groceries",
    date: "2025-04-07"
  },
  {
    id: "t4",
    amount: 45,
    type: "expense",
    categoryId: "cat4",
    description: "Fuel",
    date: "2025-04-08"
  },
  {
    id: "t5",
    amount: 30,
    type: "expense",
    categoryId: "cat5",
    description: "Movie tickets",
    date: "2025-04-09"
  },
  {
    id: "t6",
    amount: 75,
    type: "expense",
    categoryId: "cat6",
    description: "Dinner with friends",
    date: "2025-04-10"
  }
];

// Load data from localStorage if available
const loadData = <T>(key: string, initialData: T): T => {
  try {
    const storedData = localStorage.getItem(key);
    return storedData ? JSON.parse(storedData) : initialData;
  } catch (error) {
    console.error(`Error loading ${key} from localStorage:`, error);
    return initialData;
  }
};

// Save data to localStorage
const saveData = <T>(key: string, data: T): void => {
  try {
    localStorage.setItem(key, JSON.stringify(data));
  } catch (error) {
    console.error(`Error saving ${key} to localStorage:`, error);
  }
};

// Fetch all transactions
export const getTransactions = (): Transaction[] => {
  return loadData<Transaction[]>("transactions", initialTransactions);
};

// Fetch all categories
export const getCategories = (): Category[] => {
  return loadData<Category[]>("categories", initialCategories);
};

// Add a new transaction
export const addTransaction = (transaction: Omit<Transaction, "id">): Transaction => {
  const transactions = getTransactions();
  const newTransaction = {
    ...transaction,
    id: `t${Date.now()}`
  };
  
  const updatedTransactions = [...transactions, newTransaction];
  saveData("transactions", updatedTransactions);
  
  return newTransaction;
};

// Delete a transaction
export const deleteTransaction = (id: string): void => {
  const transactions = getTransactions();
  const updatedTransactions = transactions.filter(t => t.id !== id);
  saveData("transactions", updatedTransactions);
};

// Add a new category
export const addCategory = (category: Omit<Category, "id">): Category => {
  const categories = getCategories();
  const newCategory = {
    ...category,
    id: `cat${Date.now()}`
  };
  
  const updatedCategories = [...categories, newCategory];
  saveData("categories", updatedCategories);
  
  return newCategory;
};

// Update a category
export const updateCategory = (updatedCategory: Category): Category => {
  const categories = getCategories();
  const updatedCategories = categories.map(category => 
    category.id === updatedCategory.id ? updatedCategory : category
  );
  
  saveData("categories", updatedCategories);
  return updatedCategory;
};

// Delete a category
export const deleteCategory = (id: string): void => {
  const categories = getCategories();
  const updatedCategories = categories.filter(c => c.id !== id);
  saveData("categories", updatedCategories);
  
  // Also remove any transactions with this category
  const transactions = getTransactions();
  const updatedTransactions = transactions.filter(t => t.categoryId !== id);
  saveData("transactions", updatedTransactions);
};

// Get transaction summary
export const getTransactionSummary = () => {
  const transactions = getTransactions();
  
  const totalIncome = transactions
    .filter(t => t.type === "income")
    .reduce((total, t) => total + t.amount, 0);
    
  const totalExpense = transactions
    .filter(t => t.type === "expense")
    .reduce((total, t) => total + t.amount, 0);
    
  const balance = totalIncome - totalExpense;
  
  return {
    totalIncome,
    totalExpense,
    balance
  };
};

// Get category summary
export const getCategorySummary = (type: "income" | "expense") => {
  const transactions = getTransactions();
  const categories = getCategories();
  
  // Filter by transaction type
  const filteredTransactions = transactions.filter(t => t.type === type);
  
  // Group by category
  const categorySummary = categories
    .filter(c => c.type === type || c.type === "both")
    .map(category => {
      const categoryTransactions = filteredTransactions.filter(
        t => t.categoryId === category.id
      );
      
      const total = categoryTransactions.reduce(
        (sum, t) => sum + t.amount, 
        0
      );
      
      return {
        category,
        total,
        count: categoryTransactions.length
      };
    })
    .filter(summary => summary.count > 0)
    .sort((a, b) => b.total - a.total);
    
  return categorySummary;
};
