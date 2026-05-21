# Savings UTL - Comprehensive Project Documentation

**Project:** Futuristic Microfinance Savings & Loan Platform  
**Version:** 1.0.0  
**Date:** April 15, 2026

---

## 1. MODULE DESCRIPTION

### Module 1: User Authentication & Profile Management
**Description:** Handles user registration, login, password management, and profile maintenance.

**Key Features:**
- User registration with email/phone verification
- Login with 2FA support
- Biometric authentication (fingerprint/face recognition)
- Profile management (personal info, preferences, settings)
- Password reset and account recovery
- User session management and token-based authentication

**Technologies:** Django REST API (Backend), Flutter (Frontend)

**Database Entities:** User, UserProfile, AuthToken, AuditLog

---

### Module 2: Savings Plan Management
**Description:** Core module for creating, managing, and tracking savings plans with various configurations.

**Key Features:**
- Create flexible savings plans (daily, weekly, monthly, custom)
- Set savings goals with target amounts and deadlines
- Automatic interest calculation based on plan type
- Plan pause/resume functionality
- Trial plan support for new users
- Progress tracking and milestone achievements
- Plan analytics and performance metrics

**Technologies:** Django ORM (Backend), SQLite (Database), Provider (State Management)

**Database Entities:** SavingsPlan, PlanType, Milestone, PlanMetrics

---

### Module 3: Transactions & Financial Operations
**Description:** Manages all financial transactions including deposits, withdrawals, interest rewards, and penalties.

**Key Features:**
- Deposit transactions with multiple payment methods
- Withdrawal requests with approval workflow
- Interest reward calculations (daily/weekly/monthly accrual)
- Penalty application for plan violations
- Transaction history and receipts
- Real-time transaction status tracking
- Reconciliation with payment gateways

**Technologies:** Django REST API, Celery (async tasks), PostgreSQL

**Database Entities:** Transaction, PaymentMethod, Receipt, TransactionLog

---

### Module 4: Loan & Credit Management
**Description:** Handles loan applications, approvals, disbursement, and repayment tracking.

**Key Features:**
- Loan application with eligibility criteria
- Credit scoring based on savings history
- Loan approval workflow with admin review
- Disbursement scheduling
- Repayment schedule generation
- Interest calculation for loans
- Late payment penalties and reminders
- Loan status tracking (pending, approved, active, completed, defaulted)

**Technologies:** Django Models, Business Logic Engine

**Database Entities:** Loan, LoanApplication, RepaymentSchedule, CreditScore

---

### Module 5: Dashboard & Analytics
**Description:** Provides comprehensive data visualization and insights for users and administrators.

**Key Features:**
- User dashboard with key metrics (balance, savings progress, loan status)
- Charts and graphs (fl_chart library)
- Financial reports and statements
- Goal progress visualization
- Transaction analytics
- Admin dashboard with system statistics
- Trend analysis and forecasting

**Technologies:** Flutter (UI), Chart Libraries, Data Aggregation API

**Database Entities:** Dashboard metrics via aggregated queries

---

### Module 6: Notifications & Alerts
**Description:** Real-time notification system for transaction alerts, reminders, and important updates.

**Key Features:**
- Transaction notifications (deposit, withdrawal, transfer)
- Savings milestone notifications
- Loan payment reminders
- System alerts and announcements
- Notification preferences management
- Push notifications and in-app notifications
- Email and SMS notifications
- Notification history

**Technologies:** Django Signals, Firebase Cloud Messaging, Twilio

**Database Entities:** Notification, NotificationPreference, NotificationLog

---

### Module 7: Settings & Preferences
**Description:** User configuration system for personalization and security settings.

**Key Features:**
- Theme preferences (light/dark mode)
- Language selection (i18n support)
- Currency preferences
- Notification settings
- Security settings (2FA, biometric)
- Payment method management
- Auto-save configuration
- Data export options

**Technologies:** Flutter SharedPreferences, Django Settings API

**Database Entities:** UserPreference, SecuritySettings

---

### Module 8: Reporting & Compliance
**Description:** System-wide reporting for auditing, compliance, and regulatory requirements.

**Key Features:**
- Transaction audit logs
- User activity logs
- Financial reports (monthly, quarterly, annual)
- Compliance reports
- System health monitoring
- Data backup and archival
- GDPR compliance features

**Technologies:** Django Admin, Reporting Engine

**Database Entities:** AuditLog, ComplianceReport, SystemLog

---

## 2. UML DIAGRAMS

### 2.1 System Architecture Diagram

```mermaid
graph TB
    Client["📱 Flutter Mobile App"]
    Web["🌐 Web Dashboard"]
    API["🔌 Django REST API"]
    Auth["🔐 Auth Service"]
    Pay["💳 Payment Gateway"]
    DB["💾 PostgreSQL DB"]
    Cache["⚡ Redis Cache"]
    Queue["📮 Message Queue"]
    Notify["🔔 Notification Service"]
    
    Client -->|REST API| API
    Web -->|REST API| API
    API -->|Authenticate| Auth
    API -->|Process Payment| Pay
    API -->|Read/Write| DB
    API -->|Cache| Cache
    API -->|Async Task| Queue
    Queue -->|Process| Notify
    Notify -->|Push/Email/SMS| Client
    
    style Client fill:#4A90E2,color:#fff
    style Web fill:#4A90E2,color:#fff
    style API fill:#7ED321,color:#000
    style Auth fill:#F5A623,color:#000
    style Pay fill:#F5A623,color:#000
    style DB fill:#BD10E0,color:#fff
    style Cache fill:#50E3C2,color:#000
    style Queue fill:#50E3C2,color:#000
    style Notify fill:#50E3C2,color:#000
```

---

### 2.2 Class Diagram

```mermaid
classDiagram
    class User {
        -id: int
        -username: string
        -email: string
        -password: string
        -date_joined: datetime
        +login()
        +logout()
        +update_profile()
    }
    
    class UserProfile {
        -id: int
        -user: User
        -phone: string
        -savings_balance: decimal
        -loan_balance: decimal
        -financial_score: int
        -preferred_theme: string
        -notifications_enabled: bool
        +recalculate_savings_balance()
        +recalculate_loan_balance()
        +get_settings()
    }
    
    class SavingsPlan {
        -id: int
        -user: User
        -name: string
        -plan_type: string
        -target_amount: decimal
        -current_amount: decimal
        -deadline: date
        -is_trial: bool
        -status: string
        +calculate_progress()
        +apply_interest()
        +check_milestone()
    }
    
    class Transaction {
        -id: int
        -user: User
        -plan: SavingsPlan
        -type: string
        -amount: decimal
        -status: string
        -created_at: datetime
        +process_transaction()
        +get_receipt()
    }
    
    class Loan {
        -id: int
        -user: User
        -amount_requested: decimal
        -amount_approved: decimal
        -interest_rate: decimal
        -status: string
        -created_at: datetime
        +apply_for_loan()
        +calculate_repayment_schedule()
        +make_payment()
    }
    
    class RepaymentSchedule {
        -id: int
        -loan: Loan
        -due_date: date
        -amount_due: decimal
        -amount_paid: decimal
        -status: string
        +mark_as_paid()
        +apply_penalty()
    }
    
    class PaymentMethod {
        -id: int
        -user: User
        -method_type: string
        -provider: string
        -account_details: encrypted
        -is_default: bool
        +verify_method()
        +remove_method()
    }
    
    class Notification {
        -id: int
        -user: User
        -title: string
        -message: string
        -type: string
        -is_read: bool
        -created_at: datetime
        +mark_as_read()
        +delete()
    }
    
    User "1" --> "1" UserProfile
    User "1" --> "*" SavingsPlan
    User "1" --> "*" Transaction
    User "1" --> "*" Loan
    User "1" --> "*" PaymentMethod
    User "1" --> "*" Notification
    SavingsPlan "1" --> "*" Transaction
    Loan "1" --> "*" RepaymentSchedule
```

---

### 2.3 Data Flow Diagrams

#### 2.3.1 Level 0 - Context Diagram (System Overview)

```mermaid
graph TB
    User["👤 User"]
    System["🏦 Savings UTL System"]
    PaymentGW["💳 Payment Gateway"]
    EmailSMS["📧 Email/SMS Provider"]
    Bank["🏦 Bank"]
    
    User -->|Login & Transact| System
    System -->|Process Payment| PaymentGW
    System -->|Send Notification| EmailSMS
    System -->|Verify Account| Bank
    PaymentGW -->|Confirm Payment| System
    EmailSMS -->|Delivery Status| System
    Bank -->|Account Status| System
    
    style User fill:#4A90E2,color:#fff
    style System fill:#7ED321,color:#000
    style PaymentGW fill:#F5A623,color:#000
    style EmailSMS fill:#50E3C2,color:#000
    style Bank fill:#BD10E0,color:#fff
```

#### 2.3.2 Level 1 - Main Processes

```mermaid
graph TB
    User["👤 User"]
    Auth["1. Authentication<br/>Login/Register"]
    SavingsMgmt["2. Savings<br/>Management"]
    TransMgmt["3. Transaction<br/>Management"]
    LoanMgmt["4. Loan<br/>Management"]
    Dashboard["5. Dashboard &<br/>Analytics"]
    DB[(💾 Database)]
    
    User -->|Credentials| Auth
    Auth -->|Authenticated| SavingsMgmt
    SavingsMgmt -->|Create/Update Plan| DB
    User -->|Deposit/Withdraw| TransMgmt
    TransMgmt -->|Record| DB
    User -->|Request Loan| LoanMgmt
    LoanMgmt -->|Track| DB
    User -->|View Stats| Dashboard
    Dashboard -->|Query| DB
    
    style Auth fill:#FFB6C1,color:#000
    style SavingsMgmt fill:#87CEEB,color:#000
    style TransMgmt fill:#90EE90,color:#000
    style LoanMgmt fill:#FFD700,color:#000
    style Dashboard fill:#DDA0DD,color:#000
```

#### 2.3.3 Level 2 - Detailed Deposit Transaction Flow

```mermaid
graph LR
    A["👤 User<br/>Initiates"] -->|Amount & Method| B["1. Validate<br/>Request"]
    B -->|Valid| C["2. Create<br/>Transaction<br/>Record"]
    B -->|Invalid| Z["❌ Reject"]
    C -->|Pending| D["3. Process<br/>Payment"]
    D -->|Success| E["4. Update<br/>Balances"]
    D -->|Failed| F["5. Rollback<br/>& Notify"]
    E -->|Completed| G["6. Send<br/>Receipt"]
    E -->|Completed| H["7. Update<br/>Dashboard"]
    G -->|Notify| A
    H -->|Refresh| A
    F -->|Notify| A
    
    style A fill:#4A90E2,color:#fff
    style B fill:#F5A623,color:#000
    style C fill:#7ED321,color:#000
    style D fill:#F5A623,color:#000
    style E fill:#7ED321,color:#000
    style G fill:#50E3C2,color:#000
    style Z fill:#E94B3C,color:#fff
```

---

### 2.4 Use Case Diagram

```mermaid
graph TB
    User["👤 End User"]
    Admin["🔧 Administrator"]
    System["Savings UTL System"]
    
    subgraph "User Activities"
        UC1["Register Account"]
        UC2["Login/Logout"]
        UC3["Create Savings Plan"]
        UC4["Deposit Funds"]
        UC5["Withdraw Funds"]
        UC6["Apply for Loan"]
        UC7["Make Loan Payment"]
        UC8["View Dashboard"]
        UC9["Manage Settings"]
        UC10["View Transactions"]
    end
    
    subgraph "Admin Activities"
        UC11["Verify User"]
        UC12["Approve Loan"]
        UC13["View Reports"]
        UC14["Manage Plans"]
        UC15["System Monitoring"]
    end
    
    User -->|Uses| UC1
    User -->|Uses| UC2
    User -->|Uses| UC3
    User -->|Uses| UC4
    User -->|Uses| UC5
    User -->|Uses| UC6
    User -->|Uses| UC7
    User -->|Uses| UC8
    User -->|Uses| UC9
    User -->|Uses| UC10
    
    Admin -->|Uses| UC11
    Admin -->|Uses| UC12
    Admin -->|Uses| UC13
    Admin -->|Uses| UC14
    Admin -->|Uses| UC15
    
    UC1 -.->|Include| UC2
    UC6 -.->|Include| UC12
    UC3 -.->|Trigger| UC8
    
    style User fill:#4A90E2,color:#fff
    style Admin fill:#F5A623,color:#000
```

---

### 2.5 Activity Diagram - Savings Plan Creation

```mermaid
graph TD
    A["🎯 Start: User Initiates<br/>Savings Plan Creation"]
    B["📋 Enter Plan Details<br/>Name, Target, Deadline"]
    C{"Validate<br/>Input?"}
    D["❌ Show Error"]
    E["✅ Calculate Metrics<br/>Interest Rate, Duration"]
    F{"Is Trial<br/>Plan?"}
    G["🧪 Set Trial Parameters<br/>Limited Duration"]
    H["💾 Save Plan to Database"]
    I["🔔 Send Confirmation<br/>Notification"]
    J["📊 Update Dashboard<br/>with New Plan"]
    K["✅ End: Plan Created<br/>Successfully"]
    
    A --> B
    B --> C
    C -->|No| D
    D --> B
    C -->|Yes| E
    E --> F
    F -->|Yes| G
    F -->|No| H
    G --> H
    H --> I
    I --> J
    J --> K
    
    style A fill:#90EE90,color:#000
    style K fill:#90EE90,color:#000
    style D fill:#FFB6C1,color:#000
    style C fill:#FFD700,color:#000
    style F fill:#FFD700,color:#000
```

---

### 2.6 Sequential Diagram - Loan Application to Disbursement

```mermaid
sequenceDiagram
    participant User as 👤 User
    participant Mobile as 📱 App
    participant API as 🔌 API
    participant DB as 💾 Database
    participant Admin as 🔧 Admin Portal
    participant Payment as 💳 Payment Service

    User->>Mobile: Click "Apply for Loan"
    Mobile->>API: POST /loans/apply with details
    API->>DB: Validate user credit score & balances
    DB-->>API: Return user profile data
    
    alt Credit Score Insufficient
        API-->>Mobile: Reject application
        Mobile-->>User: Show denial reason
    else Credit Score Valid
        API->>DB: Create Loan Application (PENDING)
        DB-->>API: Loan ID 12345
        API-->>Mobile: Request submitted successfully
        Mobile-->>User: Show confirmation & reference number
        
        Admin->>Admin: Review applications dashboard
        Admin->>API: GET /loans/pending
        API->>DB: Fetch pending loans
        DB-->>API: Return loan data
        API-->>Admin: Display applications
        
        Admin->>API: POST /loans/12345/approve (amount, terms)
        API->>DB: Update Loan status to APPROVED
        API->>DB: Create RepaymentSchedule
        DB-->>API: Schedule created
        API-->>Admin: Approval confirmed
        
        Admin-->>User: Notification: Loan Approved
        
        API->>Payment: Process disbursement
        Payment->>Payment: Transfer funds
        Payment-->>API: Disbursement successful
        
        API->>DB: Update Loan status to ACTIVE
        DB-->>API: Updated
        
        API-->>Mobile: Funds disbursed
        Mobile-->>User: "Loan amount credited to account"
    end
```

---

### 2.7 Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    USER {
        int id PK
        string username UK
        string email UK
        string password
        datetime date_joined
        boolean is_active
    }
    
    USERPROFILE {
        int id PK
        int user_id FK
        string phone
        decimal savings_balance
        decimal loan_balance
        int financial_score
        string preferred_theme
        string preferred_currency
        boolean notifications_enabled
    }
    
    SAVINGSPLAN {
        int id PK
        int user_id FK
        string name
        string plan_type
        decimal target_amount
        decimal current_amount
        date deadline
        boolean is_trial
        string status
        datetime created_at
    }
    
    TRANSACTION {
        int id PK
        int user_id FK
        int plan_id FK
        string type
        decimal amount
        string status
        string description
        datetime created_at
    }
    
    PAYMENTMETHOD {
        int id PK
        int user_id FK
        string method_type
        string provider
        string encrypted_details
        boolean is_default
    }
    
    LOAN {
        int id PK
        int user_id FK
        decimal amount_requested
        decimal amount_approved
        decimal interest_rate
        string status
        datetime created_at
        datetime approved_at
    }
    
    REPAYMENTSCHEDULE {
        int id PK
        int loan_id FK
        date due_date
        decimal amount_due
        decimal amount_paid
        string status
    }
    
    NOTIFICATION {
        int id PK
        int user_id FK
        string title
        string message
        string type
        boolean is_read
        datetime created_at
    }
    
    AUDITLOG {
        int id PK
        int user_id FK
        string action
        string details
        datetime timestamp
    }
    
    USER ||--|| USERPROFILE : has
    USER ||--o{ SAVINGSPLAN : creates
    USER ||--o{ TRANSACTION : performs
    USER ||--o{ PAYMENTMETHOD : owns
    USER ||--o{ LOAN : applies
    USER ||--o{ NOTIFICATION : receives
    USER ||--o{ AUDITLOG : generates
    SAVINGSPLAN ||--o{ TRANSACTION : contains
    LOAN ||--o{ REPAYMENTSCHEDULE : has
    TRANSACTION ||--o{ AUDITLOG : logged_in
```

---

## 3. IMPLEMENTATION PLANNING

### Phase 1: Foundation (Months 1-3)

**Objective:** Build core user management and savings infrastructure

#### Phase 1 Modules:
1. **User Authentication & Profile Management**
   - User registration and login
   - JWT token management
   - User profile creation and updates
   - Basic password management
   - **Deliverables:**
     - REST API endpoints for auth
     - Flutter login/signup screens
     - User profile management screen
     - Database schema and migrations

2. **User Settings & Preferences**
   - Theme selection (light/dark)
   - Language preferences (i18n)
   - Currency selection
   - Notification preferences
   - **Deliverables:**
     - Settings API endpoints
     - Settings UI screens
     - SharedPreferences integration
     - User preference persistence

#### Phase 1 Timeline:
- **Week 1-2:** Backend setup, authentication API, database schema
- **Week 3-4:** Frontend login/signup screens, authentication integration
- **Week 5-6:** User profile management, CRUD operations
- **Week 7-8:** Settings module, preferences management
- **Week 9-10:** Testing, bug fixes, documentation
- **Week 11-12:** Deployment to staging, UAT preparation

#### Phase 1 Deliverables:
- ✅ Authentication API (Login, Register, Refresh Token, Logout)
- ✅ User Profile API (Get, Update, Delete)
- ✅ Settings API (Get, Update Preferences)
- ✅ Flutter UI for Auth and Settings
- ✅ Database migrations
- ✅ API documentation (Swagger)
- ✅ Unit tests (80%+ coverage)

---

### Phase 2: Transactions & Savings (Months 4-6)

**Objective:** Implement core savings and transaction functionality

#### Phase 2 Modules:
1. **Savings Plan Management**
   - Create/update/delete savings plans
   - Multiple plan types (daily, weekly, monthly, custom)
   - Trial plans for new users
   - Plan status management
   - Interest calculation engine
   - Milestone tracking
   - **Deliverables:**
     - Savings plan CRUD API
     - Plan type configuration
     - Interest calculation logic
     - Plan dashboard UI
     - Milestone achievement system

2. **Transactions & Financial Operations**
   - Deposit transactions
   - Withdrawal requests
   - Interest reward application
   - Penalty system
   - Transaction history and filtering
   - Receipt generation
   - **Deliverables:**
     - Transaction API (Create, List, Get)
     - Payment method management API
     - Transaction UI screens
     - Receipt generation service
     - Transaction status tracking

3. **Dashboard & Analytics**
   - User dashboard with key metrics
   - Balance overview
   - Savings progress charts
   - Transaction history
   - Financial goals visualization
   - **Deliverables:**
     - Dashboard API (aggregated stats)
     - Flutter dashboard UI
     - Chart integration (fl_chart)
     - Real-time balance updates

4. **Notifications & Alerts**
   - Transaction notifications
   - Savings milestone alerts
   - System alerts
   - Notification preferences
   - Push notification integration
   - **Deliverables:**
     - Notification API
     - Firebase Cloud Messaging setup
     - In-app notification UI
     - Notification preference settings

#### Phase 2 Timeline:
- **Week 1-2:** Savings plan API and database schema
- **Week 3-4:** Transaction management system
- **Week 5-6:** Frontend UI for savings and transactions
- **Week 7-8:** Dashboard and analytics integration
- **Week 9-10:** Notifications system setup
- **Week 11-12:** Integration testing, performance optimization
- **Week 13-14:** Final QA, documentation, deployment preparation

#### Phase 2 Deliverables:
- ✅ Savings Plan Management API
- ✅ Transaction Management API
- ✅ Payment Method Management API
- ✅ Dashboard API with aggregated statistics
- ✅ Notification System (Push, In-app, Email, SMS)
- ✅ Flutter UI for savings, transactions, dashboard
- ✅ Charts and visualizations
- ✅ Integration tests (70%+ coverage)
- ✅ API documentation updates
- ✅ Performance optimization report

---

### Phase 3: Loans & Advanced Features (Months 7-9) - Future

**Objective:** Add loan management and advanced analytics features

#### Phase 3 Modules (Planned):
1. Loan & Credit Management
2. Reporting & Compliance
3. Advanced Analytics & Forecasting
4. Admin Dashboard & Monitoring

---

## Summary

### Technology Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Django REST Framework (Python)
- **Database:** PostgreSQL (Production), SQLite (Development)
- **Cache:** Redis
- **Task Queue:** Celery
- **Real-time:** WebSockets (optional)
- **Notifications:** Firebase Cloud Messaging, Twilio
- **Deployment:** Docker, Nginx, Gunicorn

### Success Criteria for Phase 1
- [ ] All authentication flows working (Register, Login, 2FA)
- [ ] User profiles fully functional
- [ ] Settings persist correctly
- [ ] 80%+ API endpoint test coverage
- [ ] Zero critical security issues
- [ ] UI/UX meets design standards

### Success Criteria for Phase 2
- [ ] All transactions processing correctly
- [ ] Interest calculations accurate
- [ ] Dashboard performance < 500ms
- [ ] Notifications delivered reliably
- [ ] 70%+ integration test coverage
- [ ] System scales to 10,000 concurrent users
- [ ] Zero financial data loss
- [ ] GDPR compliance verified

---

**Document Version:** 1.0  
**Last Updated:** April 15, 2026  
**Next Review:** Monthly
