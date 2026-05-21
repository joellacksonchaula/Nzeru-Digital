# Digital Saving Vault (Nzelu Digital Saving)
## Comprehensive Project Documentation

---

## 1. MODULE DESCRIPTIONS

### Module 1: Authentication & User Management
- **Purpose**: Handle user registration, login, password reset, and profile management
- **Key Features**: User authentication, profile settings, 2FA, biometric login, user data persistence
- **Technologies**: Flutter (frontend), Django (backend), JWT tokens, secure credential storage
- **Actors**: Users, System Administrator

### Module 2: Savings Management
- **Purpose**: Allow users to create, manage, and track savings plans and deposits
- **Key Features**: Create savings plans, deposit tracking, interest calculation, auto-save feature, withdrawal processing
- **Technologies**: Provider state management, REST API, SQLite (local cache)
- **Actors**: Users, Account Holders

### Module 3: Credit/Loan Management
- **Purpose**: Enable users to access microfinance credit with flexible repayment options
- **Key Features**: Loan application, approval workflow, EMI calculation, repayment tracking, interest calculation
- **Technologies**: Business logic engine, Payment gateway integration, Notification service
- **Actors**: Borrowers, Credit Officers, Admin

### Module 4: Dashboard & Analytics
- **Purpose**: Provide comprehensive financial overview and transaction history
- **Key Features**: Balance display, transaction history, savings progress charts, financial score display, reports
- **Technologies**: FL Charts, Data aggregation service, Analytics engine
- **Actors**: Users, Finance Managers

### Module 5: Payment & Transaction Processing
- **Purpose**: Handle all financial transactions (deposits, withdrawals, repayments)
- **Key Features**: Transaction verification, payment gateway integration, receipt generation, transaction history
- **Technologies**: Payment APIs, Django models, PostgreSQL/SQLite, Transaction logger
- **Actors**: Users, Payment Processors

### Module 6: Notifications & Alerts
- **Purpose**: Keep users informed about account activities and important alerts
- **Key Features**: Email/SMS notifications, transaction alerts, milestone celebrations, app notifications
- **Technologies**: Push notification service, Email services, Message queues
- **Actors**: Users, System

### Module 7: Settings & Preferences
- **Purpose**: Allow users to customize their app experience and security settings
- **Key Features**: Theme selection, language preferences, currency settings, notification preferences, security settings
- **Technologies**: Shared Preferences (Flutter), Backend cache
- **Actors**: End Users

---

## 2. UML DIAGRAMS

### 2.1 Use Case Diagram
```mermaid
graph TB
    User["👤 End User"]
    Admin["👨‍💼 Administrator"]
    System["⚙️ System"]
    
    User -->|UC1| Register["Register Account"]
    User -->|UC2| Login["Login/Authentication"]
    User -->|UC3| CreateSavingsPlan["Create Savings Plan"]
    User -->|UC4| DepositAmount["Deposit Money"]
    User -->|UC5| ViewBalance["View Account Balance"]
    User -->|UC6| WithdrawAmount["Withdraw Money"]
    User -->|UC7| ApplyForCredit["Apply for Credit"]
    User -->|UC8| ViewTransactionHistory["View Transactions"]
    User -->|UC9| ManageSettings["Manage Settings"]
    
    Admin -->|UC10| ApproveCredit["Approve/Reject Credit"]
    Admin -->|UC11| GenerateReports["Generate Reports"]
    Admin -->|UC12| ManageUsers["Manage Users"]
    
    System -->|UC13| CalculateInterest["Calculate Interest"]
    System -->|UC14| SendNotifications["Send Notifications"]
    System -->|UC15| UpdateBalances["Update Balances"]

    style Register fill:#e1f5ff
    style Login fill:#e1f5ff
    style CreateSavingsPlan fill:#c8e6c9
    style DepositAmount fill:#c8e6c9
    style ViewBalance fill:#e0e0e0
    style WithdrawAmount fill:#ffccbc
    style ApplyForCredit fill:#f8bbd0
    style ViewTransactionHistory fill:#e0e0e0
    style ManageSettings fill:#ede7f6
    style ApproveCredit fill:#ffe0b2
    style GenerateReports fill:#ffe0b2
    style ManageUsers fill:#ffe0b2
    style CalculateInterest fill:#f0f4c3
    style SendNotifications fill:#f0f4c3
    style UpdateBalances fill:#f0f4c3
```

### 2.2 Class Diagram
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

### 2.3 System Architecture Diagram
```mermaid
graph TB
    subgraph Client["📱 Client Layer"]
        Flutter["Flutter App<br/>(iOS/Android/Web)"]
        LocalDB["📦 Local Storage<br/>(SQLite/SharedPrefs)"]
    end
    
    subgraph API["🌐 API Gateway"]
        Gateway["REST API Gateway<br/>(Django REST Framework)"]
        Auth["Authentication<br/>Service"]
    end
    
    subgraph Business["💼 Business Logic Layer"]
        AuthService["Auth Service"]
        SavingsService["Savings Service"]
        LoanService["Loan Service"]
        TransactionService["Transaction Service"]
        NotificationService["Notification Service"]
        AnalyticsService["Analytics Service"]
    end
    
    subgraph Data["🗄️ Data Layer"]
        PgDB["PostgreSQL<br/>Database"]
        Cache["Redis Cache"]
    end
    
    subgraph External["🔗 External Services"]
        PaymentGW["Payment Gateway<br/>(Stripe/Pesapal)"]
        EmailService["Email Service<br/>(SendGrid)"]
        SMSService["SMS Service<br/>(Twilio)"]
    end
    
    Flutter -->|HTTP/REST| Gateway
    LocalDB -->|Store/Retrieve| Flutter
    Gateway -->|Validate| Auth
    Gateway -->|Route| AuthService
    Gateway -->|Route| SavingsService
    Gateway -->|Route| LoanService
    Gateway -->|Route| TransactionService
    Gateway -->|Route| NotificationService
    Gateway -->|Route| AnalyticsService
    
    AuthService -->|Read/Write| PgDB
    SavingsService -->|Read/Write| PgDB
    LoanService -->|Read/Write| PgDB
    TransactionService -->|Read/Write| PgDB
    NotificationService -->|Read/Write| PgDB
    AnalyticsService -->|Cache| Cache
    
    TransactionService -->|Integrate| PaymentGW
    NotificationService -->|Send| EmailService
    NotificationService -->|Send| SMSService
    
    style Client fill:#e3f2fd
    style API fill:#f3e5f5
    style Business fill:#e8f5e9
    style Data fill:#fff3e0
    style External fill:#fce4ec
```

### 2.4 Data Flow Diagram - Level 1
```mermaid
graph LR
    User["👤 User"]
    System["⚙️ Digital Saving Vault<br/>System"]
    Reports["📊 Generate Reports"]
    
    User -->|Provides Input| System
    System -->|Processing<br/>- Authenticate<br/>- Manage Savings<br/>- Process Loans<br/>- Handle Transactions| Reports
    System -->|Updates<br/>Account Data| User
    System -->|Sends<br/>Notifications| User
    
    style User fill:#bbdefb
    style System fill:#c8e6c9
    style Reports fill:#ffe0b2
```

### 2.5 Data Flow Diagram - Level 2
```mermaid
graph TB
    subgraph Input["📥 Input Processes"]
        Login["Login/Authenticate"]
        Deposit["Deposit Money"]
        Withdraw["Withdraw Money"]
        ApplyLoan["Apply for Loan"]
    end
    
    subgraph Processing["⚙️ Processing"]
        AuthProcess["Authentication<br/>Process"]
        TransProcess["Transaction<br/>Processing"]
        LoanProcess["Loan Processing<br/>Engine"]
        BalanceUpdateProcess["Balance<br/>Update"]
    end
    
    subgraph Output["📤 Output Processes"]
        Dashboard["Display Dashboard"]
        Statement["Generate Statement"]
        Notifications["Send Notifications"]
    end
    
    subgraph Store["💾 Data Store"]
        UserDB["User Data"]
        TransDB["Transaction Data"]
        LoanDB["Loan Data"]
    end
    
    Login -->|User Credentials| AuthProcess
    Deposit -->|Amount| TransProcess
    Withdraw -->|Amount| TransProcess
    ApplyLoan -->|Loan Details| LoanProcess
    
    AuthProcess -->|Verified| Dashboard
    TransProcess -->|Transaction| BalanceUpdateProcess
    LoanProcess -->|Processed| BalanceUpdateProcess
    
    BalanceUpdateProcess -->|Updated Balance| Dashboard
    BalanceUpdateProcess -->|Generate| Statement
    BalanceUpdateProcess -->|Trigger| Notifications
    
    AuthProcess -->|Store| UserDB
    TransProcess -->|Store| TransDB
    LoanProcess -->|Store| LoanDB
    
    style Input fill:#bbdefb
    style Processing fill:#c8e6c9
    style Output fill:#ffe0b2
    style Store fill:#f8bbd0
```

### 2.6 Data Flow Diagram - Level 3
```mermaid
graph TB
    subgraph A["👤 User Actions"]
        A1["Enter Credentials"]
        A2["Select Savings Plan"]
        A3["Enter Amount"]
        A4["Confirm Transaction"]
    end
    
    subgraph B["🔐 Authentication"]
        B1["Validate Email<br/>Format"]
        B2["Check Password<br/>Strength"]
        B3["Query User<br/>Database"]
        B4["Match Credentials"]
        B5["Generate JWT<br/>Token"]
    end
    
    subgraph C["💰 Transaction"]
        C1["Retrieve Account<br/>Balance"]
        C2["Validate Amount<br/>Rules"]
        C3["Create Transaction<br/>Record"]
        C4["Update Balance"]
        C5["Calculate Interest"]
    end
    
    subgraph D["📊 Updated System"]
        D1["Update UserProfile<br/>Savings Balance"]
        D2["Create Audit<br/>Log"]
        D3["Queue Notification"]
    end
    
    A1 --> B1
    B1 --> B2
    B2 --> B3
    B3 --> B4
    B4 --> B5
    B5 --> A2
    
    A2 --> A3
    A3 --> A4
    A4 --> C1
    C1 --> C2
    C2 --> C3
    C3 --> C4
    C4 --> C5
    C5 --> D1
    D1 --> D2
    D2 --> D3
    
    style A fill:#e1f5fe
    style B fill:#c8e6c9
    style C fill:#fff3e0
    style D fill:#ede7f6
```

### 2.7 Activity Diagram
```mermaid
stateDiagram-v2
    [*] --> OpenApp: User Opens App
    OpenApp --> CheckLogin: Check Authentication<br/>Status
    CheckLogin --> IsLoggedIn{Is User<br/>Logged In?}
    
    IsLoggedIn -->|No| LoginScreen: Navigate to<br/>Login Screen
    IsLoggedIn -->|Yes| Dashboard: Show Dashboard
    
    LoginScreen --> InvalidCreds{Credentials<br/>Valid?}
    InvalidCreds -->|No| ErrorMsg: Show Error
    ErrorMsg --> LoginScreen
    InvalidCreds -->|Yes| Dashboard
    
    Dashboard --> UserAction{User<br/>Action}
    
    UserAction -->|View Balance| ViewBalance: Retrieve & Display<br/>Account Balance
    UserAction -->|Make Deposit| MakeDeposit: Navigate to<br/>Deposit Screen
    UserAction -->|Make Withdrawal| MakeWithdraw: Navigate to<br/>Withdrawal Screen
    UserAction -->|View Transactions| ViewTrans: Show Transaction<br/>History
    UserAction -->|Apply for Loan| ApplyLoan: Navigate to<br/>Loan Application
    UserAction -->|View Settings| Settings: Show User<br/>Settings
    UserAction -->|Logout| Logout: Clear Session
    
    ViewBalance --> ProcessData{Data<br/>Fetch<br/>Success?}
    MakeDeposit --> EnterAmount: Enter Amount<br/>& Plan
    MakeWithdraw --> EnterAmount
    ApplyLoan --> EnterLoanDetails: Fill Loan<br/>Application
    
    ProcessData -->|Yes| Dashboard
    ProcessData -->|No| ErrorMsg
    
    EnterAmount --> Confirm{Confirm<br/>Transaction?}
    EnterLoanDetails --> Confirm
    
    Confirm -->|No| Dashboard
    Confirm -->|Yes| ProcessTrans: Process<br/>Transaction
    
    ProcessTrans --> TransSuccess{Transaction<br/>Success?}
    TransSuccess -->|Yes| Success: Show Success<br/>Message
    TransSuccess -->|No| ErrorMsg
    
    Success --> SendNotif: Send Notification
    SendNotif --> Dashboard
    
    Settings --> UpdateSettings{Update<br/>Settings?}
    UpdateSettings -->|Yes| SaveSettings: Save Changes
    UpdateSettings -->|No| Dashboard
    SaveSettings --> Dashboard
    
    Logout --> [*]
```

### 2.8 Sequential Diagram
```mermaid
sequenceDiagram
    participant User as 👤 User
    participant App as 📱 Flutter App
    participant Gateway as 🌐 API Gateway
    participant AuthSvc as 🔐 Auth Service
    participant DB as 🗄️ Database
    participant NotifSvc as 📬 Notification Service

    User->>App: 1. Opens App
    App->>Gateway: 2. GET /auth/status
    Gateway->>AuthSvc: 3. Check Token
    AuthSvc->>DB: 4. Retrieve User
    DB-->>AuthSvc: 5. User Data
    AuthSvc-->>Gateway: 6. Token Valid
    Gateway-->>App: 7. Auth Success Response
    App->>App: 8. Load Dashboard
    
    Note over User,App: User Makes Transaction
    User->>App: 9. Initiate Deposit
    App->>Gateway: 10. POST /transactions/deposit
    Gateway->>Gateway: 11. Validate Request
    Gateway->>DB: 12. Get Current Balance
    DB-->>Gateway: 13. Return Balance
    Gateway->>DB: 14. Create Transaction Record
    DB-->>Gateway: 15. Transaction Created
    Gateway->>DB: 16. Update User Balance
    DB-->>Gateway: 17. Balance Updated
    Gateway->>NotifSvc: 18. Queue Notification
    NotifSvc->>NotifSvc: 19. Send Email/SMS
    Gateway-->>App: 20. Success Response
    App->>User: 21. Show Confirmation
```

### 2.9 Entity Relationship Diagram
```mermaid
erDiagram
    USER ||--|| USERPROFILE : has
    USER ||--o{ SAVINGSPLAN : creates
    USER ||--o{ TRANSACTION : performs
    USER ||--o{ LOAN : applies
    USER ||--o{ NOTIFICATION : receives
    
    SAVINGSPLAN ||--o{ TRANSACTION : contains
    LOAN ||--o{ REPAYMENT : has
    TRANSACTION ||--o{ PAYMENT : generates

    USER {
        string id PK
        string email UK
        string password
        string phone
        datetime created_at
        datetime updated_at
    }
    
    USERPROFILE {
        string id PK
        string user_id FK
        decimal savings_balance
        decimal loan_balance
        integer financial_score
        string preferred_currency
        boolean notifications_enabled
        string preferred_theme
    }
    
    SAVINGSPLAN {
        string id PK
        string user_id FK
        string plan_name
        decimal target_amount
        decimal current_amount
        float interest_rate
        datetime start_date
        datetime end_date
        string status
    }
    
    TRANSACTION {
        string id PK
        string user_id FK
        string savings_plan_id FK
        string type
        decimal amount
        string status
        datetime timestamp
        string description
    }
    
    LOAN {
        string id PK
        string user_id FK
        decimal principal_amount
        float interest_rate
        integer tenure_months
        decimal remaining_balance
        string status
        datetime approval_date
    }
    
    REPAYMENT {
        string id PK
        string loan_id FK
        decimal amount
        datetime due_date
        datetime paid_date
        string status
    }
    
    PAYMENT {
        string id PK
        string transaction_id FK
        string payment_method
        string gateway_ref
        decimal amount
        string status
        datetime timestamp
    }
    
    NOTIFICATION {
        string id PK
        string user_id FK
        string type
        string title
        string message
        boolean is_read
        datetime created_at
    }
```

---

## 3. PHASE 1 & PHASE 2 PLANNING

### Phase 1: Core Foundation (Months 1-2)
**Objective**: Build essential features for MVP

#### Phase 1 Modules:
1. **Authentication & User Management Module**
   - User registration with email verification
   - Login/Logout functionality
   - Password reset feature
   - Basic profile management
   - Secure token storage

2. **Savings Management Module (Basic)**
   - Create savings plans
   - View savings balance
   - Basic deposit tracking
   - Manual deposit processing
   - Simple interest calculation

3. **Dashboard & Analytics Module (Basic)**
   - Display current balance
   - Show recent transactions (last 10)
   - Basic statistics and progress bars
   - Simple transaction history

4. **Payment & Transaction Processing Module (Basic)**
   - Deposit transaction creation
   - Basic withdrawal requests
   - Transaction status tracking
   - Receipt generation

5. **Settings & Preferences Module**
   - Theme selection (Light/Dark)
   - Language preferences (English/Local)
   - Currency selection
   - Notification toggle
   - Security settings

**Phase 1 Deliverables:**
- ✅ Functional Flutter app (Android/iOS)
- ✅ Django backend API endpoints
- ✅ User authentication system
- ✅ Basic savings functionality
- ✅ Transaction processing
- ✅ Simple dashboard
- ✅ MVP ready for testing

---

### Phase 2: Advanced Features (Months 3-4)
**Objective**: Add credit/loan system and advanced features

#### Phase 2 Modules:
1. **Credit/Loan Management Module (Full)**
   - Loan application submission
   - Automated approval workflow
   - EMI calculation engine
   - Repayment schedule generation
   - Partial payment processing
   - Loan status tracking

2. **Notifications & Alerts Module (Full)**
   - Email notifications
   - SMS notifications
   - Push notifications
   - Transaction alerts
   - Milestone celebrations
   - Account alerts

3. **Dashboard & Analytics Module (Advanced)**
   - Advanced charts and graphs
   - Spending patterns
   - Savings goal progress
   - Financial score display
   - Detailed reports
   - Monthly/Yearly analysis

4. **Savings Management Module (Advanced)**
   - Auto-save feature
   - Multiple savings goals
   - Interest rewards system
   - Penalty system
   - Savings milestones
   - Achievement badges

5. **Payment & Transaction Processing Module (Advanced)**
   - Multiple payment methods
   - Payment gateway integration
   - Scheduled transactions
   - Recurring payments
   - Transaction export
   - Advanced filters

6. **Security & Compliance Module**
   - 2-Factor Authentication
   - Biometric login
   - Session management
   - Audit logging
   - Data encryption
   - GDPR compliance

**Phase 2 Deliverables:**
- ✅ Credit/Loan system fully operational
- ✅ Advanced notification system
- ✅ Comprehensive analytics dashboard
- ✅ Enhanced security features
- ✅ Payment gateway integration
- ✅ Full production-ready application
- ✅ Admin dashboard for management

---

## 4. TECHNOLOGY STACK

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **UI Components**: Material Design 3
- **Charts**: FL Charts
- **Local Storage**: SQLite, Shared Preferences
- **HTTP**: HTTP package

### Backend
- **Framework**: Django 4.x
- **API**: Django REST Framework
- **Database**: PostgreSQL (Production), SQLite (Development)
- **Cache**: Redis
- **Task Queue**: Celery
- **Auth**: JWT (Django SimpleJWT)

### External Services
- **Payment Gateway**: Stripe/Pesapal
- **Email Service**: SendGrid
- **SMS Service**: Twilio
- **Hosting**: AWS/Digital Ocean

---

## 5. DEPLOYMENT STRATEGY

### Phase 1 Deployment
- **Frontend**: Google Play Store (Beta), App Store (TestFlight)
- **Backend**: Heroku or AWS EC2 (t2.micro)
- **Database**: AWS RDS or Heroku Postgres
- **CDN**: CloudFlare

### Phase 2 Deployment
- **Frontend**: Official releases on Play Store & App Store
- **Backend**: Scaled EC2 instances with load balancing
- **Database**: AWS RDS with read replicas
- **Monitoring**: CloudWatch, Sentry
- **CI/CD**: GitHub Actions

---

## Document Created: April 2026
## Version: 1.0
