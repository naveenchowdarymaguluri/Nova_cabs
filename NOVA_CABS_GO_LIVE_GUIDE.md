# 🚖 Nova Cabs — Go-Live Guide
## Multi-Provider Architecture, Pricing Strategy & Production Readiness

> **Document Version:** 1.0  
> **Date:** 23 February 2026  
> **Author:** Engineering Team  
> **Status:** Planning & Analysis

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current Application State](#2-current-application-state)
3. [Multi-Provider Architecture](#3-multi-provider-architecture)
4. [Pricing Models & Strategy](#4-pricing-models--strategy)
5. [Recommended MVP Tech Stack — Providers & Pricing in Detail](#5-recommended-mvp-tech-stack--providers--pricing-in-detail)
   - 5.1 [Backend-as-a-Service (BaaS) & Cloud Hosting](#51-backend-as-a-service-baas--cloud-hosting) — Firebase, Supabase, Appwrite, AWS
   - 5.2 [Maps & Location Services](#52-maps--location-services-detailed) — Google Maps, Mappls, HERE, OSM
   - 5.3 [Payment Gateways](#53-payment-gateways-detailed) — Razorpay, Cashfree, PhonePe, PayU
   - 5.4 [SMS / OTP Providers](#54-sms--otp-providers-detailed) — Firebase Auth, MSG91, Twilio, 2Factor
   - 5.5 [WhatsApp Business API](#55-whatsapp-business-api-detailed) — Gupshup, Wati, Interakt, Meta Direct
   - 5.6 [Push Notifications](#56-push-notifications-detailed) — FCM, OneSignal
   - 5.7 [Analytics & Monitoring](#57-analytics-crash-reporting--monitoring-detailed) — Firebase, Mixpanel, Sentry
   - 5.8 [Domain, SSL & CDN](#58-domain-ssl--cdn)
   - 5.9 [App Store Accounts](#59-app-store--developer-accounts)
   - 5.10 [Consolidated Comparison](#510-consolidated-provider-comparison--all-services-at-a-glance)
   - 5.11 [Total Cost Projections](#511-total-cost-projection-by-stage)
6. [Backend Infrastructure Requirements](#6-backend-infrastructure-requirements)
7. [Payment Gateway Integration](#7-payment-gateway-integration)
8. [Security & Compliance](#8-security--compliance)
9. [Go-Live Checklist](#9-go-live-checklist)
10. [Phased Rollout Plan](#10-phased-rollout-plan)
11. [Estimated Monthly Operating Costs](#11-estimated-monthly-operating-costs)

---

## 1. Executive Summary

**Nova Cabs** is a Flutter-based cab aggregator application that connects customers with multiple travel agencies offering cabs across three vehicle categories (4-Seater, 7-Seater, 13-Seater). The app currently operates entirely on **mock/static data** with no backend, database, or payment integration.

This document outlines the complete roadmap to bring Nova Cabs to **production** with:
- ✅ Multi-provider (travel agency) support with individual pricing
- ✅ Real-time booking and payment processing
- ✅ Cloud-hosted backend infrastructure
- ✅ Third-party service integrations with cost breakdowns
- ✅ Compliance and security hardening

---

## 2. Current Application State

### 2.1 Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                 Flutter App (Frontend)           │
├─────────────────────────────────────────────────┤
│  Customer Module          │  Admin Module        │
│  ├─ Home Screen           │  ├─ Dashboard        │
│  ├─ Search / Cab Listing  │  ├─ Booking Mgmt     │
│  ├─ Trip Details          │  ├─ Travel Agencies   │
│  ├─ Payment Screen        │  ├─ Cab Management    │
│  ├─ Booking Confirmation  │  ├─ Pricing Mgmt     │
│  ├─ My Bookings           │  ├─ Customer Mgmt    │
│  ├─ Offers                │  ├─ Payments          │
│  ├─ Login / Sign-Up       │  ├─ Offers Mgmt      │
│  └─ Support               │  ├─ Notifications     │
│                           │  ├─ Reports/Analytics │
│                           │  ├─ Ratings/Feedback  │
│                           │  └─ System Config     │
├─────────────────────────────────────────────────┤
│  Core Layer                                      │
│  ├─ models.dart (6 models)                       │
│  ├─ mock_data.dart (static data)                 │
│  └─ app_theme.dart (Material 3 theme)            │
├─────────────────────────────────────────────────┤
│  State Management: flutter_riverpod              │
│  Backend: ❌ NONE (mock data only)               │
│  Database: ❌ NONE                                │
│  Auth: ❌ Mock only                               │
│  Payments: ❌ Simulated                           │
└─────────────────────────────────────────────────┘
```

### 2.2 Current Data Models

| Model | Fields | Status |
|-------|--------|--------|
| **Cab** | id, model, type, agencyName, imageUrl, rating, pricePerKm, estimatedArrival, vehicleNumber, fuelType, isAvailable | ⚠️ Needs provider relationship |
| **Booking** | id, pickup, drop, date, time, cab, totalDistance, totalFare, status, customerName, customerPhone, paymentMethod, paymentStatus | ⚠️ Needs backend persistence |
| **BookingOffer** | id, title, discount, validity, imageUrl, discountType, discountValue, applicableCabTypes, isActive | ⚠️ Static only |
| **TravelAgency** | id, name, contactPerson, mobile, whatsapp, email, address, gstNumber, bankDetails, isActive | ✅ Good base model |
| **Customer** | id, name, phone, email, totalBookings, totalSpent, isBlocked | ⚠️ Needs auth integration |
| **CustomerFeedback** | id, customerName, agencyName, cabModel, rating, comment, date, isFlagged | ⚠️ Needs backend persistence |

### 2.3 What's Missing for Production

| Component | Status | Priority |
|-----------|--------|----------|
| Backend API server | ❌ Missing | 🔴 Critical |
| Database (PostgreSQL / Firebase) | ❌ Missing | 🔴 Critical |
| User authentication (Firebase Auth / OTP) | ❌ Mock only | 🔴 Critical |
| Payment gateway (Razorpay / PhonePe) | ❌ Simulated | 🔴 Critical |
| Push notifications (FCM) | ❌ Missing | 🟡 High |
| WhatsApp Business API | ❌ Missing | 🟡 High |
| Maps / Distance calculation (Google Maps) | ❌ Hardcoded 25 KM | 🔴 Critical |
| Real-time cab tracking | ❌ Missing | 🟡 High |
| SMS OTP provider | ❌ Missing | 🔴 Critical |
| Cloud hosting | ❌ Missing | 🔴 Critical |
| App store deployment | ❌ Not deployed | 🟡 High |
| Analytics (Firebase / Mixpanel) | ❌ Missing | 🟢 Medium |

---

## 3. Multi-Provider Architecture

### 3.1 Provider (Travel Agency) Hierarchy

Nova Cabs acts as an **aggregator platform** connecting customers with multiple independent travel agencies. Each agency manages their own fleet, pricing, and drivers.

```
┌──────────────────────────────────────────────────┐
│                 NOVA CABS PLATFORM               │
│              (Aggregator / Marketplace)           │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌────────┐ │
│  │ Quick Travels │  │ Elite Cabs   │  │ City   │ │
│  │              │  │              │  │ Riders │ │
│  │ 4-Seat: ₹12  │  │ 4-Seat: ₹14  │  │ ₹13/km │ │
│  │ 7-Seat: ₹18  │  │ 7-Seat: ₹20  │  │ ₹19/km │ │
│  │ 13-Seat: ₹25 │  │ 13-Seat: ₹28 │  │ ₹26/km │ │
│  │              │  │              │  │        │ │
│  │ Fleet: 15    │  │ Fleet: 8     │  │ Fleet: │ │
│  │ Rating: 4.8  │  │ Rating: 4.5  │  │ 12     │ │
│  └──────────────┘  └──────────────┘  └────────┘ │
│                                                  │
│  ┌──────────────┐  ┌──────────────┐              │
│  │ Global       │  │ [Future      │              │
│  │ Travels      │  │  Provider]   │              │
│  │              │  │              │              │
│  │ 4-Seat: ₹11  │  │ Self-register│              │
│  │ 7-Seat: ₹17  │  │ via portal   │              │
│  │ 13-Seat: ₹24 │  │              │              │
│  └──────────────┘  └──────────────┘              │
└──────────────────────────────────────────────────┘
```

### 3.2 Enhanced Data Models for Multi-Provider

```dart
// ── ENHANCED MODELS FOR PRODUCTION ──

class TravelAgency {
  final String id;
  final String name;
  final String contactPerson;
  final String mobileNumber;
  final String whatsappNumber;
  final String email;
  final String address;
  final String gstNumber;
  final String panNumber;
  final String bankAccountNumber;
  final String bankIFSC;
  final String bankName;
  final String upiId;
  final String logoUrl;
  final double rating;
  final int totalTrips;
  final double commissionRate;      // Nova Cabs commission %
  final Map<String, double> pricing; // Per cab-type pricing
  final List<String> operatingCities;
  final bool isVerified;
  final bool isActive;
  final DateTime registeredAt;
  final SubscriptionPlan? subscription;
}

class ProviderPricing {
  final String agencyId;
  final String cabType;           // 4-Seater, 7-Seater, 13-Seater
  final double baseFarePerKm;
  final double minimumFare;       // Minimum booking charge
  final double nightSurcharge;    // % extra for night rides
  final double peakSurcharge;     // % extra for peak hours
  final double tollHandling;      // 'included' | 'extra'
  final double driverAllowance;
  final double waitingChargePerMin;
  final double cancellationFee;
  final bool isActive;
  final DateTime effectiveFrom;
}

class SubscriptionPlan {
  final String planId;
  final String planName;         // Basic, Premium, Enterprise
  final double monthlyFee;
  final double commissionRate;   // Lower commission for higher plans
  final int maxCabs;
  final bool priorityListing;
  final bool analyticsAccess;
  final bool dedicatedSupport;
}
```

### 3.3 Provider Onboarding Flow

```
1. Agency registers via Admin Portal / Self-Registration
        │
2. Submit documents (GST, PAN, Bank Details, Fleet Photos)
        │
3. Nova Cabs admin verifies documents
        │
4. Agency sets pricing per cab type
        │
5. Agency adds cabs with vehicle details + driver info
        │
6. Agency goes LIVE — their cabs appear in customer search
        │
7. Bookings flow to agency via WhatsApp + App notifications
        │
8. Settlements processed weekly/bi-weekly to agency bank
```

---

## 4. Pricing Models & Strategy

### 4.1 Revenue Models Comparison

| Model | Description | Nova Cabs Earning | Best For |
|-------|-------------|-------------------|----------|
| **Commission-Based** | Take 15–25% of each ride fare | ₹30–₹500+ per booking | High-volume cities |
| **Subscription-Based** | Agencies pay monthly fee (₹2,000–₹15,000) | Fixed monthly income | Predictable revenue |
| **Hybrid Model** ⭐ | Subscription + lower commission (5–10%) | Dual revenue stream | **Recommended** |
| **Zero Commission + Subscription** | No cut from rides, only fixed fee | Monthly fee only | Driver-friendly branding |

### 4.2 Recommended Hybrid Pricing Model

#### For Travel Agencies (Provider Plans)

| Plan | Monthly Fee | Commission | Max Cabs | Features |
|------|------------|------------|----------|----------|
| **Starter** | ₹2,999/mo | 20% | 5 cabs | Basic listing, standard support |
| **Growth** | ₹7,999/mo | 12% | 20 cabs | Priority listing, analytics dashboard |
| **Enterprise** | ₹14,999/mo | 5% | Unlimited | Top listing, dedicated support, API access |

#### For Customers (Fare Structure)

| Component | 4-Seater | 7-Seater | 13-Seater |
|-----------|----------|----------|-----------|
| **Base Fare (per KM)** | ₹11–14/km | ₹16–20/km | ₹23–28/km |
| **Minimum Fare** | ₹150 | ₹250 | ₹400 |
| **Waiting Charge** | ₹2/min | ₹3/min | ₹5/min |
| **Night Surcharge** (10PM–6AM) | +15% | +15% | +15% |
| **Peak Hours** (8–10AM, 5–8PM) | +10% | +10% | +10% |
| **Toll Charges** | At actuals | At actuals | At actuals |
| **Driver Allowance** (One-way 300+ KM) | ₹300 | ₹400 | ₹500 |
| **Cancellation Fee** | ₹50 | ₹100 | ₹150 |

### 4.3 Fare Calculation Formula

```
Total Fare = (Base Rate × Distance)
           + Minimum Fare (if applicable)
           + Night Surcharge (if applicable)
           + Peak Surcharge (if applicable)
           + Toll Charges
           + Driver Allowance (if applicable)
           + Waiting Charges (if applicable)
           - Discount / Offer (if applicable)
           + GST @ 5%
```

### 4.4 Sample Fare Comparison (Multi-Provider)

**Route:** Bangalore → Mysore (148 KM) | **Cab Type:** 7-Seater

| Provider | Base Rate | Total Fare | Rating | ETA |
|----------|-----------|------------|--------|-----|
| Quick Travels | ₹16/km | ₹2,661 | ⭐ 4.8 | 10 min |
| Elite Cabs | ₹20/km | ₹3,256 | ⭐ 4.5 | 15 min |
| City Riders | ₹18/km | ₹2,923 | ⭐ 4.7 | 8 min |
| Global Travels | ₹17/km | ₹2,788 | ⭐ 4.2 | 25 min |

> **Customer sees all providers sorted by price/rating/ETA and picks their preferred one.**

---

## 5. Recommended MVP Tech Stack — Providers & Pricing in Detail

> This section provides an **exhaustive**, category-by-category breakdown of every third-party service Nova Cabs needs, with **multiple providers compared**, granular per-unit pricing, free tier limits, and projected monthly costs at MVP / Growth / Scale stages.

---

### 5.1 Backend-as-a-Service (BaaS) & Cloud Hosting

#### 5.1.1 Firebase (Google) ⭐ RECOMMENDED FOR MVP

| Component | Free Tier (Spark/Blaze) | Paid Rate (Blaze – Pay-as-you-go) |
|-----------|------------------------|-----------------------------------|
| **Cloud Firestore** | | |
| › Document Reads | 50,000/day free | $0.18 per 100K reads |
| › Document Writes | 20,000/day free | $0.18 per 100K writes |
| › Document Deletes | 20,000/day free | $0.02 per 100K deletes |
| › Stored Data | 1 GiB free | $0.26/GiB/month |
| › Network Egress | 10 GiB/month free | Google Cloud rates after |
| **Cloud Functions** | | |
| › Invocations | 2M/month free | $0.40 per 1M invocations |
| › Compute (GB-sec) | 400K GB-sec free | $0.0000025/GB-sec |
| › Compute (CPU-sec) | 200K CPU-sec free | $0.00001/CPU-sec |
| › Outbound Networking | 5 GB/month free | $0.12/GB |
| **Firebase Auth** | | |
| › Email/Password | Unlimited free | Free |
| › Phone (OTP) – India | 10,000/month free | $0.01/verification after |
| › Google Sign-In | Unlimited free | Free |
| › Anonymous | Unlimited free | Free |
| **Cloud Storage** | | |
| › Storage | 5 GB free | $0.026/GB/month |
| › Downloads | 1 GB/day free | $0.12/GB |
| › Uploads | 50K ops/day free | $0.05/10K operations |
| **Firebase Hosting** | | |
| › Storage | 10 GB free | $0.026/GB |
| › Data Transfer | 360 MB/day free | $0.15/GB |
| **FCM (Push Notifications)** | **Unlimited — FREE** | **FREE** |
| **Firebase Analytics** | **Unlimited — FREE** | **FREE** |
| **Firebase Crashlytics** | **Unlimited — FREE** | **FREE** |

**💰 Nova Cabs Projected Firebase Cost:**

| Stage | Users | Reads/Day | Writes/Day | Functions/Mo | Auth OTPs/Mo | **Est. Monthly Cost** |
|-------|-------|-----------|------------|-------------|-------------|----------------------|
| **MVP** | 0–1,000 | ~10K | ~3K | ~500K | ~2K | **₹0–₹500** (within free tier) |
| **Growth** | 1K–10K | ~80K | ~20K | ~3M | ~15K | **₹2,000–₹6,000** |
| **Scale** | 10K–50K | ~400K | ~100K | ~15M | ~60K | **₹8,000–₹25,000** |

**New customer bonus:** $300 free credits on Blaze plan activation.

---

#### 5.1.2 Supabase

| Plan | Monthly Cost | Database | Storage | Bandwidth | MAUs | Auth | Support |
|------|-------------|----------|---------|-----------|------|------|---------|
| **Free** | **$0** | 500 MB PostgreSQL (shared CPU) | 1 GB | 5 GB | 50K | ✅ Built-in | Community |
| **Pro** | **$25/project** (~₹2,100) | 8 GB (dedicated CPU available) | 100 GB | 250 GB | 100K included | ✅ Built-in | Email |
| **Team** | **$599/mo** (~₹50,000) | All Pro features | All Pro features | All Pro features | All Pro features | SOC2 + SSO | Priority email + SLA |
| **Enterprise** | Custom | Custom | Custom | Custom | Custom | HIPAA available | Dedicated 24/7 |

**Overages (Pro plan):**

| Resource | Overage Cost |
|----------|-------------|
| Additional MAUs | $3.25 per 1,000 users |
| Database Storage | $0.125/GB (general purpose) |
| File Storage | $0.021/GB |
| Bandwidth | $0.09/GB |
| Dedicated CPU (Large) | +$100/month |

**Pros:** Open-source, PostgreSQL (SQL), real-time subscriptions, row-level security, Edge Functions.
**Cons:** Free plan pauses after 7 days inactivity; limited to 2 free projects.

---

#### 5.1.3 Appwrite

| Plan | Monthly Cost | Database | Storage | Bandwidth | MAUs | Functions |
|------|-------------|----------|---------|-----------|------|-----------|
| **Free** | **$0** | 1 DB, unlimited docs | 2 GB | 5 GB | 75K | 2 functions, 750K executions |
| **Pro** | **$25/project** (~₹2,100) | Unlimited DBs | 150 GB | 2 TB | 200K | Unlimited functions, 3.5M executions |
| **Scale** | **$599/mo** (~₹50,000) | Everything in Pro | Everything in Pro | 2 TB/project | Everything in Pro | Everything in Pro |

**Overages (Pro):**

| Resource | Cost |
|----------|------|
| Bandwidth | $15/100 GB |
| Storage | $2.80/100 GB |
| Executions | $1.50/1M |

**Pros:** Fully open-source, self-hostable (free unlimited), no vendor lock-in.
**Cons:** Cannot self-host on free; per-project pricing (Sep 2025+); smaller ecosystem than Firebase.

---

#### 5.1.4 AWS (Amplify + EC2 + RDS)

| Service | Pricing | Free Tier |
|---------|---------|-----------|
| **AWS Amplify Hosting** | $0.01/build minute + $0.15/GB served | 1,000 build min/mo + 15 GB/mo for 12 months |
| **EC2** (t3.micro) | ~$8.50/month (~₹710) | 750 hrs/month free for 12 months |
| **RDS** (db.t3.micro PostgreSQL) | ~$15/month (~₹1,250) | 750 hrs/month free for 12 months |
| **S3** (Storage) | $0.025/GB/month | 5 GB free for 12 months |
| **API Gateway** | $1/million requests | 1M requests/month free for 12 months |
| **Lambda** | $0.20/1M requests + compute | 1M requests/month free always |
| **Cognito** (Auth) | Free up to 50K MAUs | 50K MAUs free always |

**💰 Est. Cost:** ₹0 (12-month free tier) → ₹15,000–₹50,000/mo at scale.
**Pros:** Enterprise-grade, massive ecosystem, global infrastructure.
**Cons:** Most complex setup, steep learning curve, costs can spiral without monitoring.

---

#### 5.1.5 Other Providers (Quick Comparison)

| Provider | Starting Cost | Best For |
|----------|-------------|----------|
| **Railway** | $5/mo (~₹420) | Quick prototyping, Node.js/Python backends |
| **Render** | Free (static) / $7/mo (web service) | Simple Node.js API hosting |
| **DigitalOcean App Platform** | $5/mo (~₹420) droplet; $12/mo app platform | Budget VPS + managed DB |
| **Fly.io** | Free (3 shared VMs) / $1.94/mo per VM | Edge deployment, global low-latency |
| **PocketBase** | $0 (self-hosted, single Go binary) | Ultra-lightweight BaaS, open-source |

---

#### 5.1.6 BaaS Decision Matrix

| Criteria | Firebase ⭐ | Supabase | Appwrite | AWS |
|----------|-----------|----------|----------|-----|
| Setup Complexity | 🟢 Easy | 🟢 Easy | 🟡 Medium | 🔴 Complex |
| Free Tier Generosity | 🟢 Very generous | 🟡 Good (pauses) | 🟡 Good (2 projects) | 🟢 12 months free |
| Flutter Integration | 🟢 Official SDK | 🟡 Community SDK | 🟡 Community SDK | 🟡 Amplify Flutter |
| Real-time Support | 🟢 Firestore Streams | 🟢 Realtime subscriptions | 🟡 Realtime (limited) | 🟡 AppSync |
| SQL Support | 🔴 NoSQL only | 🟢 Full PostgreSQL | 🟡 Document-based | 🟢 RDS PostgreSQL |
| Auth (Phone OTP) | 🟢 Built-in, ₹0.01/OTP | 🟡 Via Twilio ($) | 🟡 Basic phone auth | 🟢 Cognito (50K free) |
| Vendor Lock-in | 🔴 High | 🟢 Low (open-source) | 🟢 Low (open-source) | 🟡 Medium |
| India Region | 🟢 Mumbai (asia-south1) | 🟢 Mumbai available | 🟡 Closest: Singapore | 🟢 Mumbai (ap-south-1) |
| **MVP Monthly Cost** | **₹0–₹500** | **₹0–₹2,100** | **₹0–₹2,100** | **₹0 (free tier)** |
| **Scale Monthly Cost** | **₹8K–₹25K** | **₹5K–₹50K** | **₹5K–₹50K** | **₹15K–₹50K** |

---

### 5.2 Maps & Location Services (Detailed)

#### 5.2.1 Google Maps Platform

**Pricing Model:** Pay-as-you-go with tiered free usage (effective March 2025).

| API / SKU | Tier | Free Allowance | Cost per 1,000 Requests |
|-----------|------|----------------|------------------------|
| **Maps SDK** (Mobile) | Essentials | 10,000/mo | $7.00 |
| **Directions API** (Legacy) | Essentials | 10,000/mo | $5.00 |
| **Directions API** (Advanced) | Pro | 5,000/mo | $10.00 |
| **Distance Matrix API** (Legacy) | Essentials | 10,000 elements/mo | $5.00 |
| **Distance Matrix API** (Advanced) | Pro | 5,000 elements/mo | $10.00 |
| **Geocoding API** | Essentials | 10,000/mo | $5.00 |
| **Places API** | Essentials | 10,000/mo | $5.00 |
| **Routes API** (Compute Routes) | Essentials | 10,000/mo | $5.00 |
| **Routes API** (Compute Routes) | Pro | 5,000/mo | $10.00 |

**Subscription Plans (alternative to pay-as-you-go):**

| Plan | Monthly Cost | Included Calls |
|------|-------------|---------------|
| **Starter** | ~$100/mo (~₹8,400) | 50,000 combined |
| **Essentials** | ~$275/mo (~₹23,000) | 100,000 combined |
| **Pro** | ~$1,200/mo (~₹1,00,800) | 250,000 combined |

**💰 Nova Cabs Projected Google Maps Cost:**

| Stage | Map Loads/Mo | Direction Requests/Mo | Distance Matrix/Mo | **Est. Monthly Cost** |
|-------|-------------|----------------------|--------------------|-----------------------|
| **MVP** | ~5K | ~2K | ~2K | **₹0** (within free tiers) |
| **Growth** | ~30K | ~15K | ~15K | **₹5,000–₹12,000** |
| **Scale** | ~150K | ~80K | ~80K | **₹25,000–₹60,000** |

---

#### 5.2.2 Mappls (MapmyIndia) ⭐ RECOMMENDED FOR MVP

**Pricing Model:** Free tier + paid plans for higher usage; India-optimized.

| Tier | Monthly Cost | API Calls Included | Features |
|------|-------------|-------------------|----------|
| **Free** | ₹0 | Limited (basic navigation, search) | Maps SDK, basic geocoding, no credit card required |
| **Starter** | ~₹25,000/mo (~$300) | 10,000 API calls | Maps, routing, geocoding, distance matrix |
| **Growth** | ~₹50,000/mo (~$605) | 50,000 API calls | All APIs + analytics |
| **Enterprise** | Custom | Custom | White-label, SLA-based support, dedicated infra |

**Annual Plans:**

| Plan | Annual Cost | API Calls/Year |
|------|-----------|---------------|
| **Starter** | ~₹2,75,000/year (~$3,273) | 10,000/mo |
| **Growth** | ~₹5,50,000/year (~$6,526) | 50,000/mo |

**Key APIs Available:**
- 🗺️ Maps (2D/3D with real-time traffic)
- 📍 Geocoding & Reverse Geocoding
- 🧭 Directions (shortest/fastest routes, avoid tolls/motorways)
- 📊 Distance Matrix (up to 10,000 origin-destination pairs)
- 🚗 Real-time Vehicle Tracking
- 📦 Fleet Telematics & Route Optimization

**Advantage:** Claims **~30% cheaper** than Google Maps for Indian geographies.

**💰 Nova Cabs Projected Mappls Cost:**

| Stage | API Calls/Mo | **Est. Monthly Cost** |
|-------|-------------|----------------------|
| **MVP** | ~5K | **₹0** (free tier) |
| **Growth** | ~20K | **₹25,000–₹35,000** |
| **Scale** | ~80K+ | **₹50,000+** (or custom enterprise) |

---

#### 5.2.3 Other Map Providers

| Provider | Free Tier | Paid Pricing | Best For |
|----------|-----------|-------------|----------|
| **HERE Maps** | 250K transactions/month free | Pay-as-you-go after | High free tier, good for MVP testing |
| **OpenStreetMap + OSRM** | Unlimited (self-hosted) | ₹0 + server cost (~₹2,000–₹5,000/mo) | Budget-conscious, tech-heavy teams |
| **Ola Maps** | 50K free calls/mo | Volume-based pricing | India-focused, ride-hailing optimized |
| **TomTom** | 2,500 free transactions/day | $0.42–$0.55/1000 requests | Accurate traffic data |

---

#### 5.2.4 Maps Decision Matrix

| Criteria | Google Maps ⭐ Scale | Mappls ⭐ MVP | HERE Maps | OpenStreetMap |
|----------|---------------------|--------------|-----------|---------------|
| India Accuracy | 🟢 Excellent | 🟢 Excellent (India-best) | 🟡 Good | 🟡 Variable |
| Flutter SDK | 🟢 Official `google_maps_flutter` | 🟡 Community | 🟡 Community | 🟡 `flutter_map` |
| Free Tier | 🟡 10K events/SKU/mo | 🟡 Basic only | 🟢 250K/month | 🟢 Unlimited |
| Real-time Traffic | 🟢 Yes | 🟢 Yes | 🟢 Yes | 🔴 No |
| Toll Calculation | 🟢 Yes | 🟢 Yes | 🟡 Limited | 🔴 No |
| Cost (MVP) | ₹0 | ₹0 | ₹0 | ₹0 + hosting |
| Cost (Scale) | ₹25K–₹60K/mo | ₹50K+/mo | ₹15K–₹30K/mo | ₹2K–₹5K/mo (hosting) |

---

### 5.3 Payment Gateways (Detailed)

#### 5.3.1 Razorpay ⭐ RECOMMENDED

| Fee Component | Cost | Notes |
|---------------|------|-------|
| **Setup Fee** | ₹0 | No setup or AMC |
| **UPI (Bank-to-Bank)** | 0% MDR + 2% platform fee + 18% GST | Gov mandates 0% MDR; Razorpay charges 2% platform fee |
| **UPI (RuPay Credit Card)** | 2.15% + 18% GST | Network MDR applies |
| **Credit/Debit Cards** | 2% + 18% GST | Visa, Mastercard, RuPay |
| **Net Banking** | 2% + 18% GST | 58+ banks supported |
| **Wallets (PayTM, etc.)** | 2% + 18% GST | — |
| **EMI / Pay Later** | 3% + 18% GST | Premium methods |
| **International Cards** | 3% + 18% GST | Optional +1% chargeback protection |
| **Razorpay Route (Split Payments)** | ₹0 extra | Built-in; auto-split to agency + Nova Cabs |
| **Razorpay Subscriptions** | ₹0 extra | For agency monthly plan billing |
| **Settlement** | T+2 business days | Funds to bank account |
| **Refunds** | Free processing | Amount reversal within days |

**Flutter Integration:** [`razorpay_flutter`](https://pub.dev/packages/razorpay_flutter) — official Dart package.

**💰 Nova Cabs Projected Razorpay Cost (assuming 80% UPI, 20% Cards):**

| Stage | Monthly Bookings | Avg. Fare | GMV | UPI Txns (80%) | Card Txns (20%) | **Platform Fee (Est.)** |
|-------|-----------------|-----------|-----|---------------|----------------|------------------------|
| **MVP** | 200 | ₹1,500 | ₹3,00,000 | ₹2,40,000 × 2% = ₹4,800 | ₹60,000 × 2% = ₹1,200 | **~₹6,000 + GST** |
| **Growth** | 1,500 | ₹1,500 | ₹22,50,000 | ₹18,00,000 × 2% = ₹36,000 | ₹4,50,000 × 2% = ₹9,000 | **~₹45,000 + GST** |
| **Scale** | 8,000 | ₹1,800 | ₹1,44,00,000 | ₹1,15,20,000 × 2% = ₹2,30,400 | ₹28,80,000 × 2% = ₹57,600 | **~₹2,88,000 + GST** |

> ⚠️ **Note:** These are fees Razorpay deducts from transactions, not out-of-pocket costs. The fees come from the booking amount before settlement.

---

#### 5.3.2 Cashfree Payments

| Fee Component | Cost | Notes |
|---------------|------|-------|
| **Setup Fee** | ₹0 | Free setup; premium support ₹4,999/year |
| **UPI & RuPay** | 0%–0.4% | Free or nominal based on agreement |
| **Credit/Debit Cards (Visa, MC)** | 1.90% | *Promo: 1.6% for new signups (till Mar 2026)* |
| **Net Banking** | 1.90% | 70+ partner banks |
| **Debit Card EMI** | 1.5% | HDFC, etc. |
| **Credit Card EMI** | 2.5% + TDR | Various banks |
| **Cardless EMI** | 1.9% | ICICI, Kotak, KreditBee, etc. |
| **Pay Later** | 2.2% | LazyPay, Simpl, etc. |
| **International Cards** | 2.99% (promo: 2.69%) | Available for new signups |
| **Diners/Amex** | 2.95% | — |
| **Easy Split (Multi-party)** | +0.2% on order value | Introductory pricing for split payouts |
| **Settlement** | T+0 / T+1 / T+2 | Flexible; T+0 same-day available |

**Key Advantage:** **T+0 same-day settlement** (RBI-compliant) — agencies get paid faster.
**Split Payments:** "Easy Split" feature for marketplace commission deduction — but costs extra 0.2%.

---

#### 5.3.3 PhonePe Payment Gateway

| Fee Component | Cost | Notes |
|---------------|------|-------|
| **Setup Fee** | ₹0 | Limited-period free onboarding for SMBs |
| **UPI (Bank-to-Bank)** | 0% MDR | Government mandate; zero charges |
| **UPI via PPI (>₹2,000)** | 0.5%–1.1% interchange | Varies by category; paid by merchant |
| **Debit Card (<₹2,000)** | 0.40% | Government-set rate |
| **Credit/Debit Card** | ~2% | Standard gateway fee |
| **Settlement** | T+1 business days | Faster than Razorpay (T+2) |

**Key Advantage:** **T+1 settlement** + largest UPI user base in India (48%+ market share).
**Limitation:** No built-in split payment route like Razorpay; less startup-friendly dashboard.

---

#### 5.3.4 PayU India

| Fee Component | Cost |
|---------------|------|
| **Setup Fee** | ₹0 |
| **UPI** | 0% MDR + platform fee (~1.5–2%) |
| **Cards / Net Banking** | 2% |
| **EMI** | 2.5%–3% |
| **International** | 3.5% |
| **Settlement** | T+2 days |

---

#### 5.3.5 Payment Gateway Decision Matrix

| Criteria | Razorpay ⭐ | Cashfree | PhonePe PG | PayU |
|----------|-----------|----------|-----------|------|
| **Domestic Fee** | 2% | 1.90% (promo: 1.6%) | ~2% | 2% |
| **UPI Cost** | 2% platform fee | 0%–0.4% | 0% | ~1.5–2% |
| **Settlement** | T+2 | **T+0 / T+1** | **T+1** | T+2 |
| **Split Payments** | 🟢 Route (free) | 🟡 Easy Split (+0.2%) | 🔴 Manual | 🟡 Available |
| **Subscription Billing** | 🟢 Built-in | 🟡 Available | 🔴 No | 🟡 Available |
| **Flutter SDK** | 🟢 `razorpay_flutter` | 🟡 `cashfree_pg` | 🟡 Limited | 🟡 `payu_checkoutpro` |
| **Dashboard Quality** | 🟢 Excellent | 🟢 Good | 🟡 Basic | 🟡 Good |
| **Refunds** | 🟢 Free, easy | 🟢 Free, easy | 🟡 Manual | 🟡 Available |
| **India Market Share** | 🟢 #1 PG | 🟢 #2 PG | 🟢 #1 UPI app | 🟡 Established |
| **Best For Nova Cabs** | **MVP + Scale** | **If T+0 settlement needed** | **If UPI-only focus** | **Enterprise backup** |

---

### 5.4 SMS / OTP Providers (Detailed)

#### 5.4.1 Firebase Authentication (Phone) ⭐ RECOMMENDED

| Item | Detail |
|------|--------|
| **Free Tier** | 10,000 phone verifications/month (India) |
| **After Free Tier** | $0.01/verification (~₹0.84) for India |
| **Supported Methods** | SMS OTP (automatic), reCAPTCHA verification |
| **Flutter Package** | `firebase_auth` (official) |
| **Pros** | Zero setup for OTP; auto-reads SMS on Android; integrates with Firestore |
| **Cons** | No WhatsApp OTP fallback; 10K/month limit may hit at scale |

**💰 Nova Cabs Projected Cost:**

| Stage | OTP Verifications/Mo | **Est. Cost** |
|-------|---------------------|--------------|
| **MVP** | ~2,000 | **₹0** (within free tier) |
| **Growth** | ~15,000 | **₹42** ($0.01 × 5,000 overage) |
| **Scale** | ~60,000 | **₹420** ($0.01 × 50,000 overage) |

---

#### 5.4.2 MSG91

| Volume (₹ spent) | Per SMS Cost | Notes |
|-------------------|-------------|-------|
| Up to ₹3,999 | ₹0.25/SMS | 5,000 SMS minimum |
| ₹4,000–₹7,999 | ₹0.21/SMS | — |
| ₹8,000–₹13,999 | ₹0.19/SMS | — |
| ₹14,000–₹59,999 | ₹0.17/SMS | — |
| ₹60,000–₹1,29,999 | ₹0.15/SMS | — |
| ₹1,30,000–₹5,99,999 | ₹0.13/SMS | — |
| ₹6,00,000+ | ₹0.11/SMS | Enterprise rate |

- All prices **+ 18% GST**
- **OTP Widget:** Free (charges only for sent messages)
- **Channels:** SMS, Voice, Email, WhatsApp
- **DND Numbers:** Charged on both promo & transactional routes

---

#### 5.4.3 Other SMS Providers

| Provider | Per SMS (India) | Free Tier | OTP Support | Notes |
|----------|----------------|-----------|-------------|-------|
| **Twilio** | ~₹0.20/SMS ($0.0075 + carrier fee) | $15.50 trial credit | Verify API | Global; expensive for India-only |
| **2Factor.in** | ₹0.09–₹0.12/SMS | — | Dedicated OTP API | India-only, very affordable |
| **TextLocal** | ₹0.10–₹0.15/SMS | 10 free SMS | OTP API | Good dashboard, India-focused |
| **Fast2SMS** | ₹0.10–₹0.20/SMS | — | Quick OTP | Budget option |

---

### 5.5 WhatsApp Business API (Detailed)

> **Important:** From July 1, 2025, Meta has shifted from conversation-based to **per-message billing** for all WhatsApp Business API messages.

#### 5.5.1 WhatsApp Message Types & Meta Base Costs (India)

| Message Category | Meta Base Cost (India) | When Used in Nova Cabs |
|------------------|----------------------|----------------------|
| **Marketing** | ~₹0.78–₹0.89/message | Promotional offers, new cab type announcements |
| **Utility** | ~₹0.12–₹0.13/message | Booking confirmations, trip updates, payment receipts |
| **Authentication** | ~₹0.13–₹0.16/message | OTP verification via WhatsApp |
| **Service** (customer-initiated, within 24hr) | **Free** (no Meta charge) | Customer support replies |

> Nova Cabs will primarily use **Utility** messages (booking confirmations, driver details, trip status) which are the cheapest at ~₹0.13/message.

---

#### 5.5.2 Gupshup ⭐ RECOMMENDED

| Item | Detail |
|------|--------|
| **Platform Fee** | ~$0.001/message (~₹0.08) on top of Meta rate |
| **Marketing Message** | ~₹0.87–₹0.97/message (Meta + Gupshup) |
| **Utility Message** | ~₹0.13–₹0.21/message (Meta + Gupshup) |
| **Authentication Message** | ~₹0.14–₹0.24/message (Meta + Gupshup) |
| **Monthly Subscription** | ₹0 (no platform fee for API access) |
| **Chatbot Builder** | Included |
| **Template Approval** | Managed by Gupshup |
| **India Focus** | 🟢 Yes, headquarters in India |
| **API Integration** | REST API + SDKs |

**💰 Nova Cabs Projected Gupshup Cost (Utility messages primarily):**

| Stage | Bookings/Mo | Messages/Booking | Total Messages | **Est. Cost** (₹0.20/msg avg.) |
|-------|------------|-----------------|---------------|--------------------------------|
| **MVP** | 200 | 3 (confirm + driver + complete) | 600 | **₹120/mo** |
| **Growth** | 1,500 | 3 | 4,500 | **₹900/mo** |
| **Scale** | 8,000 | 4 (+ marketing) | 32,000 | **₹6,400/mo** |

---

#### 5.5.3 Wati

| Plan | Monthly Cost | Users Included | Extra Users | Key Features |
|------|-------------|---------------|-------------|-------------|
| **Pay-as-you-Go** | ₹999 one-time | 1 | — | Credits-based, light broadcast |
| **Growth** | ₹1,999–₹2,499/mo | 3–5 | ₹699/user/mo | Team inbox, broadcasts (15K), basic automation, 24×5 email support |
| **Pro** | ₹4,499–₹5,999/mo | 5 | ₹1,299/user/mo | Advanced chatbots, forms, integrations, webhooks, 24×7 support |
| **Business** | ₹13,499–₹16,999/mo | 5 | ₹3,999/user/mo | Round-robin, multiple numbers, IP whitelist, priority support |

**Per-Message Costs (in addition to subscription):**

| Category | Cost |
|----------|------|
| Marketing | ~₹0.94/message |
| Utility | ~₹0.14/message |
| Service | ~₹0.14/message |

**Pros:** Beautiful dashboard UI, team inbox for customer support, Shopify integration.
**Cons:** Expensive at scale; per-user pricing adds up.

---

#### 5.5.4 Interakt

| Plan | Monthly Cost | Key Features |
|------|-------------|-------------|
| **Starter** | ₹2,757/quarter (~₹919/mo) | Shared inbox, unlimited members, catalog, bulk notifications |
| **Growth** | ₹2,499/mo | Click-to-WA ads analytics, advanced automation, 3 app integrations |
| **Advanced** | ₹3,499/mo | Unlimited integrations, developer API, 600 API calls/min |
| **Enterprise** | Custom | Custom volumes, dedicated support |

**Per-Message Costs (Starter plan):**

| Category | Cost |
|----------|------|
| Marketing | ~₹0.88/message |
| Utility | ~₹0.16/message |
| Authentication | ~₹0.13/message |

**Pros:** Affordable entry point; 1,000 free conversations/month; unlimited team members.
**Cons:** Advanced features gated to higher plans; smaller community.

---

#### 5.5.5 WhatsApp Provider Decision Matrix

| Criteria | Gupshup ⭐ | Wati | Interakt | Twilio | Meta Direct |
|----------|-----------|------|----------|--------|-------------|
| **Monthly Base Fee** | ₹0 | ₹1,999–₹16,999 | ₹919–₹3,499 | ₹0 | ₹0 |
| **Utility Msg Cost** | ~₹0.20 | ~₹0.14 | ~₹0.16 | ~₹0.60 | ~₹0.13 |
| **Dashboard UI** | 🟡 Basic | 🟢 Excellent | 🟢 Good | 🟡 Developer-focused | 🔴 API only |
| **Team Inbox** | 🟡 Basic | 🟢 Full-featured | 🟢 Good | 🔴 No | 🔴 No |
| **API Quality** | 🟢 RESTful | 🟢 RESTful | 🟡 Good | 🟢 Excellent | 🟢 Official |
| **Chatbot Builder** | 🟢 Included | 🟢 Included (Pro+) | 🟡 Basic | 🔴 Build yourself | 🔴 Build yourself |
| **Setup Complexity** | 🟢 Easy | 🟢 Easy | 🟢 Easy | 🟡 Medium | 🔴 Complex |
| **India Support** | 🟢 HQ in India | 🟡 Global | 🟢 India-focused | 🟡 Global | 🟡 Global |
| **Best For** | **API-first, budget MVP** | **Team with support agents** | **SMBs, affordable entry** | **Global multi-channel** | **Max cost savings (dev effort)** |

---

### 5.6 Push Notifications (Detailed)

#### 5.6.1 Firebase Cloud Messaging (FCM) ⭐ RECOMMENDED

| Feature | Detail |
|---------|--------|
| **Cost** | **Completely FREE** — unlimited messages, unlimited devices |
| **Platforms** | Android, iOS, Web |
| **Flutter Package** | `firebase_messaging` (official) |
| **Topic Messaging** | Send to device groups (e.g., all Bangalore users) |
| **Data Messages** | Custom payload for in-app handling |
| **Delivery Reports** | Via Firebase Console |
| **Scheduling** | Yes, from Firebase Console |
| **Rich Notifications** | Images, action buttons, deep links |
| **Limitation** | No built-in analytics for open rates (use Firebase Analytics) |

#### 5.6.2 OneSignal

| Plan | Cost | Subscribers | Features |
|------|------|------------|----------|
| **Free** | $0 | 10,000 | Basic push, email, in-app messaging |
| **Growth** | $9/mo (~₹750) | 10,000 | Advanced analytics, A/B testing, Journeys |
| **Professional** | $99/mo (~₹8,300) | Custom | Segments, throttling, API access |

**Pros:** Cross-platform (Android + iOS + Web), good analytics, A/B testing.
**Cons:** Costs money at scale; FCM is sufficient for Nova Cabs.

#### ⭐ Verdict: **FCM — Free, native, and sufficient.** No reason to pay for push notifications.

---

### 5.7 Analytics, Crash Reporting & Monitoring (Detailed)

#### 5.7.1 Firebase Analytics + Crashlytics ⭐ RECOMMENDED

| Service | Cost | Features |
|---------|------|----------|
| **Firebase Analytics** | **FREE** (unlimited) | Screen tracking, custom events, user properties, funnels, cohorts, audiences, BigQuery export |
| **Firebase Crashlytics** | **FREE** (unlimited) | Real-time crash reports, stack traces, affected users count, breadcrumbs, non-fatal error logging |
| **Firebase Performance** | **FREE** | Network request latency, app startup time, screen rendering |
| **Firebase Remote Config** | **FREE** | A/B testing, feature flags without app update |

**Flutter Packages:** `firebase_analytics`, `firebase_crashlytics`, `firebase_performance`

#### 5.7.2 Other Analytics Tools

| Provider | Free Tier | Paid Pricing | Best For |
|----------|-----------|-------------|----------|
| **Mixpanel** | 20M events/month | $20/mo for more features | Advanced product analytics, funnels |
| **Amplitude** | 10M events/month | Custom pricing | Enterprise product analytics |
| **PostHog** | 1M events/month (cloud) | Self-host: free | Open-source, session recordings |
| **Sentry** | 5K errors/month | $26/mo (~₹2,200) | Error tracking with context |
| **Datadog** | 5 hosts free | $15/host/month | Infrastructure monitoring |

#### ⭐ Verdict: **Firebase Analytics + Crashlytics — Free, native, zero-config.** Add Mixpanel later for advanced product analytics if needed.

---

### 5.8 Domain, SSL & CDN

| Service | Provider | Cost |
|---------|----------|------|
| **Domain (.com)** | GoDaddy / Namecheap / Google Domains | ₹600–₹1,200/year |
| **Domain (.in)** | BigRock / GoDaddy | ₹350–₹700/year |
| **SSL Certificate** | Let's Encrypt (via hosting) | **FREE** |
| **CDN** | Cloudflare (Free plan) | **FREE** (unlimited bandwidth) |
| **CDN** | Firebase Hosting (built-in) | Included in Firebase |

#### ⭐ Verdict: **~₹800/year for domain + Free SSL via Let's Encrypt + Free CDN via Cloudflare**

---

### 5.9 App Store & Developer Accounts

| Platform | Fee Type | Cost | Notes |
|----------|---------|------|-------|
| **Google Play Store** | One-time registration | **₹2,100** (~$25) | Lifetime access; publish unlimited apps |
| **Apple App Store** | Annual membership | **₹8,299/year** (~$99/year) | Required for iOS distribution; renew annually |
| **Apple (Enterprise)** | Annual membership | **₹25,500/year** (~$299/year) | Only needed for internal distribution |

---

### 5.10 Consolidated Provider Comparison — All Services at a Glance

| Service Category | Provider ⭐ Recommended | Alternative 1 | Alternative 2 | Alternative 3 |
|-----------------|----------------------|---------------|---------------|---------------|
| **Backend + DB** | Firebase (₹0–₹500 MVP) | Supabase ($25/mo) | Appwrite ($25/mo) | AWS (free 12mo) |
| **Auth (Phone OTP)** | Firebase Auth (10K free) | MSG91 (₹0.25/SMS) | 2Factor (₹0.09/SMS) | Twilio ($0.0075/SMS) |
| **Maps & Routing** | Mappls (₹0 MVP) | Google Maps ($5/1K req) | HERE Maps (250K free) | OpenStreetMap (free) |
| **Payment Gateway** | Razorpay (2% + Route) | Cashfree (1.9% + T+0) | PhonePe PG (T+1) | PayU (2%) |
| **WhatsApp API** | Gupshup (₹0.20/msg) | Interakt (₹919/mo) | Wati (₹1,999/mo) | Meta Direct (₹0.13/msg) |
| **Push Notifications** | FCM (**FREE**) | OneSignal (free 10K) | — | — |
| **Analytics** | Firebase Analytics (**FREE**) | Mixpanel (20M free) | PostHog (1M free) | — |
| **Crash Reports** | Firebase Crashlytics (**FREE**) | Sentry (5K free) | — | — |
| **Domain + SSL** | Namecheap + Let's Encrypt (~₹800/yr) | GoDaddy (~₹1,200/yr) | — | — |
| **CDN** | Cloudflare (**FREE**) | Firebase Hosting | — | — |
| **Play Store** | Google Play (₹2,100 one-time) | — | — | — |
| **App Store** | Apple Dev Program (₹8,299/yr) | — | — | — |

---

### 5.11 Total Cost Projection by Stage

#### 💰 MVP Stage (0–1,000 users, 200 bookings/month)

| Service | Provider | Monthly Cost |
|---------|----------|-------------|
| Backend + Database | Firebase (Blaze) | ₹0–₹500 |
| Authentication | Firebase Auth (Phone) | ₹0 (within free tier) |
| Maps & Routing | Mappls (free tier) or Google Maps (free tier) | ₹0 |
| Payment Gateway | Razorpay (deducted from GMV) | ~₹6,000 (from transactions) |
| WhatsApp API | Gupshup (600 messages × ₹0.20) | ₹120 |
| Push Notifications | FCM | ₹0 |
| Analytics + Crashes | Firebase Analytics + Crashlytics | ₹0 |
| Domain + SSL | Namecheap + Let's Encrypt | ₹70 (~₹800/year) |
| CDN | Cloudflare (Free) | ₹0 |
| **Total MVP (out-of-pocket)** | | **₹190–₹690/mo** |
| **Total (including PG fees from GMV)** | | **₹6,190–₹6,690/mo** |

#### 💰 Growth Stage (1,000–10,000 users, 1,500 bookings/month)

| Service | Provider | Monthly Cost |
|---------|----------|-------------|
| Backend + Database | Firebase (Blaze) or Supabase (Pro) | ₹2,000–₹6,000 |
| Authentication | Firebase Auth | ₹42 (5K overage) |
| Maps & Routing | Google Maps Platform | ₹5,000–₹12,000 |
| Payment Gateway | Razorpay (from GMV) | ~₹45,000 |
| WhatsApp API | Gupshup (4,500 messages) | ₹900 |
| Push Notifications | FCM | ₹0 |
| Analytics | Firebase + Mixpanel | ₹0 |
| Domain + SSL + CDN | Namecheap + Cloudflare | ₹70 |
| **Total (out-of-pocket)** | | **₹8,012–₹19,012/mo** |
| **Total (including PG fees from GMV)** | | **₹53,012–₹64,012/mo** |

#### 💰 Scale Stage (10,000+ users, 8,000 bookings/month)

| Service | Provider | Monthly Cost |
|---------|----------|-------------|
| Backend | Firebase (Blaze) or GCP Custom | ₹8,000–₹25,000 |
| Authentication | Firebase Auth | ₹420 |
| Maps & Routing | Google Maps Platform | ₹25,000–₹60,000 |
| Payment Gateway | Razorpay (from GMV) | ~₹2,88,000 |
| WhatsApp API | Gupshup | ₹6,400 |
| Push Notifications | FCM | ₹0 |
| Analytics + Monitoring | Firebase + Mixpanel + Sentry | ₹0–₹2,200 |
| Domain + SSL + CDN | Namecheap + Cloudflare | ₹70 |
| **Total (out-of-pocket)** | | **₹39,890–₹94,090/mo** |
| **Total (including PG fees from GMV)** | | **₹3,27,890–₹3,82,090/mo** |

---

## 6. Backend Infrastructure Requirements

### 6.1 Recommended Backend Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                                 │
│                  (Android + iOS + Web)                              │
└──────────────┬────────────────────────────┬────────────────────────┘
               │ REST API / Firestore SDK   │ WebSocket (Real-time)
               ▼                            ▼
┌──────────────────────────────────────────────────────────────────┐
│                     BACKEND LAYER                                 │
│                                                                   │
│  Option A: Firebase (Recommended for MVP)                         │
│  ┌─────────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Cloud Functions  │  │ Firestore    │  │ Firebase Auth        │ │
│  │ (Node.js/Python) │  │ (NoSQL DB)   │  │ (Phone OTP + Google) │ │
│  └─────────────────┘  └──────────────┘  └──────────────────────┘ │
│  ┌─────────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Cloud Storage    │  │ FCM          │  │ Firebase Hosting     │ │
│  │ (Images/Docs)    │  │ (Push Notif) │  │ (Admin Web Panel)    │ │
│  └─────────────────┘  └──────────────┘  └──────────────────────┘ │
│                                                                   │
│  Option B: Custom Backend (For Scale)                             │
│  ┌─────────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Node.js / Python │  │ PostgreSQL   │  │ Redis (Caching)      │ │
│  │ (Express/FastAPI)│  │ (via Supabase│  │                      │ │
│  │ on Cloud Run     │  │  or RDS)     │  │                      │ │
│  └─────────────────┘  └──────────────┘  └──────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
               │                            │
               ▼                            ▼
┌──────────────────────┐   ┌────────────────────────────────────────┐
│  THIRD-PARTY APIs    │   │  EXTERNAL SERVICES                     │
│                      │   │                                        │
│  • Razorpay (Pay)    │   │  • WhatsApp Business API (Gupshup)    │
│  • Google Maps /     │   │  • SMS OTP (Firebase Auth / MSG91)    │
│    Mappls (Maps)     │   │  • Firebase Analytics + Crashlytics   │
│  • FCM (Notifs)      │   │  • Play Store / App Store Connect     │
└──────────────────────┘   └────────────────────────────────────────┘
```

### 6.2 API Endpoints Required

| Category | Endpoint | Method | Description |
|----------|----------|--------|-------------|
| **Auth** | `/auth/send-otp` | POST | Send OTP to phone |
| | `/auth/verify-otp` | POST | Verify OTP and get token |
| | `/auth/google` | POST | Google sign-in |
| **Agencies** | `/agencies` | GET | List all active agencies |
| | `/agencies/:id` | GET | Agency details + pricing |
| | `/agencies` | POST | Register new agency |
| | `/agencies/:id/pricing` | PUT | Update agency pricing |
| | `/agencies/:id/cabs` | GET | List agency's cabs |
| **Cabs** | `/cabs/search` | POST | Search available cabs by route + type |
| | `/cabs/:id` | GET | Cab details |
| | `/cabs/compare` | POST | Compare prices across providers |
| **Bookings** | `/bookings` | POST | Create new booking |
| | `/bookings/:id` | GET | Booking details |
| | `/bookings/:id/status` | PUT | Update booking status |
| | `/bookings/history` | GET | Customer booking history |
| **Fare** | `/fare/estimate` | POST | Calculate fare estimate |
| | `/fare/breakdown` | POST | Detailed fare breakdown |
| **Payments** | `/payments/initiate` | POST | Create Razorpay order |
| | `/payments/verify` | POST | Verify payment signature |
| | `/payments/refund` | POST | Process refund |
| **Offers** | `/offers` | GET | List active offers |
| | `/offers/apply` | POST | Apply coupon code |
| **Admin** | `/admin/dashboard` | GET | Dashboard stats |
| | `/admin/settlements` | GET | Agency settlement reports |
| | `/admin/settlements/:id/process` | POST | Process agency payout |

---

## 7. Payment Gateway Integration

### 7.1 Multi-Party Settlement Flow

```
Customer pays ₹2,000 for a ride
         │
         ▼
┌────────────────────────┐
│     RAZORPAY            │
│     (Payment Gateway)   │
│                         │
│  Total: ₹2,000          │
│  - Razorpay fee: ₹40    │
│    (2% on card/netbank) │
│                         │
│  Net: ₹1,960            │
│  ┌─────────────────┐    │
│  │ Split via Route: │    │
│  │                  │    │
│  │ Agency: ₹1,764   │    │
│  │ (90% of net)     │    │
│  │                  │    │
│  │ Nova Cabs: ₹196  │    │
│  │ (10% commission)  │    │
│  └─────────────────┘    │
└────────────────────────┘
         │
         ▼
  Settled to respective bank accounts
  every T+2 business days
```

### 7.2 Razorpay Flutter Integration Cost

| Item | Cost |
|------|------|
| Setup fee | ₹0 |
| UPI payments | ₹0 (free) |
| Credit/Debit card | 2% per transaction |
| Net banking | 2% per transaction |
| Wallet (PayTM, etc.) | 2% per transaction |
| Subscription billing (for agencies) | ₹0 (built into Razorpay) |
| Route (split payments) | ₹0 (built into Razorpay) |
| **Average blended rate** | **~1% (80% UPI India)** |

---

## 8. Security & Compliance

### 8.1 Regulatory Requirements

| Requirement | Details | Status |
|-------------|---------|--------|
| **GST Registration** | Required for platform & each agency | 📋 Pending |
| **Payment Aggregator License** (RBI) | Required if handling > ₹1 Cr annually | 📋 Evaluate |
| **Terms of Service** | Legal T&C for customers and agencies | ❌ Required |
| **Privacy Policy** | GDPR/India IT Act compliant | ❌ Required |
| **Data Encryption** | TLS 1.2+ for all API communication | ❌ Required |
| **PCI-DSS Compliance** | Handled by Razorpay (no card data on Nova Cabs servers) | ✅ Via Razorpay |
| **Play Store / App Store Compliance** | Privacy policy, data handling declaration | ❌ Required |

### 8.2 Security Checklist

- [ ] Firebase Security Rules (Firestore, Storage)
- [ ] API authentication via JWT tokens
- [ ] Rate limiting on auth endpoints
- [ ] Input validation on all customer-facing forms
- [ ] Admin role-based access control (RBAC)
- [ ] SSL/TLS for all API endpoints
- [ ] Secure storage of API keys (no hardcoding)
- [ ] ProGuard/R8 obfuscation for release APK
- [ ] Certificate pinning for API calls

---

## 9. Go-Live Checklist

### 9.1 Technical Checklist

- [ ] Backend API deployed and tested
- [ ] Database schema finalized and migrated
- [ ] Firebase Auth (Phone + Google) integrated
- [ ] Razorpay payment flow tested (test mode → live mode)
- [ ] Google Maps / Mappls distance calculation working
- [ ] WhatsApp notification templates approved by Meta
- [ ] FCM push notifications working (Android + iOS)
- [ ] Multi-provider cab search with price comparison
- [ ] Fare calculation engine with all surcharges
- [ ] Booking lifecycle (create → confirm → complete → rate)
- [ ] Agency settlement system tested
- [ ] Admin dashboard connected to live data
- [ ] App performance tested (load testing)
- [ ] Crash-free rate > 99.5% verified
- [ ] All hardcoded mock data removed

### 9.2 Business Checklist

- [ ] Minimum 3 travel agencies onboarded
- [ ] Minimum 15 cabs listed across all types
- [ ] Pricing verified and approved by each agency
- [ ] T&C and Privacy Policy published
- [ ] Customer support WhatsApp number active
- [ ] Agency onboarding documentation ready
- [ ] Razorpay account verified (live mode activated)
- [ ] Google Maps / Mappls billing account set up
- [ ] Play Store developer account (₹2,100 one-time)
- [ ] Apple Developer account ($99/year = ~₹8,300/year) — if iOS

### 9.3 App Store Deployment

| Platform | Fee | Requirements |
|----------|-----|-------------|
| **Google Play Store** | ₹2,100 (one-time) | Signed APK/AAB, privacy policy, content rating |
| **Apple App Store** | ₹8,300/year | Apple Developer Program, signed IPA, App Review |

---

## 10. Phased Rollout Plan

### Phase 1: Foundation (Weeks 1–4) 🔴
> **Goal:** Backend + Auth + Core booking flow

| Task | Duration | Cost |
|------|----------|------|
| Set up Firebase project (Firestore + Auth + Functions) | 3 days | ₹0 |
| Design and implement database schema | 5 days | Dev time |
| Implement Firebase Auth (Phone OTP + Google) | 3 days | ₹0 |
| Build REST API / Cloud Functions for core endpoints | 10 days | Dev time |
| Connect Flutter app to live backend (replace mock data) | 7 days | Dev time |
| Integrate Mappls / Google Maps for distance calculation | 3 days | ₹0 (free tier) |

### Phase 2: Payments + Multi-Provider (Weeks 5–7) 🟡
> **Goal:** Live payments, multi-provider pricing, agency onboarding

| Task | Duration | Cost |
|------|----------|------|
| Integrate Razorpay (payment flow + split payments) | 5 days | ₹0 setup |
| Build agency self-registration portal | 5 days | Dev time |
| Implement per-provider pricing engine | 4 days | Dev time |
| Build fare comparison UI (sort by price/rating/ETA) | 3 days | Dev time |
| Agency settlement and payout system | 4 days | Dev time |
| Onboard first 3 agencies with real data | 3 days | Business ops |

### Phase 3: Notifications + Polish (Weeks 8–9) 🟢
> **Goal:** WhatsApp notifications, push notifications, final polish

| Task | Duration | Cost |
|------|----------|------|
| Set up FCM push notifications | 2 days | ₹0 |
| Integrate WhatsApp Business API (booking confirmations) | 4 days | ₹999–₹2,499/mo |
| Implement booking status updates (real-time) | 3 days | Dev time |
| Performance optimization & bug fixing | 4 days | Dev time |
| Security audit and hardening | 2 days | Dev time |

### Phase 4: Launch (Week 10) 🚀
> **Goal:** App store deployment, soft launch

| Task | Duration | Cost |
|------|----------|------|
| Generate signed release APK/AAB | 1 day | Dev time |
| Submit to Google Play Store | 1 day | ₹2,100 |
| Submit to Apple App Store (optional) | 2 days | ₹8,300/year |
| Soft launch in 1 city (e.g., Bangalore) | 1 week | Marketing budget |
| Monitor analytics, crashes, and user feedback | Ongoing | ₹0 |

---

## 11. Estimated Monthly Operating Costs

### 11.1 MVP Stage (0–1,000 users)

| Service | Provider | Monthly Cost |
|---------|----------|-------------|
| Backend + Database | Firebase (Blaze) | ₹0–₹2,000 |
| Authentication | Firebase Auth | ₹0 |
| Push Notifications | FCM | ₹0 |
| Maps & Routing | Mappls / Google Maps ($200 credit) | ₹0–₹3,000 |
| Payment Gateway | Razorpay | ~₹0–₹500 (commission only) |
| WhatsApp API | Gupshup / Interakt | ₹999–₹2,499 |
| SMS (fallback) | Firebase Auth | ₹0 |
| Analytics | Firebase Analytics + Crashlytics | ₹0 |
| Domain + SSL | Any registrar | ₹100–₹500 |
| **Total MVP** | | **₹1,099–₹8,499/mo** |

### 11.2 Growth Stage (1,000–10,000 users)

| Service | Provider | Monthly Cost |
|---------|----------|-------------|
| Backend + Database | Firebase or Supabase (Pro) | ₹3,000–₹10,000 |
| Maps & Routing | Google Maps Platform | ₹5,000–₹15,000 |
| Payment Gateway | Razorpay (2% on non-UPI) | ₹2,000–₹10,000 |
| WhatsApp API | Gupshup | ₹3,000–₹8,000 |
| Push Notifications | FCM | ₹0 |
| Analytics | Firebase + Mixpanel | ₹0 |
| Cloud Storage | Firebase / S3 | ₹500–₹2,000 |
| **Total Growth** | | **₹13,500–₹45,000/mo** |

### 11.3 Scale Stage (10,000+ users)

| Service | Provider | Monthly Cost |
|---------|----------|-------------|
| Backend (Custom) | GCP Cloud Run + Cloud SQL | ₹20,000–₹50,000 |
| Maps & Routing | Google Maps Platform | ₹15,000–₹50,000 |
| Payment Gateway | Razorpay | ₹10,000–₹50,000+ |
| WhatsApp API | Gupshup / Meta Direct | ₹10,000–₹30,000 |
| CDN + Storage | Cloudflare + GCS | ₹3,000–₹8,000 |
| Monitoring | Sentry + Firebase | ₹5,000–₹10,000 |
| **Total Scale** | | **₹63,000–₹1,98,000/mo** |

---

## Revenue Projections (Conservative)

| Metric | Month 3 | Month 6 | Month 12 |
|--------|---------|---------|----------|
| Active Agencies | 5 | 15 | 40 |
| Monthly Bookings | 200 | 1,500 | 8,000 |
| Avg. Booking Value | ₹1,500 | ₹1,500 | ₹1,800 |
| **GMV (Gross Merchandise Value)** | **₹3,00,000** | **₹22,50,000** | **₹1,44,00,000** |
| Commission Revenue (10% avg.) | ₹30,000 | ₹2,25,000 | ₹14,40,000 |
| Subscription Revenue | ₹15,000 | ₹75,000 | ₹3,20,000 |
| **Total Revenue** | **₹45,000** | **₹3,00,000** | **₹17,60,000** |
| Operating Cost | ₹8,000 | ₹35,000 | ₹1,50,000 |
| **Net Margin** | **₹37,000** | **₹2,65,000** | **₹16,10,000** |

---

## Summary

| Item | Recommendation |
|------|---------------|
| **Backend** | Firebase (MVP) → GCP Cloud Run (Scale) |
| **Database** | Firestore (MVP) → PostgreSQL (Scale) |
| **Auth** | Firebase Auth (Phone OTP + Google) |
| **Payments** | Razorpay (Split payments for multi-provider) |
| **Maps** | Mappls (MVP) → Google Maps (Scale) |
| **WhatsApp** | Gupshup |
| **Push Notifications** | Firebase Cloud Messaging (Free) |
| **Analytics** | Firebase Analytics + Crashlytics (Free) |
| **Pricing Model** | Hybrid (Subscription + Commission) |
| **Time to MVP** | ~10 weeks |
| **MVP Monthly Cost** | ₹1,099–₹8,499/month |
| **First Revenue** | Month 2 (after agency onboarding) |

---

> **Next Steps:**
> 1. Finalize backend choice (Firebase vs. Supabase vs. Custom)
> 2. Create Firebase project and configure services
> 3. Design Firestore database schema
> 4. Begin Phase 1 implementation
> 5. Start onboarding conversations with 3–5 travel agencies in Bangalore

---

*This document is a living guide and should be updated as decisions are made and the product evolves.*
