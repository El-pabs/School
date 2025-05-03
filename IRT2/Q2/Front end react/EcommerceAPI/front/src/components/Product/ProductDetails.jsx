import { useParams } from "react-router-dom";
import { useEffect, useState } from "react";
import axios from "axios";

function ProductDetails() {
  const { id } = useParams(); // Récupère l'ID du produit depuis l'URL
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const API_URL = "http://127.0.0.1:3000/api";

    axios
      .get(`${API_URL}/product/${id}`)
      .then((response) => {
        setProduct(response.data.product);
        setLoading(false);
      })
      .catch((err) => {
        setError("Impossible de charger les détails du produit.");
        setLoading(false);
      });
  }, [id]);

  if (loading) {
    return <p>Chargement...</p>;
  }

  if (error) {
    return <p>{error}</p>;
  }

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
    </p>    </div>
  );
}

export default ProductDetails;