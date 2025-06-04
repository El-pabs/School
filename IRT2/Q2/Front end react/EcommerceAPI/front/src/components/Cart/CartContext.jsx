import React from "react";
import { createContext, useReducer, useContext, useMemo } from "react";

// Création du contexte
const CartContext = createContext(null);

// État initial du panier
const initialState = {
  items: [],
  totalQuantity: 0,
};

// Actions
const ACTIONS = {
  ADD_TO_CART: "ADD_TO_CART",
  REMOVE_FROM_CART: "REMOVE_FROM_CART",
  CLEAR_CART: "CLEAR_CART",
};

// Fonction reducer pour gérer les états du panier
function cartReducer(state, action) {
  switch (action.type) {
    case ACTIONS.ADD_TO_CART: {
      const { product, quantity } = action.payload;
      const existingItemIndex = state.items.findIndex((item) => item._id === product._id);

      if (existingItemIndex !== -1) {
        // Mise à jour de la quantité si le produit existe déjà
        const updatedItems = state.items.map((item, index) =>
          index === existingItemIndex ? { ...item, quantity: item.quantity + quantity } : item
        );

        return {
          ...state,
          items: updatedItems,
          totalQuantity: state.totalQuantity + quantity,
        };
      }

      // Ajout d'un nouveau produit
      return {
        ...state,
        items: [...state.items, { ...product, quantity }],
        totalQuantity: state.totalQuantity + quantity,
      };
    }

    case ACTIONS.REMOVE_FROM_CART: {
      const removedItem = state.items.find((item) => item._id === action.payload._id);
      if (!removedItem) return state; // Évite une erreur si l'élément n'est pas trouvé

      const updatedItems = state.items.filter((item) => item._id !== action.payload._id);
      return {
        ...state,
        items: updatedItems,
        totalQuantity: state.totalQuantity - removedItem.quantity,
      };
    }

    case ACTIONS.CLEAR_CART:
      return initialState;

    default:
      return state;
  }
}

// Fournisseur du contexte
export function CartProvider({ children }) {
  const [cartState, dispatch] = useReducer(cartReducer, initialState);

  // Actions disponibles
  const addToCart = (product, quantity) => {
    const existingItem = cartState.items.find((item) => item._id === product._id);
    const totalQuantityInCart = existingItem ? existingItem.quantity + quantity : quantity;
  
    if (product.isOutOfStock || product.quantity - product.sold <= 0) {
      alert(`Le produit "${product.name}" n'est plus disponible.`);
      return;
    }
  
    if (totalQuantityInCart > product.quantity - product.sold) {
      alert(
        `Le produit "${product.name}" n'est disponible qu'en ${product.quantity - product.sold} exemplaire(s).`
      );
      return;
    }
  
    dispatch({ type: ACTIONS.ADD_TO_CART, payload: { product, quantity } });
  };
  const removeFromCart = (product) => dispatch({ type: ACTIONS.REMOVE_FROM_CART, payload: product });
  const clearCart = () => dispatch({ type: ACTIONS.CLEAR_CART });

  // Utilisation de useMemo pour éviter les re-rendus inutiles
  const cartContext = useMemo(
    () => ({
      items: cartState.items,
      totalQuantity: cartState.totalQuantity,
      addToCart,
      removeFromCart,
      clearCart,
    }),
    [cartState]
  );

  return <CartContext.Provider value={cartContext}>{children}</CartContext.Provider>;
}


export function useCart() {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error("useCart must be used within a CartProvider");
  }
  return context;
}

export default CartContext;