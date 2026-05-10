import { CartItemModel } from "../models/Carts/CartItemModel";

export class CartService {
  async getCartList(): Promise<CartItemModel[]> {

    return [];
  }
}

export const cartService = new CartService();