import { Container, Row, Col } from 'react-bootstrap';
import ProductItem from './ProductItem';
import { useEffect, useState } from 'react';
import axios from 'axios';

function Products() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  


  useEffect(() => {
    const API_URL = 'http://127.0.0.1:3000/api'; 

    setLoading(true);
    
    axios.get(`${API_URL}/product`)
      .then(response => {
        console.log('Products fetched:', response.data);
        setProducts(response.data.products);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching products:', err);
        setError('Failed to load products');
        setLoading(false);
      });
    
      
  }, []);
  if (loading) return <p>Loading products...</p>;
  if (error) return <p>Error: {error}</p>;

return (
    <Container>
      <Row>
        {products.length === 0 ? (
          <p>No products available</p>
        ) : (
          products.map((product) => (
            <Col md={4} key={product._id}>
              <ProductItem 
                id={product._id}
                name={product.name} 
                price={product.price}
              />
            </Col>
          ))
        )}
      </Row>
    </Container>
  );
}

export default Products;