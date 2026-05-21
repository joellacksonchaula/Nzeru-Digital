# 🔄 DIAGRAM 7 OF 9: ACTIVITY DIAGRAM
## Digital Saving Vault (Nzelu Digital Saving)
**Type**: UML Activity Diagram | **Shows**: User workflows, 8 states, 7 decision points

## Diagram Code (Mermaid)

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

## Activity States and Transitions:

### 1. **APP INITIALIZATION**
- **[Start]** → **OpenApp**
  - User launches the application
  
- **OpenApp** → **CheckLogin**
  - System checks stored authentication tokens
  - Validates token expiration
  
- **CheckLogin** → **IsLoggedIn?** (Decision)
  - Decision: Is user already authenticated?

### 2. **AUTHENTICATION FLOW**
- **IsLoggedIn = No** → **LoginScreen**
  - Present login form
  - Request email/phone and password
  
- **LoginScreen** → **InvalidCreds?** (Decision)
  - Validate credentials against database
  - Check account status
  
- **InvalidCreds = No** → **ErrorMsg**
  - Display error message
  - Return to LoginScreen
  - Allow max 3 attempts before account lock
  
- **InvalidCreds = Yes** → **Dashboard**
  - Generate JWT token
  - Navigate to main dashboard

- **IsLoggedIn = Yes** → **Dashboard**
  - Load cached user data
  - Refresh from server

### 3. **DASHBOARD OPERATIONS**
- **Dashboard** → **UserAction?** (Decision)
  - User selects primary action

#### Option 1: View Balance
- **UserAction = View Balance** → **ViewBalance**
  - Fetch current account balance
  - Display balance in main widget
  
- **ViewBalance** → **ProcessData?** (Decision)
  - Check if API call successful
  
- **ProcessData = Yes** → **Dashboard**
  - Update UI with balance
  
- **ProcessData = No** → **ErrorMsg**
  - Show error notification
  - Retry option

#### Option 2: Make Deposit
- **UserAction = Make Deposit** → **MakeDeposit**
  - Navigate to deposit screen
  - List available savings plans
  
- **MakeDeposit** → **EnterAmount**
  - User enters amount
  - Select deposit method (bank transfer, mobile money)

#### Option 3: Make Withdrawal
- **UserAction = Make Withdrawal** → **MakeWithdraw**
  - Navigate to withdrawal screen
  - Show withdrawal limits
  
- **MakeWithdraw** → **EnterAmount**
  - User enters withdrawal amount
  - Select receiving account

#### Option 4: View Transactions
- **UserAction = View Transactions** → **ViewTrans**
  - Show transaction history
  - Filter by date/type
  - Back to Dashboard

#### Option 5: Apply for Loan
- **UserAction = Apply for Loan** → **ApplyLoan**
  - Navigate to loan application
  - Show eligibility info
  
- **ApplyLoan** → **EnterLoanDetails**
  - Fill loan amount, duration, purpose
  - Review terms and conditions

#### Option 6: Manage Settings
- **UserAction = View Settings** → **Settings**
  - Display user preferences
  - Theme, language, currency, notifications
  
- **Settings** → **UpdateSettings?** (Decision)
  - User makes changes?
  
- **UpdateSettings = Yes** → **SaveSettings**
  - Save settings to database
  - Update local preferences
  - Return to Dashboard
  
- **UpdateSettings = No** → **Dashboard**

#### Option 7: Logout
- **UserAction = Logout** → **Logout**
  - Clear authentication token
  - Clear cached data
  - [End]

### 4. **TRANSACTION PROCESSING**
- **EnterAmount** or **EnterLoanDetails** → **Confirm?** (Decision)
  - Display confirmation screen
  - Show transaction summary
  
- **Confirm = No** → **Dashboard**
  - Cancel and return
  
- **Confirm = Yes** → **ProcessTrans**
  - Submit to backend API
  - Lock UI during processing

- **ProcessTrans** → **TransSuccess?** (Decision)
  - Check API response status
  
- **TransSuccess = Yes** → **Success**
  - Display success message
  - Show transaction ID
  - Display updated balance
  
- **TransSuccess = No** → **ErrorMsg**
  - Show reason for failure
  - Suggest corrective actions

- **Success** → **SendNotif**
  - Queue notification (Email/SMS)
  - Mark notification sent
  
- **SendNotif** → **Dashboard**
  - Return to main dashboard

### 5. **ERROR HANDLING**
- **ErrorMsg**: Common error handler
  - Display error with retry option
  - Suggest troubleshooting steps
  - Return to appropriate screen

### 6. **SESSION END**
- **Logout** → **[End]**
  - Application terminates
  - Clear sensitive data from memory

## Flow Summary:
```
Start → Auth Check → [Login if needed] → Dashboard → 
[User Action] → Process → [Verify Success] → 
[Send Notification] → Return to Dashboard
```

## Key Decision Points:
1. **IsLoggedIn**: Determines if authentication needed
2. **InvalidCreds**: Validates user credentials
3. **UserAction**: Routes to specific feature
4. **ProcessData**: Confirms successful data fetch
5. **Confirm**: User confirms transaction
6. **TransSuccess**: Verifies transaction completion
7. **UpdateSettings**: Checks if user made changes

---
**Document Version**: 1.0  
**Date**: April 2026  
**Project**: Digital Saving Vault (Nzelu Digital Saving)  
**Diagram Type**: Activity Diagram / State Machine
