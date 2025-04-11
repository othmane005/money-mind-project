
import React from 'react';
import { Link } from 'react-router-dom';
import { cn } from '@/lib/utils';
import { 
  CreditCard, 
  Home, 
  Layers, 
  PieChart 
} from 'lucide-react';

const Header: React.FC = () => {
  return (
    <header className="sticky top-0 z-10 w-full bg-white border-b shadow-sm">
      <div className="container mx-auto px-4">
        <div className="flex h-16 items-center justify-between">
          <div className="flex items-center gap-2">
            <CreditCard className="h-6 w-6 text-money-primary" />
            <span className="text-xl font-bold bg-gradient-to-r from-money-primary to-money-secondary bg-clip-text text-transparent">
              MoneyMind
            </span>
          </div>
          
          <nav className="hidden md:flex items-center space-x-4">
            <NavLink to="/" icon={<Home size={18} />} label="Dashboard" />
            <NavLink to="/transactions" icon={<Layers size={18} />} label="Transactions" />
            <NavLink to="/categories" icon={<PieChart size={18} />} label="Categories" />
          </nav>
          
          <div className="md:hidden">
            <MobileNav />
          </div>
        </div>
      </div>
    </header>
  );
};

interface NavLinkProps {
  to: string;
  icon: React.ReactNode;
  label: string;
}

const NavLink: React.FC<NavLinkProps> = ({ to, icon, label }) => {
  // Check if this link is for the current page
  const isActive = window.location.pathname === to;
  
  return (
    <Link
      to={to}
      className={cn(
        "flex items-center gap-1.5 px-3 py-2 rounded-md text-sm font-medium transition-colors",
        isActive 
          ? "bg-money-gray text-money-primary" 
          : "text-gray-600 hover:bg-gray-100"
      )}
    >
      {icon}
      {label}
    </Link>
  );
};

const MobileNav: React.FC = () => {
  return (
    <div className="fixed bottom-0 left-0 z-50 w-full border-t bg-white">
      <div className="flex justify-around py-2">
        <MobileNavLink to="/" icon={<Home size={20} />} label="Dashboard" />
        <MobileNavLink to="/transactions" icon={<Layers size={20} />} label="Transactions" />
        <MobileNavLink to="/categories" icon={<PieChart size={20} />} label="Categories" />
      </div>
    </div>
  );
};

const MobileNavLink: React.FC<NavLinkProps> = ({ to, icon, label }) => {
  // Check if this link is for the current page
  const isActive = window.location.pathname === to;
  
  return (
    <Link
      to={to}
      className={cn(
        "flex flex-col items-center p-2 rounded-md text-xs font-medium",
        isActive 
          ? "text-money-primary" 
          : "text-gray-600"
      )}
    >
      {icon}
      <span className="mt-1">{label}</span>
    </Link>
  );
};

export default Header;
