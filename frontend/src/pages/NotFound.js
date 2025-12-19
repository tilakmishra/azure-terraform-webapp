import React from 'react';
import { Link } from 'react-router-dom';
import { Home, ArrowLeft } from 'lucide-react';

const NotFound = () => {
  return (
    <div className="min-h-[60vh] flex items-center justify-center">
      <div className="text-center">
        <div className="mb-8">
          <h1 className="text-9xl font-bold text-gray-300">404</h1>
          <h2 className="text-3xl font-semibold text-gray-900 mb-2">
            Page Not Found
          </h2>
          <p className="text-gray-600 mb-8 max-w-md mx-auto">
            Sorry, the page you are looking for doesn't exist or has been moved.
          </p>
        </div>
        
        <div className="space-x-4">
          <button
            onClick={() => window.history.back()}
            className="btn-secondary flex items-center space-x-2 inline-flex"
          >
            <ArrowLeft className="h-4 w-4" />
            <span>Go Back</span>
          </button>
          
          <Link to="/" className="btn-primary flex items-center space-x-2 inline-flex">
            <Home className="h-4 w-4" />
            <span>Go Home</span>
          </Link>
        </div>
      </div>
    </div>
  );
};

export default NotFound;