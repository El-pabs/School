import { Card } from 'react-bootstrap';
import ProductItemForm from './ProductItemForm';

function ProductItem(props) {
    const product = {
        _id: props.id || props.key,
        name: props.name,
        price: props.price,
        
    };
    
    return (
        <Card style={{ width: '18rem', margin: "10px" }}>
            <Card.Img variant="top" src={props.image} alt="" />
            <Card.Body>
                <Card.Title>{props.name}</Card.Title>
                <Card.Text>{props.price} €</Card.Text>
                <ProductItemForm product={product} />
            </Card.Body>
        </Card>
    );
}   

export default ProductItem;