import React from "react";
import { createContext, useReducer, useContext, useMemo } from "react";

const CartContext = createContext(null);

const initialState = {
  items: [],
  totalQuantity: 0,
};

const ACTIONS = {
  ADD_TO_CART: "ADD_TO_CART",
  REMOVE_FROM_CART: "REMOVE_FROM_CART",
  CLEAR_CART: "CLEAR_CART",
};

function cartReducer(state, action) {
  switch (action.type) {
    case ACTIONS.ADD_TO_CART: {
      const { product, quantity } = action.payload;
      const existingItemIndex = state.items.findIndex((item) => item._id === product._id);

      if (existingItemIndex !== -1) {
        const updatedItems = state.items.map((item, index) =>
          index === existingItemIndex ? { ...item, quantity: item.quantity + quantity } : item
        );
        return {
          ...state,
          items: updatedItems,
          totalQuantity: state.totalQuantity + quantity,
        };
      }

      return {
        ...state,
        items: [...state.items, { ...product, quantity }],
        totalQuantity: state.totalQuantity + quantity,
      };
    }

    case ACTIONS.REMOVE_FROM_CART: {
      const removedItem = state.items.find((item) => item._id === action.payload._id);
      if (!removedItem) return state; 

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

export function CartProvider({ children }) {
  const [cartState, dispatch] = useReducer(cartReducer, initialState);

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

  const removeFromCart = (product) =>
    dispatch({ type: ACTIONS.REMOVE_FROM_CART, payload: product });

  const clearCart = () => dispatch({ type: ACTIONS.CLEAR_CART });

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