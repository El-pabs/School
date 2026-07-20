import React, { useState } from "react";
import { Button } from "react-bootstrap";
import { useCart } from "../Cart/CartContext";

/**
 * Formulaire pour ajouter un produit au panier.
 * Désactive les champs si le produit est en rupture de stock.
 */
function ProductItemForm({ product }) {
  const [quantity, setQuantity] = useState(1);
  const { addToCart } = useCart();

  // Gère la modification de la quantité
  const handleQuantityChange = (event) => {
    const value = event.target.value;
    if (value === "") return;
    const parsedValue = parseInt(value, 10);
    if (!isNaN(parsedValue) && parsedValue >= 1) {
      setQuantity(parsedValue);
    }
  };

  // Remet la quantité à 1 si l'utilisateur quitte le champ avec une valeur invalide
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
          onChange={handleQuantityChange}
          onBlur={handleBlur}
          style={{ marginRight: "10px" }}
          disabled={product.isOutOfStock}
        />
      </label>
      <Button
        className="btn btn-primary"
        type="submit"
        disabled={product.isOutOfStock}
      >
        Add
      </Button>
    </form>
  );
}

export default ProductItemForm;
