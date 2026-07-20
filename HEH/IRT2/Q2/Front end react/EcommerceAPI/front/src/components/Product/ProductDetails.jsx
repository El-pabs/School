import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";
import { Spinner } from "react-bootstrap";
import { useCart } from "../Cart/CartContext";

/**
 * Affiche les détails d'un produit avec gestion du chargement, des erreurs et du panier.
 */
function ProductDetails() {
  const { id } = useParams();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { items } = useCart();

  useEffect(() => {
    const API_URL = "http://127.0.0.1:3000/api";
    let didCancel = false;
    const timeout = setTimeout(() => {
      if (!didCancel) {
        setError("Le chargement prend trop de temps. Veuillez réessayer plus tard.");
        setLoading(false);
      }
    }, 5000);

    axios
      .get(`${API_URL}/product/${id}`)
      .then((response) => {
        if (!didCancel) {
          clearTimeout(timeout);
          setProduct(response.data.product);
          setLoading(false);
        }
      })
      .catch(() => {
        if (!didCancel) {
          clearTimeout(timeout);
          setError("Impossible de charger les détails du produit.");
          setLoading(false);
        }
      });

    return () => {
      didCancel = true;
      clearTimeout(timeout);
    };
  }, [id]);

  if (loading) {
    return (
      <div style={{ textAlign: "center", marginTop: "40px" }}>
        <Spinner animation="border" role="status" style={{ width: "4rem", height: "4rem" }}>
          <span className="visually-hidden">Chargement...</span>
        </Spinner>
        <div style={{ marginTop: "15px", fontWeight: "bold", fontSize: "1.2rem" }}>
          Chargement des détails du produit...
        </div>
      </div>
    );
  }

  if (error) {
    return <p>{error}</p>;
  }

  const itemInCart = items.find((item) => item._id === product._id);

  return (
    <div style={{ padding: "20px" }}>
      <h1>{product.name}</h1>
      <img src={product.mainImage} alt={product.name} style={{ width: "300px" }} />
      <p>Prix : {product.price} €</p>
      <p>Description : {product.description}</p>
      <p>Quantité disponible : {product.quantity - product.sold}</p>
      <p>
        Statut :{" "}
        {product.isOutOfStock ? (
          <span style={{ color: "red", fontWeight: "bold" }}>Rupture de stock</span>
        ) : (
          <span style={{ color: "green", fontWeight: "bold" }}>En stock</span>
        )}
      </p>
      {itemInCart && (
        <p style={{ color: "#0d6efd", fontWeight: "bold" }}>
          Vous avez déjà cet article dans votre panier ({itemInCart.quantity} exemplaire{itemInCart.quantity > 1 ? "s" : ""})
        </p>
      )}
    </div>
  );
}

export default ProductDetails;