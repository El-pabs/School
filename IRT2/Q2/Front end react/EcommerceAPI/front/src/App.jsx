import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { CartProvider } from './components/Cart/CartContext'; // Importez CartProvider
import Header from './components/Layout/Header';
import Products from './components/Product/Products';
import ProductDetails from './components/Product/ProductDetails';
import NotFound from './components/NotFound';

function App() {
  return (
    <CartProvider>
      <Router>
        <Header />
        <main>
          <Routes>
            <Route path="/" element={<Products />} />
            <Route path="/product/:id" element={<ProductDetails />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </main>
      </Router>
    </CartProvider>
  );
}

export default App;