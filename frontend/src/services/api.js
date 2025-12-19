import axios from 'axios';

// API Configuration
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

// Create axios instance with default config
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    console.log(`Making ${config.method?.toUpperCase()} request to ${config.url}`);
    return config;
  },
  (error) => {
    console.error('Request error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error('Response error:', error);
    
    // Handle specific error cases
    if (error.response) {
      // Server responded with error status
      const { status, data } = error.response;
      
      switch (status) {
        case 404:
          throw new Error(data.error || 'Resource not found');
        case 409:
          throw new Error(data.error || 'Conflict - Resource already exists');
        case 422:
          throw new Error(data.error || 'Validation failed');
        case 500:
          throw new Error('Internal server error. Please try again later.');
        default:
          throw new Error(data.error || `Request failed with status ${status}`);
      }
    } else if (error.request) {
      // Network error
      throw new Error('Network error. Please check your connection and try again.');
    } else {
      // Other error
      throw new Error(error.message || 'An unexpected error occurred');
    }
  }
);

// Employee API functions
export const employeeService = {
  // Get all employees with pagination and filters
  getEmployees: async (params = {}) => {
    const response = await api.get('/employees', { params });
    return response.data;
  },

  // Get employee by ID
  getEmployee: async (id) => {
    const response = await api.get(`/employees/${id}`);
    return response.data;
  },

  // Create new employee
  createEmployee: async (employee) => {
    const response = await api.post('/employees', employee);
    return response.data;
  },

  // Update employee
  updateEmployee: async (id, employee) => {
    const response = await api.put(`/employees/${id}`, employee);
    return response.data;
  },

  // Delete employee (soft delete)
  deleteEmployee: async (id) => {
    await api.delete(`/employees/${id}`);
  },

  // Get department statistics
  getDepartmentStats: async () => {
    const response = await api.get('/employees/stats/departments');
    return response.data;
  },

  // Health check
  healthCheck: async () => {
    const response = await api.get('/health');
    return response.data;
  },
};

// Export axios instance for custom requests if needed
export default api;