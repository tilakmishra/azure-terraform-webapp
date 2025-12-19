import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation, useQueryClient } from 'react-query';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { ArrowLeft, Save, Loader2 } from 'lucide-react';
import { employeeService } from '../services/api';
import { toast } from 'react-toastify';

// Validation schema
const schema = yup.object({
  firstName: yup
    .string()
    .required('First name is required')
    .min(1, 'First name must be at least 1 character')
    .max(50, 'First name must be less than 50 characters'),
  lastName: yup
    .string()
    .required('Last name is required')
    .min(1, 'Last name must be at least 1 character')
    .max(50, 'Last name must be less than 50 characters'),
  email: yup
    .string()
    .required('Email is required')
    .email('Please enter a valid email address'),
  department: yup
    .string()
    .required('Department is required')
    .max(100, 'Department must be less than 100 characters'),
  position: yup
    .string()
    .required('Position is required')
    .max(100, 'Position must be less than 100 characters'),
  hireDate: yup
    .date()
    .required('Hire date is required')
    .max(new Date(), 'Hire date cannot be in the future'),
  salary: yup
    .number()
    .required('Salary is required')
    .positive('Salary must be a positive number')
    .min(1, 'Salary must be at least $1'),
});

const CreateEmployee = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  // Form setup
  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm({
    resolver: yupResolver(schema),
    defaultValues: {
      firstName: '',
      lastName: '',
      email: '',
      department: '',
      position: '',
      hireDate: '',
      salary: '',
    },
  });

  // Create employee mutation
  const createMutation = useMutation(
    (data) => employeeService.createEmployee(data),
    {
      onSuccess: (newEmployee) => {
        toast.success('Employee created successfully');
        queryClient.invalidateQueries('employees');
        navigate(`/employees/${newEmployee.id}`);
      },
      onError: (error) => {
        toast.error(error.message || 'Failed to create employee');
      },
    }
  );

  const onSubmit = (data) => {
    // Convert salary to number
    const employeeData = {
      ...data,
      salary: parseInt(data.salary, 10),
    };
    
    createMutation.mutate(employeeData);
  };

  const handleReset = () => {
    reset();
  };

  // Common departments for suggestions
  const commonDepartments = [
    'Engineering',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
    'Operations',
    'Design',
    'Customer Support',
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <Link 
          to="/employees"
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <ArrowLeft className="h-5 w-5 text-gray-600" />
        </Link>
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Add New Employee</h1>
          <p className="text-gray-600">Create a new employee record</p>
        </div>
      </div>

      {/* Form */}
      <div className="card p-6">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          {/* Personal Information */}
          <div>
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Personal Information
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* First Name */}
              <div>
                <label htmlFor="firstName" className="form-label">
                  First Name *
                </label>
                <input
                  id="firstName"
                  type="text"
                  {...register('firstName')}
                  className={`form-input ${errors.firstName ? 'border-red-500' : ''}`}
                  placeholder="Enter first name"
                />
                {errors.firstName && (
                  <p className="form-error">{errors.firstName.message}</p>
                )}
              </div>

              {/* Last Name */}
              <div>
                <label htmlFor="lastName" className="form-label">
                  Last Name *
                </label>
                <input
                  id="lastName"
                  type="text"
                  {...register('lastName')}
                  className={`form-input ${errors.lastName ? 'border-red-500' : ''}`}
                  placeholder="Enter last name"
                />
                {errors.lastName && (
                  <p className="form-error">{errors.lastName.message}</p>
                )}
              </div>

              {/* Email */}
              <div className="md:col-span-2">
                <label htmlFor="email" className="form-label">
                  Email Address *
                </label>
                <input
                  id="email"
                  type="email"
                  {...register('email')}
                  className={`form-input ${errors.email ? 'border-red-500' : ''}`}
                  placeholder="Enter email address"
                />
                {errors.email && (
                  <p className="form-error">{errors.email.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* Work Information */}
          <div>
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Work Information
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* Department */}
              <div>
                <label htmlFor="department" className="form-label">
                  Department *
                </label>
                <input
                  id="department"
                  type="text"
                  {...register('department')}
                  className={`form-input ${errors.department ? 'border-red-500' : ''}`}
                  placeholder="Enter department"
                  list="departments"
                />
                <datalist id="departments">
                  {commonDepartments.map((dept) => (
                    <option key={dept} value={dept} />
                  ))}
                </datalist>
                {errors.department && (
                  <p className="form-error">{errors.department.message}</p>
                )}
              </div>

              {/* Position */}
              <div>
                <label htmlFor="position" className="form-label">
                  Position *
                </label>
                <input
                  id="position"
                  type="text"
                  {...register('position')}
                  className={`form-input ${errors.position ? 'border-red-500' : ''}`}
                  placeholder="Enter position/job title"
                />
                {errors.position && (
                  <p className="form-error">{errors.position.message}</p>
                )}
              </div>

              {/* Hire Date */}
              <div>
                <label htmlFor="hireDate" className="form-label">
                  Hire Date *
                </label>
                <input
                  id="hireDate"
                  type="date"
                  {...register('hireDate')}
                  className={`form-input ${errors.hireDate ? 'border-red-500' : ''}`}
                  max={new Date().toISOString().split('T')[0]}
                />
                {errors.hireDate && (
                  <p className="form-error">{errors.hireDate.message}</p>
                )}
              </div>

              {/* Salary */}
              <div>
                <label htmlFor="salary" className="form-label">
                  Annual Salary *
                </label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-500">
                    $
                  </span>
                  <input
                    id="salary"
                    type="number"
                    min="1"
                    step="1000"
                    {...register('salary')}
                    className={`form-input pl-8 ${errors.salary ? 'border-red-500' : ''}`}
                    placeholder="0"
                  />
                </div>
                {errors.salary && (
                  <p className="form-error">{errors.salary.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* Form Actions */}
          <div className="flex justify-end space-x-4 pt-6 border-t">
            <button
              type="button"
              onClick={handleReset}
              className="btn-secondary"
              disabled={createMutation.isLoading}
            >
              Reset
            </button>
            <Link
              to="/employees"
              className="btn-secondary"
            >
              Cancel
            </Link>
            <button
              type="submit"
              disabled={createMutation.isLoading}
              className="btn-primary flex items-center space-x-2"
            >
              {createMutation.isLoading ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Save className="h-4 w-4" />
              )}
              <span>
                {createMutation.isLoading ? 'Creating...' : 'Create Employee'}
              </span>
            </button>
          </div>
        </form>
      </div>

      {/* Helper Text */}
      <div className="text-center text-gray-500 text-sm">
        <p>* Required fields must be filled out before submitting.</p>
      </div>
    </div>
  );
};

export default CreateEmployee;