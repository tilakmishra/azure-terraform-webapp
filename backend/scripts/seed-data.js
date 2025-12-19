/**
 * Seed Script for Cosmos DB
 * Adds sample employee data to the database
 * 
 * Usage: 
 *   node scripts/seed-data.js
 * 
 * Required environment variables:
 *   COSMOS_ENDPOINT - Cosmos DB endpoint URL
 *   COSMOS_PRIMARY_KEY - Cosmos DB primary key (for local/dev)
 */

const { CosmosClient } = require('@azure/cosmos');
require('dotenv').config();

const endpoint = process.env.COSMOS_ENDPOINT;
const key = process.env.COSMOS_PRIMARY_KEY;
const databaseName = process.env.COSMOS_DATABASE || 'employees';
const containerName = process.env.COSMOS_CONTAINER || 'employees';

// Sample employee data
const sampleEmployees = [
  {
    id: 'emp-001',
    employeeId: 'EMP001',
    firstName: 'John',
    lastName: 'Smith',
    email: 'john.smith@company.com',
    department: 'Engineering',
    position: 'Senior Software Engineer',
    hireDate: '2021-03-15',
    salary: 95000,
    isActive: true
  },
  {
    id: 'emp-002',
    employeeId: 'EMP002',
    firstName: 'Sarah',
    lastName: 'Johnson',
    email: 'sarah.johnson@company.com',
    department: 'Engineering',
    position: 'Tech Lead',
    hireDate: '2019-06-01',
    salary: 125000,
    isActive: true
  },
  {
    id: 'emp-003',
    employeeId: 'EMP003',
    firstName: 'Michael',
    lastName: 'Williams',
    email: 'michael.williams@company.com',
    department: 'Sales',
    position: 'Sales Manager',
    hireDate: '2020-01-10',
    salary: 85000,
    isActive: true
  },
  {
    id: 'emp-004',
    employeeId: 'EMP004',
    firstName: 'Emily',
    lastName: 'Brown',
    email: 'emily.brown@company.com',
    department: 'HR',
    position: 'HR Director',
    hireDate: '2018-09-20',
    salary: 110000,
    isActive: true
  },
  {
    id: 'emp-005',
    employeeId: 'EMP005',
    firstName: 'David',
    lastName: 'Garcia',
    email: 'david.garcia@company.com',
    department: 'Finance',
    position: 'Financial Analyst',
    hireDate: '2022-02-14',
    salary: 75000,
    isActive: true
  },
  {
    id: 'emp-006',
    employeeId: 'EMP006',
    firstName: 'Jennifer',
    lastName: 'Martinez',
    email: 'jennifer.martinez@company.com',
    department: 'Engineering',
    position: 'DevOps Engineer',
    hireDate: '2021-08-01',
    salary: 90000,
    isActive: true
  },
  {
    id: 'emp-007',
    employeeId: 'EMP007',
    firstName: 'Robert',
    lastName: 'Anderson',
    email: 'robert.anderson@company.com',
    department: 'Sales',
    position: 'Account Executive',
    hireDate: '2023-01-15',
    salary: 70000,
    isActive: true
  },
  {
    id: 'emp-008',
    employeeId: 'EMP008',
    firstName: 'Lisa',
    lastName: 'Taylor',
    email: 'lisa.taylor@company.com',
    department: 'Marketing',
    position: 'Marketing Manager',
    hireDate: '2020-05-10',
    salary: 88000,
    isActive: true
  },
  {
    id: 'emp-009',
    employeeId: 'EMP009',
    firstName: 'James',
    lastName: 'Thomas',
    email: 'james.thomas@company.com',
    department: 'Engineering',
    position: 'Junior Developer',
    hireDate: '2023-06-01',
    salary: 65000,
    isActive: true
  },
  {
    id: 'emp-010',
    employeeId: 'EMP010',
    firstName: 'Amanda',
    lastName: 'Jackson',
    email: 'amanda.jackson@company.com',
    department: 'Finance',
    position: 'Controller',
    hireDate: '2017-11-01',
    salary: 130000,
    isActive: true
  }
];

async function seedDatabase() {
  console.log('🌱 Starting database seed...\n');

  if (!endpoint || !key) {
    console.error('❌ Missing required environment variables:');
    console.error('   COSMOS_ENDPOINT:', endpoint ? '✓' : '✗');
    console.error('   COSMOS_PRIMARY_KEY:', key ? '✓' : '✗');
    process.exit(1);
  }

  try {
    // Initialize Cosmos client
    const client = new CosmosClient({ endpoint, key });
    console.log('✓ Connected to Cosmos DB');

    // Get or create database
    const { database } = await client.databases.createIfNotExists({ 
      id: databaseName 
    });
    console.log(`✓ Database: ${databaseName}`);

    // Get or create container
    const { container } = await database.containers.createIfNotExists({
      id: containerName,
      partitionKey: { paths: ['/department'] }
    });
    console.log(`✓ Container: ${containerName}`);

    // Insert sample data
    console.log('\n📥 Inserting sample employees...\n');
    
    let inserted = 0;
    let skipped = 0;

    for (const employee of sampleEmployees) {
      try {
        // Add timestamp
        employee.createdAt = new Date().toISOString();
        employee.updatedAt = new Date().toISOString();
        
        await container.items.upsert(employee);
        console.log(`  ✓ ${employee.firstName} ${employee.lastName} (${employee.department})`);
        inserted++;
      } catch (error) {
        if (error.code === 409) {
          console.log(`  ⊘ ${employee.firstName} ${employee.lastName} (already exists)`);
          skipped++;
        } else {
          throw error;
        }
      }
    }

    console.log('\n' + '─'.repeat(50));
    console.log(`✅ Seed completed!`);
    console.log(`   Inserted: ${inserted}`);
    console.log(`   Skipped:  ${skipped}`);
    console.log(`   Total:    ${sampleEmployees.length}`);

  } catch (error) {
    console.error('\n❌ Seed failed:', error.message);
    process.exit(1);
  }
}

// Run the seed
seedDatabase();
