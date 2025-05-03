import { Container, Row, Col, Spinner, Alert } from 'react-bootstrap'; // Importez Spinner et Alert
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
        setProducts(response.data.products);
        setLoading(false);
      })
      .catch(err => {
        setError('Le serveur ne répond pas. Veuillez réessayer plus tard.');
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div style={{ textAlign: 'center', marginTop: '20px' }}>
        <Spinner animation="border" role="status">
          <span className="visually-hidden">Chargement...</span>
        </Spinner>
      </div>
    );
  }

  if (error) {
    return (
      <Alert variant="danger" style={{ textAlign: 'center', marginTop: '20px' }}>
        {error}
      </Alert>
    );
  }

  return (
    <Container>
      <Row>
        {products.length === 0 ? (
          <p>Aucun produit disponible</p>
        ) : (
          products.map((product) => (
            <Col md={4} key={product._id}>
              <ProductItem 
                image={product.mainImage}
                id={product._id}
                name={product.name} 
                price={product.price}
                quantity={product.quantity}
                sold={product.sold}
                isOutOfStock={product.isOutOfStock}
              />
            </Col>
          ))
        )}
      </Row>
    </Container>
  );
}

export default Products;