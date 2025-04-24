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
                <input
                    type="number"
                    id="quantity"
                    name="quantity"
                    min="1"
                    value={quantity}
                    onChange={handleQuantityChange}
                    onBlur={handleBlur}
                    style={{ marginRight: "10px" }}
                />
            </label>
            <Button variant="primary" type="submit">Add</Button>
        </form>
    );
}

export default ProductItemForm;
