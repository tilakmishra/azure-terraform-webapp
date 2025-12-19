const { CosmosClient } = require('@azure/cosmos');
const { DefaultAzureCredential } = require('@azure/identity');

class DatabaseConfig {
  constructor() {
    this.client = null;
    this.database = null;
    this.container = null;
    
    // Configuration from environment variables
    this.endpoint = process.env.COSMOS_ENDPOINT;
    this.databaseName = process.env.COSMOS_DATABASE || 'employees';
    this.containerName = process.env.COSMOS_CONTAINER || 'employees';
    this.primaryKey = process.env.COSMOS_PRIMARY_KEY;
    
    if (!this.endpoint) {
      throw new Error('COSMOS_ENDPOINT environment variable is required');
    }
  }

  async connect() {
    try {
      console.log('🔄 Connecting to Cosmos DB...');
      
      // Use managed identity in Azure, fallback to key for local development
      if (process.env.AZURE_CLIENT_ID || process.env.NODE_ENV === 'production') {
        // Use managed identity authentication
        const credential = new DefaultAzureCredential();
        this.client = new CosmosClient({
          endpoint: this.endpoint,
          aadCredentials: credential
        });
        console.log('🔐 Using managed identity authentication');
      } else {
        // Use primary key for local development
        if (!this.primaryKey) {
          throw new Error('COSMOS_PRIMARY_KEY is required for local development');
        }
        this.client = new CosmosClient({
          endpoint: this.endpoint,
          key: this.primaryKey
        });
        console.log('🔑 Using primary key authentication');
      }

      // Get database reference
      const { database } = await this.client.databases.createIfNotExists({
        id: this.databaseName
      });
      this.database = database;

      // Get container reference
      const { container } = await this.database.containers.createIfNotExists({
        id: this.containerName,
        partitionKey: {
          paths: ['/department'],
          kind: 'Hash'
        },
        indexingPolicy: {
          automatic: true,
          indexingMode: 'consistent',
          includedPaths: [
            {
              path: '/*'
            }
          ],
          excludedPaths: [
            {
              path: '/\"_etag\"/?'
            }
          ]
        }
      });
      this.container = container;

      console.log('✅ Successfully connected to Cosmos DB');
      
      // Seed initial data if container is empty
      await this.seedInitialData();
      
      return this.container;
    } catch (error) {
      console.error('❌ Failed to connect to Cosmos DB:', error);
      throw error;
    }
  }

  async seedInitialData() {
    try {
      // Check if data already exists
      const query = 'SELECT VALUE COUNT(1) FROM c';
      const { resources } = await this.container.items.query(query).fetchAll();
      const count = resources[0];

      if (count === 0) {
        console.log('🌱 Seeding initial employee data...');
        
        const initialEmployees = [
          {
            id: '1',
            firstName: 'John',
            lastName: 'Doe',
            email: 'john.doe@company.com',
            department: 'Engineering',
            position: 'Senior Software Engineer',
            hireDate: '2020-01-15',
            salary: 95000,
            isActive: true
          },
          {
            id: '2',
            firstName: 'Jane',
            lastName: 'Smith',
            email: 'jane.smith@company.com',
            department: 'Marketing',
            position: 'Marketing Manager',
            hireDate: '2019-03-20',
            salary: 75000,
            isActive: true
          },
          {
            id: '3',
            firstName: 'Mike',
            lastName: 'Johnson',
            email: 'mike.johnson@company.com',
            department: 'Engineering',
            position: 'DevOps Engineer',
            hireDate: '2021-07-10',
            salary: 85000,
            isActive: true
          },
          {
            id: '4',
            firstName: 'Sarah',
            lastName: 'Wilson',
            email: 'sarah.wilson@company.com',
            department: 'HR',
            position: 'HR Manager',
            hireDate: '2018-11-05',
            salary: 70000,
            isActive: true
          },
          {
            id: '5',
            firstName: 'David',
            lastName: 'Brown',
            email: 'david.brown@company.com',
            department: 'Finance',
            position: 'Financial Analyst',
            hireDate: '2022-02-14',
            salary: 65000,
            isActive: true
          }
        ];

        for (const employee of initialEmployees) {
          await this.container.items.create(employee);
        }

        console.log('✅ Initial employee data seeded successfully');
      }
    } catch (error) {
      console.error('❌ Error seeding initial data:', error);
      // Don't throw here, seeding is optional
    }
  }

  getContainer() {
    if (!this.container) {
      throw new Error('Database not connected. Call connect() first.');
    }
    return this.container;
  }

  getDatabase() {
    if (!this.database) {
      throw new Error('Database not connected. Call connect() first.');
    }
    return this.database;
  }

  getClient() {
    if (!this.client) {
      throw new Error('Database not connected. Call connect() first.');
    }
    return this.client;
  }
}

// Singleton instance
const dbConfig = new DatabaseConfig();

const connectToDatabase = async () => {
  return await dbConfig.connect();
};

const getContainer = () => {
  return dbConfig.getContainer();
};

const getDatabase = () => {
  return dbConfig.getDatabase();
};

const getClient = () => {
  return dbConfig.getClient();
};

module.exports = {
  connectToDatabase,
  getContainer,
  getDatabase,
  getClient
};