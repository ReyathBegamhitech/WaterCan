import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import CreateSeller from './pages/CreateSeller';
import SellerList from './pages/SellerList';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/create-seller" element={<CreateSeller />} />
          <Route path="/sellers" element={<SellerList />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
