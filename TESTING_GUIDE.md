# Nova Cabs - Step-by-Step Testing Guide

This document outlines the step-by-step process to test the core functionalities of the Nova Cabs application to ensure everything is working as expected.

## Pre-requisites
- Ensure the app is built and running on a device or emulator (The `flutter build apk` command in progress must complete).
- Ensure internet connectivity for Firebase and Google Maps services.
- If testing real SMS, ensure MSG91 credentials are correct in the `.env` file.

---

## Phase 1: Authentication & Role Selection

### Test 1.1: Role Selection Screen
1.  **Action**: Launch the application.
2.  **Expected Result**: The app should open to the Splash screen and then redirect to the Role Selection screen (if not logged in).
3.  **Verification**: Verify that options for **Customer**, **Driver**, **Agency**, and **Admin** are visible.

### Test 1.2: Customer Login (MSG91 OTP Flow)
1.  **Action**: Click on **Customer** on the Role Selection screen.
2.  **Expected Result**: Redirected to the Customer Login screen.
3.  **Action**: Enter a valid phone number (e.g., `+91 9876543210`) and click "Send OTP".
4.  **Expected Result**:
    *   If using real MSG91: An SMS should be received.
    *   If using mock/debug: The app should proceed to the OTP screen.
5.  **Action**: Enter the received OTP.
6.  **Expected Result**: Successful verification and redirection to the **Customer Home Screen**.

---

## Phase 2: Customer Flow (Booking & Search)

### Test 2.1: Location Search & Distance Calculation
1.  **Action**: On the Customer Home Screen, click on the search bar or pickup/drop fields.
2.  **Action**: Enter a Pickup Location and a Drop Location.
3.  **Expected Result**:
    *   The app should calculate the distance.
    *   Fares should be displayed based on the distance for different cab types.
    *   *Note: If Google Maps API is not fully configured, verify that fallback/mock distances are used without crashing.*

### Test 2.2: Booking a Cab
1.  **Action**: Select a cab type (e.g., Sedan, SUV) and click "Confirm Booking" or "Book Now".
2.  **Expected Result**:
    *   A booking request should be created in Firestore.
    *   The user should see a "Searching for Drivers" or "Booking Confirmed" state.
3.  **Verification**: Check the `bookings` collection in Firestore to ensure the document exists with status `booked`.

---

## Phase 3: Driver Flow

### Test 3.1: Receiving and Accepting Bookings
1.  **Action**: Log in as a **Driver** on a separate device or after logging out of the customer account.
2.  **Expected Result**: Redirected to the Driver Dashboard.
3.  **Action**: Wait for a booking request to appear (or create one from the customer app).
4.  **Expected Result**: The driver should see a notification or a card with the trip details.
5.  **Action**: Click "Accept".
6.  **Expected Result**:
    *   The booking status in Firestore should update to `driverAccepted`.
    *   The customer app should reflect that a driver has accepted.

### Test 3.2: Trip Execution
1.  **Action**: On the Driver Dashboard, update status as you proceed:
    *   Click "Arrived" -> Status updates to `driverArriving`.
    *   Click "Start Trip" -> Status updates to `tripStarted`.
    *   Click "Complete Trip" -> Status updates to `tripCompleted`.
2.  **Verification**: Verify at each step that the Customer app and Firestore document reflect the correct status.

---

## Phase 4: Admin & Agency Management

### Test 4.1: Admin Dashboard
1.  **Action**: Log in as **Admin**.
2.  **Expected Result**: Redirected to the Admin Dashboard.
3.  **Verification**:
    *   Verify that statistics (Total Bookings, Active Drivers) are loading.
    *   Verify that the recent bookings list is visible.

### Test 4.2: Booking Management
1.  **Action**: Navigate to Booking Management in the Admin panel.
2.  **Action**: Try to update a booking status manually.
3.  **Expected Result**: The status should update in Firestore and the UI should reflect the change.

---

## Troubleshooting Tips
- **App Crashes on Map**: Check if Google Maps API key is placed in `android/app/src/main/AndroidManifest.xml`.
- **OTP Not Received**: Check MSG91 balance and template ID configuration in the backend/env.
- **Firebase Permission Errors**: Ensure Firestore rules allow read/write for the respective collections or are set to open for testing.
