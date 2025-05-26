import React from "react";
import { Button } from "react-bootstrap";
import { useState } from "react";
import { useCart } from "../Cart/CartContext";

function ProductItemForm({ product }) {
    const [quantity, setQuantity] = useState(1);
    const { addToCart } = useCart();

    const handleQuantityChange = (event) => {
        const value = event.target.value;
        
        if (value === "") return;

        const parsedValue = parseInt(value, 10);
        if (!isNaN(parsedValue) && parsedValue >= 1) {
            setQuantity(parsedValue);
        }
    };

    const handleBlur = () => {
        if (quantity < 1 || isNaN(quantity)) {
            setQuantity(1);
        }
    };

    const handleSubmit = (event) => {
        event.preventDefault();
        addToCart(product, quantity);
        setQuantity(1);
    };

 return (
    <form onSubmit={handleSubmit} style={{ display: "flex", alignItems: "center" }}>
    <label htmlFor="quantity" style={{ fontSize: "0.8rem" }}>
    Quantité
    <input
        id="quantity"
        name="quantity"
        type="number"
        min="1"
        value={quantity}
        onChange={(e) => setQuantity(Number(e.target.value))}
        style={{ marginRight: "10px" }}
        disabled={product.isOutOfStock}
    />
    </label>
      <button
        className="btn btn-primary"
        type="submit"
        disabled={product.isOutOfStock}
      >
        Add
      </button>
    </form>
  );
}

export default ProductItemForm;
