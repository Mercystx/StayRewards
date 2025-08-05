# StayRewards 🏨✨

A decentralized hotel loyalty program built on Stacks blockchain using Clarity smart contracts. StayRewards revolutionizes the hospitality industry by creating a transparent, interoperable loyalty system that works across multiple hotels and gives users true ownership of their rewards, including collectible NFT stay certificates.

## 🌟 Features

- **Decentralized Loyalty Program**: Hotels can register and offer points to guests
- **Cross-Hotel Compatibility**: Earn and redeem points across participating hotels
- **NFT Stay Certificates**: Mint unique NFTs for each completed stay as collectible proof of visit
- **Transparent Tier System**: Automatic tier upgrades based on stay history
- **Smart Point Allocation**: Customizable point rates per hotel
- **Immutable Stay Records**: All stays are permanently recorded on-chain
- **Guest Profiles**: Comprehensive tracking of stays, points, and tier status
- **Certificate Trading**: Transfer NFT stay certificates between users

## 🏗️ Smart Contract Architecture

### Core Components

- **Hotel Management**: Registration, activation/deactivation, and point rate configuration
- **Guest Profiles**: User registration, point balances, and tier progression
- **Stay Tracking**: Complete stay lifecycle from check-in to completion
- **Point System**: Earning, tracking, and redemption of loyalty points
- **Tier System**: Bronze, Silver, Gold, and Platinum levels based on stay count
- **NFT Certificates**: Unique collectible tokens for each completed stay

### Key Functions

#### For Hotels
- `register-hotel`: Register hotel with custom point rates
- `record-stay`: Record guest stays and automatically award points
- `complete-stay`: Mark stays as completed, update guest profiles, and mint NFT certificate

#### For Guests
- `register-guest`: Create a new guest profile
- `redeem-points`: Redeem accumulated points for rewards
- `transfer-certificate`: Transfer NFT stay certificates to other users

#### Read-Only Functions
- `get-hotel-info`: Retrieve hotel details and status
- `get-guest-profile`: Access guest profile information
- `get-guest-points`: Check current point balance
- `get-stay-info`: View stay details and history
- `get-nft-metadata`: Retrieve NFT certificate metadata
- `get-certificate-owner`: Check current owner of an NFT certificate
- `guest-owns-certificate`: Check if a guest owns a specific certificate
- `get-total-certificates`: Get total number of certificates minted
- `get-contract-stats`: Overall platform statistics including total certificates

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

### Completing a Stay (Mints NFT Certificate)
```clarity
(contract-call? .stayrewards complete-stay u1)
```

### Redeeming Points
```clarity
(contract-call? .stayrewards redeem-points u1000)
```

### Transferring NFT Certificate
```clarity
(contract-call? .stayrewards transfer-certificate u1 tx-sender 'ST2PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Checking Guest Certificates
```clarity
;; Check if guest owns a specific certificate
(contract-call? .stayrewards guest-owns-certificate 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u1)

;; Get total certificates minted
(contract-call? .stayrewards get-total-certificates)
```

## 🎨 NFT Stay Certificates

Each completed stay generates a unique NFT certificate containing:
- **Stay ID**: Reference to the original stay record
- **Hotel Name**: Name of the hotel where the stay occurred
- **Guest**: Principal address of the guest
- **Completion Date**: Block height when the stay was completed
- **Amount Spent**: Total amount spent during the stay
- **Points Earned**: Loyalty points earned from the stay

### Certificate Benefits
- **Proof of Visit**: Immutable proof of hotel stays
- **Collectible Value**: Unique tokens that can appreciate over time
- **Transferable**: Trade certificates with other users
- **Portfolio Tracking**: Build a collection of travel experiences

## 🏆 Tier System

| Tier | Stays Required | Benefits |
|------|----------------|----------|
| Bronze | 0-4 stays | Basic rewards + NFT certificates |
| Silver | 5-9 stays | Enhanced rewards + NFT certificates |
| Gold | 10-19 stays | Premium rewards + NFT certificates |
| Platinum | 20+ stays | Exclusive benefits + NFT certificates |

## 🔒 Security Features

- Input validation on all parameters
- Proper error handling with descriptive error codes
- Authorization checks for sensitive operations
- Protection against duplicate registrations
- Immutable stay records for audit trails
- NFT ownership verification for transfers
- Protected NFT minting process

## 📊 Contract Statistics

The contract tracks:
- Total registered hotels
- Total registered guests
- Total points issued across the platform
- Total NFT certificates minted
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
- `u108`: NFT not found
- `u109`: Not NFT owner

### Testing
Comprehensive test suite covering:
- Hotel registration and management
- Guest profile creation and updates
- Stay recording and completion
- Point earning and redemption
- Tier system progression
- NFT certificate minting and transfers
- Error handling scenarios

## 🎯 NFT Use Cases

- **Travel Portfolio**: Build a digital collection of hotel experiences
- **Loyalty Rewards**: Special benefits for certificate holders
- **Social Proof**: Share travel achievements on social platforms
- **Marketplace Trading**: Buy and sell rare hotel stay certificates
- **Gaming Integration**: Use certificates in travel-based games
- **Membership Benefits**: Access exclusive events or services

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

