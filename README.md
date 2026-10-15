# 💻 LifeDrop — Web Admin Dashboard & Security Portal

> 📱 **Full-Stack Ecosystem:** This repository contains the web administrative dashboard. Looking for the donor/recipient mobile application? Visit the **[LifeDrop Mobile App Repository](https://github.com/LiyaHanna/LifeDrop-Blood-Donation-App)**.

---

## 📌 Project Overview

The **LifeDrop Web Admin Dashboard** is the centralized management and security monitoring system for the LifeDrop Emergency Blood Donation Platform. Designed specifically for system administrators and healthcare coordinators, it provides real-time oversight of blood donation requests, donor identity verifications, and system-wide security tracking.

Built with **Flutter Web** and **Firebase**, the dashboard guarantees synchronized data integrity across mobile and web platforms while maintaining strict security standards for sensitive user records.

---

## 🔒 Key Features & Functionality

- 🆔 **Donor ID & Medical Document Verification:** Secure administrative workflow to inspect, review, and verify official government IDs and health documentation submitted by blood donors prior to granting verified status.
- 🩸 **Blood Type Change Request Verification:** Dedicated verification pipeline for approving user requests to modify their registered blood type—requiring valid medical lab documentation review to ensure database accuracy and donor safety.
- 🏥 **Emergency Request Oversight:** Real-time dashboard for reviewing, filtering, and managing high-priority emergency blood requests across regional hospitals.
- 🔑 **Role-Based Access Control (RBAC):** Custom Firebase Security Rules enforcing strict separation between regular mobile users and privileged dashboard administrators.
- 📊 **Real-Time Database Sync:** Cloud Firestore synchronization ensuring instant updates between donor mobile app actions and admin panel views.

---

## 🛠️ Tech Stack & Architecture

- **Frontend & Web Framework:** Flutter Web, Dart
- **Backend & Database:** Firebase Services
  - **Cloud Firestore:** Real-time Database & Audit Logs Storage
  - **Firebase Authentication:** Secure Admin Login & JWT Handling
  - **Cloud Storage:** Document & Identity Verification Media
- **UI Components:** Responsive Material Design, `PaginatedDataTable` for log reviews

---

## 🖼️ Dashboard Screenshots

- Admin Dashboard
<p align="center">
  <img width="1280" height="611" alt="Admin Dashboard" src="https://github.com/user-attachments/assets/f3042613-42aa-4fc9-a762-8b587c2c6c9e" />
  <img width="1278" height="564" alt="Report Screen" src="https://github.com/user-attachments/assets/caf1d770-15ce-47de-a071-b1ccf434034b" />
  <img width="1280" height="612" alt="Blood Banks Screen" src="https://github.com/user-attachments/assets/a532a1fd-c56c-4f5b-b3b6-61285d458bcc" />
</p>

---

### 🔑 Access & Authentication

This dashboard requires verified administrative credentials. If you are a recruiter or technical interviewer who would like live access to test the admin panel, please contact me directly at **liya.hanna09@gmail.com** for temporary credentials.
