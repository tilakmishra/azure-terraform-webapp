import React from 'react';
import { useQuery } from 'react-query';
import { Link } from 'react-router-dom';
import { Users, TrendingUp, Building, DollarSign, Loader2 } from 'lucide-react';
import { employeeService } from '../services/api';

const Dashboard = () => {
  // Fetch employees data for dashboard stats
  const { data: employeesData, isLoading: employeesLoading } = useQuery(
    'employees-dashboard',
    () => employeeService.getEmployees({ limit: 1000 }),
    {
      staleTime: 5 * 60 * 1000, // 5 minutes
    }
  );

  // Fetch department stats
  const { data: departmentStats, isLoading: statsLoading } = useQuery(
    'department-stats',
    employeeService.getDepartmentStats,
    {
      staleTime: 5 * 60 * 1000, // 5 minutes
    }
  );

  if (employeesLoading || statsLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
        <span className="ml-2 text-gray-600">Loading dashboard...</span>
      </div>
    );
  }

  const employees = employeesData?.employees || [];
  const totalEmployees = employees.length;
  const totalDepartments = departmentStats?.length || 0;
  const averageSalary = employees.length > 0 
    ? Math.round(employees.reduce((sum, emp) => sum + emp.salary, 0) / employees.length)
    : 0;
  const recentHires = employees
    .filter(emp => {
      const hireDate = new Date(emp.hireDate);
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      return hireDate >= thirtyDaysAgo;
    })
    .length;

  const stats = [
    {
      title: 'Total Employees',
      value: totalEmployees,
      icon: Users,
      color: 'bg-blue-500',
      change: `+${recentHires} this month`,
    },
    {
      title: 'Departments',
      value: totalDepartments,
      icon: Building,
      color: 'bg-green-500',
    },
    {
      title: 'Average Salary',
      value: `$${averageSalary.toLocaleString()}`,
      icon: DollarSign,
      color: 'bg-yellow-500',
    },
    {
      title: 'Recent Hires',
      value: recentHires,
      icon: TrendingUp,
      color: 'bg-purple-500',
      change: 'Last 30 days',
    },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600 mt-1">
            Welcome to the Employee Management System
          </p>
        </div>
        <Link
          to="/employees/create"
          className="btn-primary flex items-center space-x-2"
        >
          <Users className="h-4 w-4" />
          <span>Add Employee</span>
        </Link>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <div key={index} className="card p-6">
              <div className="flex items-center">
                <div className={`${stat.color} p-3 rounded-lg`}>
                  <Icon className="h-6 w-6 text-white" />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-600">
                    {stat.title}
                  </p>
                  <p className="text-2xl font-semibold text-gray-900">
                    {stat.value}
                  </p>
                  {stat.change && (
                    <p className="text-xs text-gray-500">{stat.change}</p>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Department Overview */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Department Statistics */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Department Overview
          </h3>
          <div className="space-y-4">
            {departmentStats?.map((dept, index) => (
              <div key={index} className="flex justify-between items-center">
                <div>
                  <p className="font-medium text-gray-900">{dept.department}</p>
                  <p className="text-sm text-gray-500">
                    Avg. Salary: ${Math.round(dept.avgSalary).toLocaleString()}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-2xl font-semibold text-gray-900">
                    {dept.count}
                  </p>
                  <p className="text-sm text-gray-500">employees</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Employees */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Recent Employees
          </h3>
          <div className="space-y-4">
            {employees
              .sort((a, b) => new Date(b.hireDate) - new Date(a.hireDate))
              .slice(0, 5)
              .map((employee) => (
                <div key={employee.id} className="flex justify-between items-center">
                  <div>
                    <p className="font-medium text-gray-900">
                      {employee.firstName} {employee.lastName}
                    </p>
                    <p className="text-sm text-gray-500">{employee.department}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-gray-900">{employee.position}</p>
                    <p className="text-xs text-gray-500">
                      {new Date(employee.hireDate).toLocaleDateString()}
                    </p>
                  </div>
                </div>
              ))}
            {employees.length === 0 && (
              <p className="text-gray-500 text-center py-4">
                No employees found
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="card p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Quick Actions
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Link
            to="/employees"
            className="flex items-center justify-center p-4 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Users className="h-5 w-5 text-gray-600 mr-2" />
            <span className="text-gray-700">View All Employees</span>
          </Link>
          <Link
            to="/employees/create"
            className="flex items-center justify-center p-4 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <TrendingUp className="h-5 w-5 text-gray-600 mr-2" />
            <span className="text-gray-700">Add New Employee</span>
          </Link>
          <button
            onClick={() => window.location.reload()}
            className="flex items-center justify-center p-4 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Building className="h-5 w-5 text-gray-600 mr-2" />
            <span className="text-gray-700">Refresh Data</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;