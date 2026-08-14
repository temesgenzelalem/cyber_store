# cyber — Premium AI-Powered E-Commerce Masterpiece

A high-end, full-stack mobile e-commerce solution built with **Flutter**, **Laravel**, and **PostgreSQL**. This app is designed for the Ethiopian market, featuring local payment integrations, Amharic language support, and cutting-edge AI capabilities.

---

## 🌟 Key Features

### 🛍️ Smart Shopping
- **AI Cyber Assistant**: A Gemini-powered chatbot that helps users find products and answers technical questions in fluent English or **Amharic**.
- **Visual Search**: Take a photo of a gadget, and the AI will identify it and find matching products in the store.
- **AR "View in Room"**: Visualize electronics (laptops, speakers, etc.) in your real room using Augmented Reality.
- **Advanced Search**: Intelligent multi-term search covering names, brands, and descriptions.

### 💰 Payments & Rewards
- **Chapa Integration**: Real Ethiopian payment gateway supporting **Telebirr**, **CBEBirr**, **M-Pesa**, and Cards.
- **Cyber Points (Loyalty)**: Earn points for every purchase and rank up (Silver, Gold, Elite) to unlock discounts and free shipping.
- **Referral System**: Invite friends and earn **Store Credit** in your digital wallet.
- **Coupon System**: Dynamic promo codes (e.g., `CYBER50`) for instant savings.

### 🛡️ Management & Analytics
- **Admin AI Suite**:
    - **Magic Fill**: Auto-populate product forms by pasting raw text or specs.
    - **AI Copywriter**: Generate professional descriptions with one click.
    - **Business Analyst**: Chat with an AI that analyzes your real sales data.
- **Order Management**: Complete workflow for tracking and updating customer orders.
- **Visual Analytics**: Interactive charts for revenue, orders, and customer growth.

### ✨ Premium UI/UX
- **5 Custom Themes**: Light, Dark, Midnight Blue, Forest Green, and Sunset Orange.
- **Animations**: Fluid Hero transitions, Lottie success animations, and skeleton loading (shimmers).
- **Glassmorphism**: Modern frosted glass effects on navigation bars.

---

## 🏗 Tech Stack

| Layer | Tech |
|---|---|
| **Frontend** | Flutter 3.x (Material 3) |
| **Backend** | Laravel 10.x |
| **Database** | PostgreSQL |
| **AI** | Google Gemini 1.5 Flash / Vision |
| **Payments** | Chapa (Ethiopia) |
| **Real-time** | Firebase Cloud Messaging (Push Notifications) |

---

## 🚀 Setup Guide

### 1 — Backend (Laravel)
1. `cd backend`
2. `composer install`
3. Configure `.env`:
   - Set PostgreSQL credentials.
   - Add `CHAPA_SECRET_KEY` & `CHAPA_PUBLIC_KEY`.
   - Add `GEMINI_API_KEY`.
4. `php artisan migrate --seed`
5. `php artisan serve --port=8000`

### 2 — Frontend (Flutter)
1. `cd cyber_store`
2. `flutter pub get`
3. Configure `lib/services/api_service.dart`:
   - Replace `YOUR_LOCAL_IP` with your computer's IP address for phone testing.
4. `flutter run`

---

## 👤 Developer
**Temesgen zelalem**
- 📞 Phone: 0932638178
- ✈️ Telegram: [@Temesgen3263](https://t.me/Temesgen3263)
