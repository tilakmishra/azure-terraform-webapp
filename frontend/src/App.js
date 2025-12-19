import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout/Layout';
import EmployeeList from './pages/EmployeeList';
import EmployeeDetails from './pages/EmployeeDetails';
import CreateEmployee from './pages/CreateEmployee';
import EditEmployee from './pages/EditEmployee';
import Dashboard from './pages/Dashboard';
import NotFound from './pages/NotFound';

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/employees" element={<EmployeeList />} />
        <Route path="/employees/create" element={<CreateEmployee />} />
        <Route path="/employees/:id" element={<EmployeeDetails />} />
        <Route path="/employees/:id/edit" element={<EditEmployee />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Layout>
  );
}

export default App;