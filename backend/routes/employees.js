const express = require('express');
const { v4: uuidv4 } = require('uuid');
const Joi = require('joi');
const { getContainer } = require('../config/database');

const router = express.Router();

// Validation schemas
const employeeSchema = Joi.object({
  firstName: Joi.string().min(1).max(50).required(),
  lastName: Joi.string().min(1).max(50).required(),
  email: Joi.string().email().required(),
  department: Joi.string().min(1).max(100).required(),
  position: Joi.string().min(1).max(100).required(),
  hireDate: Joi.date().iso().required(),
  salary: Joi.number().positive().required(),
  isActive: Joi.boolean().default(true)
});

const updateEmployeeSchema = Joi.object({
  firstName: Joi.string().min(1).max(50),
  lastName: Joi.string().min(1).max(50),
  email: Joi.string().email(),
  department: Joi.string().min(1).max(100),
  position: Joi.string().min(1).max(100),
  hireDate: Joi.date().iso(),
  salary: Joi.number().positive(),
  isActive: Joi.boolean()
}).min(1);

// Helper function to handle Cosmos DB errors
const handleCosmosError = (error, res) => {
  console.error('Cosmos DB error:', error);
  
  if (error.code === 404) {
    return res.status(404).json({ error: 'Employee not found' });
  }
  
  if (error.code === 409) {
    return res.status(409).json({ error: 'Employee with this email already exists' });
  }
  
  return res.status(500).json({ 
    error: 'Database operation failed',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
  });
};

// GET /api/employees - Get all employees
router.get('/', async (req, res) => {
  try {
    const container = getContainer();
    const { page = 1, limit = 10, department, search, sortBy = 'lastName', sortOrder = 'asc' } = req.query;
    
    let query = 'SELECT * FROM c WHERE c.isActive = true';
    const parameters = [];
    
    // Filter by department
    if (department) {
      query += ' AND c.department = @department';
      parameters.push({ name: '@department', value: department });
    }
    
    // Search functionality
    if (search) {
      query += ' AND (CONTAINS(LOWER(c.firstName), LOWER(@search)) OR CONTAINS(LOWER(c.lastName), LOWER(@search)) OR CONTAINS(LOWER(c.email), LOWER(@search)))';
      parameters.push({ name: '@search', value: search });
    }
    
    // Sorting
    const validSortFields = ['firstName', 'lastName', 'email', 'department', 'position', 'hireDate', 'salary'];
    const sortField = validSortFields.includes(sortBy) ? sortBy : 'lastName';
    const order = sortOrder.toLowerCase() === 'desc' ? 'DESC' : 'ASC';
    query += ` ORDER BY c.${sortField} ${order}`;
    
    const querySpec = {
      query: query,
      parameters: parameters
    };
    
    const { resources: employees } = await container.items.query(querySpec).fetchAll();
    
    // Pagination
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedEmployees = employees.slice(startIndex, endIndex);
    
    // Get unique departments for filter options
    const departmentsQuery = 'SELECT DISTINCT VALUE c.department FROM c WHERE c.isActive = true';
    const { resources: departments } = await container.items.query(departmentsQuery).fetchAll();
    
    res.json({
      employees: paginatedEmployees,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: employees.length,
        pages: Math.ceil(employees.length / parseInt(limit))
      },
      departments: departments.sort(),
      filters: {
        department,
        search,
        sortBy: sortField,
        sortOrder: order.toLowerCase()
      }
    });
  } catch (error) {
    handleCosmosError(error, res);
  }
});

// GET /api/employees/:id - Get employee by ID
router.get('/:id', async (req, res) => {
  try {
    const container = getContainer();
    const { id } = req.params;
    
    const query = 'SELECT * FROM c WHERE c.id = @id';
    const { resources } = await container.items.query({
      query,
      parameters: [{ name: '@id', value: id }]
    }).fetchAll();
    
    if (resources.length === 0) {
      return res.status(404).json({ error: 'Employee not found' });
    }
    
    res.json(resources[0]);
  } catch (error) {
    handleCosmosError(error, res);
  }
});

// POST /api/employees - Create new employee
router.post('/', async (req, res) => {
  try {
    const { error, value } = employeeSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation failed', 
        details: error.details.map(d => d.message) 
      });
    }
    
    const container = getContainer();
    
    // Check if email already exists
    const emailCheckQuery = 'SELECT VALUE COUNT(1) FROM c WHERE c.email = @email AND c.isActive = true';
    const { resources } = await container.items.query({
      query: emailCheckQuery,
      parameters: [{ name: '@email', value: value.email }]
    }).fetchAll();
    
    if (resources[0] > 0) {
      return res.status(409).json({ error: 'Employee with this email already exists' });
    }
    
    // Create new employee
    const newEmployee = {
      id: uuidv4(),
      ...value,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    const { resource } = await container.items.create(newEmployee);
    
    res.status(201).json(resource);
  } catch (error) {
    handleCosmosError(error, res);
  }
});

// PUT /api/employees/:id - Update employee
router.put('/:id', async (req, res) => {
  try {
    const { error, value } = updateEmployeeSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation failed', 
        details: error.details.map(d => d.message) 
      });
    }
    
    const container = getContainer();
    const { id } = req.params;
    
    // Get existing employee
    const query = 'SELECT * FROM c WHERE c.id = @id';
    const { resources } = await container.items.query({
      query,
      parameters: [{ name: '@id', value: id }]
    }).fetchAll();
    
    if (resources.length === 0) {
      return res.status(404).json({ error: 'Employee not found' });
    }
    
    const existingEmployee = resources[0];
    
    // Check if email is being changed and if new email already exists
    if (value.email && value.email !== existingEmployee.email) {
      const emailCheckQuery = 'SELECT VALUE COUNT(1) FROM c WHERE c.email = @email AND c.id != @id AND c.isActive = true';
      const { resources: emailCheck } = await container.items.query({
        query: emailCheckQuery,
        parameters: [
          { name: '@email', value: value.email },
          { name: '@id', value: id }
        ]
      }).fetchAll();
      
      if (emailCheck[0] > 0) {
        return res.status(409).json({ error: 'Employee with this email already exists' });
      }
    }
    
    // Update employee
    const updatedEmployee = {
      ...existingEmployee,
      ...value,
      updatedAt: new Date().toISOString()
    };
    
    const { resource } = await container.items.upsert(updatedEmployee);
    
    res.json(resource);
  } catch (error) {
    handleCosmosError(error, res);
  }
});

// DELETE /api/employees/:id - Soft delete employee
router.delete('/:id', async (req, res) => {
  try {
    const container = getContainer();
    const { id } = req.params;
    
    // Get existing employee
    const query = 'SELECT * FROM c WHERE c.id = @id';
    const { resources } = await container.items.query({
      query,
      parameters: [{ name: '@id', value: id }]
    }).fetchAll();
    
    if (resources.length === 0) {
      return res.status(404).json({ error: 'Employee not found' });
    }
    
    const existingEmployee = resources[0];
    
    // Soft delete by setting isActive to false
    const deletedEmployee = {
      ...existingEmployee,
      isActive: false,
      deletedAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    await container.items.upsert(deletedEmployee);
    
    res.status(204).send();
  } catch (error) {
    handleCosmosError(error, res);
  }
});

// GET /api/employees/stats/departments - Get department statistics
router.get('/stats/departments', async (req, res) => {
  try {
    const container = getContainer();
    
    const query = `
      SELECT c.department, COUNT(1) as count, AVG(c.salary) as avgSalary
      FROM c 
      WHERE c.isActive = true 
      GROUP BY c.department
    `;
    
    const { resources } = await container.items.query(query).fetchAll();
    
    res.json(resources);
  } catch (error) {
    handleCosmosError(error, res);
  }
});

module.exports = router;