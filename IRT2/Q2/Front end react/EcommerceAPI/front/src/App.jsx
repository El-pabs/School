import { CartProvider } from './components/Cart/CartContext';
import Header from './components/Layout/Header';
import Products from './components/Product/Products';
import 'bootstrap/dist/css/bootstrap.min.css';

function App() {
  return (
    <CartProvider>
      <div className="App">
        <Header />
        <main>
          <Products />
        </main>
      </div>
    </CartProvider>
  );
}

export default App