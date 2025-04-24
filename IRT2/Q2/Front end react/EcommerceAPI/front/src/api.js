/* eslint-disable no-unused-vars */
import axios from "axios";


export const api = axios.create({
    baseURL: 'http://localhost:8080',
});

export function getProducts() {
    api.get('/products')
}

export function getCategories() {
    api.get('/categories')
}
