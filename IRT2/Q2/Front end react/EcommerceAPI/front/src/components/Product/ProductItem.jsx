import React from "react";
import { Card } from "react-bootstrap";
import { Link } from "react-router-dom";
import ProductItemForm from "./ProductItemForm";

function ProductItem(props) {
  const product = {
    _id: props.id || props.key,
    name: props.name,
    price: props.price,
    image: props.image,
    quantity: props.quantity,
    sold: props.sold,
    isOutOfStock: props.isOutOfStock,
  };

  return (
    <Card style={{ width: "18rem", margin: "10px" }}>
      <Link to={`/product/${product._id}`} style={{ textDecoration: "none", color: "inherit" }}>
        <Card.Img
          variant="top"
          src={props.image}
          alt={props.name}
          style={{
            width: "100%",
            height: "200px",      // Hauteur fixe pour toutes les images
            objectFit: "cover",   // Remplit le cadre, rogne si besoin
            objectPosition: "center"
          }}
        />
        <Card.Body>
          <Card.Title>{props.name}</Card.Title>
          <Card.Text>{props.price} €</Card.Text>
        </Card.Body>
      </Link>
      <ProductItemForm product={product} />
    </Card>
  );
}

export default ProductItem;