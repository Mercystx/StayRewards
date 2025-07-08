# StayRewards 🏨

A decentralized hotel loyalty program built on Stacks blockchain using Clarity smart contracts. StayRewards revolutionizes the hospitality industry by creating a transparent, interoperable loyalty system that works across multiple hotels and gives users true ownership of their rewards.

## 🌟 Features

- **Decentralized Loyalty Program**: Hotels can register and offer points to guests
- **Cross-Hotel Compatibility**: Earn and redeem points across participating hotels
- **Transparent Tier System**: Automatic tier upgrades based on stay history
- **Smart Point Allocation**: Customizable point rates per hotel
- **Immutable Stay Records**: All stays are permanently recorded on-chain
- **Guest Profiles**: Comprehensive tracking of stays, points, and tier status

## 🏗️ Smart Contract Architecture

### Core Components

- **Hotel Management**: Registration, activation/deactivation, and point rate configuration
- **Guest Profiles**: User registration, point balances, and tier progression
- **Stay Tracking**: Complete stay lifecycle from check-in to completion
- **Point System**: Earning, tracking, and redemption of loyalty points
- **Tier System**: Bronze, Silver, Gold, and Platinum levels based on stay count

### Key Functions

#### For Hotels
- `register-hotel`: Register hotel with custom point rates
- `record-stay`: Record guest stays and automatically award points
- `complete-stay`: Mark stays as completed and update guest profiles

#### For Guests
- `register-guest`: Create a new guest profile
- `redeem-points`: Redeem accumulated points for rewards

#### Read-Only Functions
- `get-hotel-info`: Retrieve hotel details and status
- `get-guest-profile`: Access guest profile information
- `get-guest-points`: Check current point balance
- `get-stay-info`: View stay details and history
- `get-contract-stats`: Overall platform statistics

## 🚀 Quick Start

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/stayrewards.git
cd stayrewards
```

2. Check the contract:
```bash
clarinet check
```

3. Run tests:
```bash
clarinet test
```

4. Deploy locally:
```bash
clarinet integrate
```

## 💡 Usage Examples

### Hotel Registration
```clarity
(contract-call? .stayrewards register-hotel "Grand Hotel" u10)
```

### Guest Registration  
```clarity
(contract-call? .stayrewards register-guest)
```

### Recording a Stay
```clarity
(contract-call? .stayrewards record-stay 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u500)
```

### Redeeming Points
```clarity
(contract-call? .stayrewards redeem-points u1000)
```

## 🏆 Tier System

| Tier | Stays Required | Benefits |
|------|----------------|----------|
| Bronze | 0-4 stays | Basic rewards |
| Silver | 5-9 stays | Enhanced rewards |
| Gold | 10-19 stays | Premium rewards |
| Platinum | 20+ stays | Exclusive benefits |

## 🔒 Security Features

- Input validation on all parameters
- Proper error handling with descriptive error codes
- Authorization checks for sensitive operations
- Protection against duplicate registrations
- Immutable stay records for audit trails

## 📊 Contract Statistics

The contract tracks:
- Total registered hotels
- Total registered guests
- Total points issued across the platform
- Individual guest activity and tier progression

## 🛠️ Development

### Error Codes
- `u100`: Owner only operation
- `u101`: Resource not found
- `u102`: Insufficient points
- `u103`: Invalid amount
- `u104`: Hotel not registered
- `u105`: Already registered
- `u106`: Invalid stay
- `u107`: Unauthorized operation

### Testing
Comprehensive test suite covering:
- Hotel registration and management
- Guest profile creation and updates
- Stay recording and completion
- Point earning and redemption
- Tier system progression
- Error handling scenarios

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

