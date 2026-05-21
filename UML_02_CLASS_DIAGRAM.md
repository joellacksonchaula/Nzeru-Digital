# 🏗️ DIAGRAM 2 OF 9: CLASS DIAGRAM
## Digital Saving Vault (Nzelu Digital Saving)
**Type**: UML Class Diagram | **Shows**: 7 classes with attributes and relationships

## Diagram Code (Mermaid)

```mermaid
graph TB
    User["<b>User</b><br/>---<br/>id: UUID<br/>email: String<br/>password: String<br/>phone: String<br/>created_at: DateTime<br/>---<br/>authenticate()<br/>updateProfile()"]
    
    UserProfile["<b>UserProfile</b><br/>---<br/>id: UUID<br/>savings_balance: Decimal<br/>loan_balance: Decimal<br/>financial_score: Integer<br/>preferred_currency: String<br/>notifications_enabled: Boolean<br/>---<br/>recalculateSavingsBalance()<br/>recalculateLoanBalance()"]
    
    SavingsPlan["<b>SavingsPlan</b><br/>---<br/>id: UUID<br/>user_id: UUID<br/>plan_name: String<br/>target_amount: Decimal<br/>current_amount: Decimal<br/>interest_rate: Float<br/>start_date: DateTime<br/>end_date: DateTime<br/>status: String<br/>---<br/>calculateProgress()<br/>addInterest()"]
    
    Transaction["<b>Transaction</b><br/>---<br/>id: UUID<br/>user_id: UUID<br/>type: String<br/>amount: Decimal<br/>status: String<br/>timestamp: DateTime<br/>description: String<br/>---<br/>processTransaction()<br/>updateStatus()"]
    
    Loan["<b>Loan</b><br/>---<br/>id: UUID<br/>user_id: UUID<br/>principal_amount: Decimal<br/>interest_rate: Float<br/>tenure_months: Integer<br/>remaining_balance: Decimal<br/>status: String<br/>approval_date: DateTime<br/>---<br/>calculateEMI()<br/>processRepayment()<br/>calculateRemaining()"]
    
    Payment["<b>Payment</b><br/>---<br/>id: UUID<br/>transaction_id: UUID<br/>payment_method: String<br/>gateway_ref: String<br/>amount: Decimal<br/>status: String<br/>timestamp: DateTime<br/>---<br/>initiatePayment()<br/>confirmPayment()"]
    
    Notification["<b>Notification</b><br/>---<br/>id: UUID<br/>user_id: UUID<br/>type: String<br/>title: String<br/>message: String<br/>is_read: Boolean<br/>created_at: DateTime<br/>---<br/>markAsRead()<br/>send()"]
    
    User -->|has one| UserProfile
    User -->|has many| SavingsPlan
    User -->|has many| Transaction
    User -->|has many| Loan
    User -->|has many| Notification
    
    SavingsPlan -->|has many| Transaction
    Loan -->|has many| Payment
    Transaction -->|has one| Payment
    
    style User fill:#0288d1,color:#fff
    style UserProfile fill:#0288d1,color:#fff
    style SavingsPlan fill:#43a047,color:#fff
    style Transaction fill:#fb8c00,color:#fff
    style Loan fill:#e53935,color:#fff
    style Payment fill:#8e24aa,color:#fff
    style Notification fill:#00897b,color:#fff
```

## Core Classes:

### 1. **User** (Blue - Authentication)
- **Attributes**: ID, email, password, phone, created_at, updated_at
- **Methods**: authenticate(), updateProfile()
- **Relationships**: Has one UserProfile, many SavingsPlan, Transactions, Loans, Notifications

### 2. **UserProfile** (Blue - Properties)
- **Attributes**: Savings balance, loan balance, financial score, preferred settings
- **Methods**: recalculateSavingsBalance(), recalculateLoanBalance()
- **Relationships**: One-to-One with User

### 3. **SavingsPlan** (Green - Savings)
- **Attributes**: Plan name, target amount, current amount, interest rate, dates, status
- **Methods**: calculateProgress(), addInterest()
- **Relationships**: Many Transactions, belongs to User

### 4. **Transaction** (Orange - Activity)
- **Attributes**: Type, amount, status, timestamp, description
- **Methods**: processTransaction(), updateStatus()
- **Relationships**: Has one Payment, belongs to User and SavingsPlan

### 5. **Loan** (Red - Credit)
- **Attributes**: Principal, interest rate, tenure, remaining balance, status
- **Methods**: calculateEMI(), processRepayment(), calculateRemaining()
- **Relationships**: Many Payments/Repayments, belongs to User

### 6. **Payment** (Purple - Processing)
- **Attributes**: Payment method, gateway reference, amount, status, timestamp
- **Methods**: initiatePayment(), confirmPayment()
- **Relationships**: One Transaction, one Loan

### 7. **Notification** (Teal - Communication)
- **Attributes**: Type, title, message, is_read, created_at
- **Methods**: markAsRead(), send()
- **Relationships**: Belongs to User

## Key Relationships:
- **1:1** - User ↔ UserProfile
- **1:M** - User ↔ SavingsPlan, Transaction, Loan, Notification
- **1:M** - SavingsPlan ↔ Transaction
- **1:M** - Loan ↔ Payment

---
**Document Version**: 1.0  
**Date**: April 2026  
**Project**: Digital Saving Vault (Nzelu Digital Saving)
