import React from 'react';
import ProductItem from './ProductItem';
import CartContext from '../Cart/CartContext';
import { BrowserRouter } from 'react-router-dom';
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';

describe('ProductItem', () => {
  let mockAddToCart;

  const baseProduct = {
    id: '1',
    name: 'Test Product',
    price: 29.99,
    image: 'image.jpg',
    quantity: 10,
    sold: 0,
    isOutOfStock: false,
  };

  const renderWithProviders = (product = baseProduct) =>
    render(
      <CartContext.Provider value={{ addToCart: mockAddToCart }}>
        <BrowserRouter>
          <ProductItem {...product} />
        </BrowserRouter>
      </CartContext.Provider>
    );

  beforeEach(() => {
    mockAddToCart = vi.fn();
  });

  it('affiche le nom, le prix et l’image', () => {
    renderWithProviders();
    expect(screen.getByText('Test Product')).toBeInTheDocument();
    expect(screen.getByText('29.99 €')).toBeInTheDocument();
    const img = screen.getByAltText('Test Product');
    expect(img.getAttribute('src')).toContain('image.jpg');
    expect(img).toHaveAttribute('alt', baseProduct.name);
  });

  it('affiche le bouton d\'ajout au panier', () => {
    renderWithProviders();
    expect(screen.getByRole('button', { name: /add/i })).toBeInTheDocument();
  });

  it('appelle addToCart quand on clique sur le bouton', () => {
    renderWithProviders();
    const button = screen.getByRole('button', { name: /add/i });
    fireEvent.click(button);
    expect(mockAddToCart).toHaveBeenCalled();
  });

  it('désactive le bouton si le produit est en rupture de stock', () => {
    const outOfStockProduct = { ...baseProduct, isOutOfStock: true };
    renderWithProviders(outOfStockProduct);
    const button = screen.getByRole('button', { name: /add/i });
    expect(button).toBeDisabled();
  });

  it('le champ quantité est désactivé si le produit est en rupture de stock', () => {
    const outOfStockProduct = { ...baseProduct, isOutOfStock: true };
    renderWithProviders(outOfStockProduct);
    const input = screen.getByLabelText(/quantité/i);
    expect(input).toBeDisabled();
  });

  it('le lien pointe vers la bonne page produit', () => {
    renderWithProviders();
    const link = screen.getByRole('link');
    expect(link).toHaveAttribute('href', '/product/1');
  });

  it('affiche correctement le prix même si c’est 0', () => {
    const freeProduct = { ...baseProduct, price: 0 };
    renderWithProviders(freeProduct);
    expect(screen.getByText('0 €')).toBeInTheDocument();
  });

  it('affiche une image même si le nom est vide', () => {
    const noNameProduct = { ...baseProduct, name: '' };
    renderWithProviders(noNameProduct);
    expect(screen.getByAltText('')).toBeInTheDocument();
  });

  it('supporte les props manquants sans planter', () => {
    const minimalProduct = { id: '2' };
    renderWithProviders(minimalProduct);
    expect(screen.getByRole('link')).toBeInTheDocument();
  });

  it('le champ quantité accepte la saisie', () => {
    renderWithProviders();
    const input = screen.getByLabelText(/quantité/i);
    fireEvent.change(input, { target: { value: '3' } });
    expect(input.value).toBe('3');
  });

  it('le bouton submit a la classe Bootstrap', () => {
    renderWithProviders();
    const button = screen.getByRole('button', { name: /add/i });
    expect(button).toHaveClass('btn');
    expect(button).toHaveClass('btn-primary');
  });

  it('l’image a bien le style imposé', () => {
    renderWithProviders();
    const img = screen.getByAltText('Test Product');
    expect(img).toHaveStyle({ width: '100%', height: '200px', objectFit: 'cover' });
  });

  it('n\'appelle pas addToCart si le bouton est désactivé', () => {
    const outOfStockProduct = { ...baseProduct, isOutOfStock: true };
    renderWithProviders(outOfStockProduct);
    const button = screen.getByRole('button', { name: /add/i });
    fireEvent.click(button);
    expect(mockAddToCart).not.toHaveBeenCalled();
  });
});