import React from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import { 
  ArrowLeft, 
  Edit, 
  Trash2, 
  Mail, 
  Building, 
  Briefcase, 
  Calendar, 
  DollarSign,
  Loader2 
} from 'lucide-react';
import { employeeService } from '../services/api';
import { toast } from 'react-toastify';

const EmployeeDetails = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  // Fetch employee details
  const { 
    data: employee, 
    isLoading, 
    error 
  } = useQuery(
    ['employee', id],
    () => employeeService.getEmployee(id),
    {
      enabled: !!id,
    }
  );

  // Delete mutation
  const deleteMutation = useMutation(
    () => employeeService.deleteEmployee(id),
    {
      onSuccess: () => {
        toast.success('Employee deleted successfully');
        queryClient.invalidateQueries('employees');
        navigate('/employees');
      },
      onError: (error) => {
        toast.error(error.message || 'Failed to delete employee');
      },
    }
  );

  const handleDelete = () => {
    if (!employee) return;
    
    const confirmMessage = `Are you sure you want to delete ${employee.firstName} ${employee.lastName}? This action cannot be undone.`;
    
    if (window.confirm(confirmMessage)) {
      deleteMutation.mutate();
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
        <span className="ml-2 text-gray-600">Loading employee details...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <div className="text-red-600 text-lg mb-4">Error loading employee</div>
        <p className="text-gray-600 mb-4">{error.message}</p>
        <Link to="/employees" className="btn-primary">
          Back to Employees
        </Link>
      </div>
    );
  }

  if (!employee) {
    return (
      <div className="text-center py-12">
        <div className="text-gray-600 text-lg mb-4">Employee not found</div>
        <Link to="/employees" className="btn-primary">
          Back to Employees
        </Link>
      </div>
    );
  }

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <Link 
            to="/employees"
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <ArrowLeft className="h-5 w-5 text-gray-600" />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {employee.firstName} {employee.lastName}
            </h1>
            <p className="text-gray-600">{employee.position}</p>
          </div>
        </div>
        
        <div className="flex items-center space-x-3">
          <Link 
            to={`/employees/${employee.id}/edit`}
            className="btn-primary flex items-center space-x-2"
          >
            <Edit className="h-4 w-4" />
            <span>Edit</span>
          </Link>
          <button 
            onClick={handleDelete}
            disabled={deleteMutation.isLoading}
            className="btn-danger flex items-center space-x-2"
          >
            {deleteMutation.isLoading ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <Trash2 className="h-4 w-4" />
            )}
            <span>Delete</span>
          </button>
        </div>
      </div>

      {/* Employee Details Card */}
      <div className="card p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Personal Information */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Personal Information
            </h2>
            
            <div className="space-y-3">
              <div className="flex items-center space-x-3">
                <Mail className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Email</p>
                  <p className="text-gray-900">{employee.email}</p>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <Calendar className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Hire Date</p>
                  <p className="text-gray-900">{formatDate(employee.hireDate)}</p>
                </div>
              </div>
            </div>
          </div>

          {/* Work Information */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-900 border-b pb-2">
              Work Information
            </h2>
            
            <div className="space-y-3">
              <div className="flex items-center space-x-3">
                <Building className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Department</p>
                  <span className="inline-flex px-2 py-1 text-sm font-semibold rounded-full bg-blue-100 text-blue-800">
                    {employee.department}
                  </span>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <Briefcase className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Position</p>
                  <p className="text-gray-900">{employee.position}</p>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <DollarSign className="h-5 w-5 text-gray-400" />
                <div>
                  <p className="text-sm text-gray-500">Salary</p>
                  <p className="text-gray-900 font-semibold">
                    ${employee.salary.toLocaleString()}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Additional Information */}
        <div className="mt-8 pt-6 border-t">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Additional Information
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div>
              <p className="text-gray-500">Employee ID</p>
              <p className="text-gray-900 font-mono">{employee.id}</p>
            </div>
            
            <div>
              <p className="text-gray-500">Status</p>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                employee.isActive 
                  ? 'bg-green-100 text-green-800' 
                  : 'bg-red-100 text-red-800'
              }`}>
                {employee.isActive ? 'Active' : 'Inactive'}
              </span>
            </div>
            
            {employee.createdAt && (
              <div>
                <p className="text-gray-500">Created</p>
                <p className="text-gray-900">{formatDate(employee.createdAt)}</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex justify-center space-x-4">
        <Link to="/employees" className="btn-secondary">
          Back to Employee List
        </Link>
        <Link 
          to={`/employees/${employee.id}/edit`}
          className="btn-primary"
        >
          Edit Employee
        </Link>
      </div>
    </div>
  );
};

export default EmployeeDetails;