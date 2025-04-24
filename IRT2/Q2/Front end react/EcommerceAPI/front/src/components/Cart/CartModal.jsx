import { Button, Modal } from "react-bootstrap";
import { useCart } from "./CartContext";

function CartModal({ open, onClose }) {
  const { items, clearCart } = useCart();

  // Tâche 5 reduce()
  const totalAmount = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  const handleOrder = () => {
    alert("Commande passée avec succès!");
    clearCart();
    onClose();
  };

  return (
    <Modal show={open} onHide={onClose} centered>
      <Modal.Header closeButton>
        <Modal.Title>Cart</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        {items.length === 0 ? (
          <p className="text-center">Votre panier est vide.</p>
        ) : (
          <>
            <table className="table table-striped table-bordered text-center">
              <thead className="table-light">
                <tr>
                  <th scope="col">Name</th>
                  <th scope="col">Price (€)</th>
                  <th scope="col">Quantity</th>
                  <th scope="col">Total</th>
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr key={item._id}>
                    <td>{item.name}</td>
                    <td>{item.price}</td>
                    <td>{item.quantity}</td>
                    <td>{item.price * item.quantity}€</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <h4 className="text-end fw-bold">Total Amount: {totalAmount}€</h4>
          </>
        )}
      </Modal.Body>
      <Modal.Footer>
        <Button variant="secondary" onClick={onClose}>
          Close
        </Button>
        <Button variant="primary" onClick={handleOrder} disabled={items.length === 0}>
          Order
        </Button>
      </Modal.Footer>
    </Modal>
  );
}

export default CartModal;