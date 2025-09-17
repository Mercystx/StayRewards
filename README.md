# StayRewards 🏨✨🌉

A decentralized hotel loyalty program built on Stacks blockchain using Clarity smart contracts. StayRewards revolutionizes the hospitality industry by creating a transparent, interoperable loyalty system that works across multiple hotels and blockchains, giving users true ownership of their rewards, including collectible NFT stay certificates.

## 🌟 Features

- **Decentralized Loyalty Program**: Hotels can register and offer points to guests
- **Cross-Hotel Compatibility**: Earn and redeem points across participating hotels
- **Cross-Chain Points Bridge**: Transfer points seamlessly between Stacks, Ethereum, and Polygon blockchains
- **NFT Stay Certificates**: Mint unique NFTs for each completed stay as collectible proof of visit
- **Transparent Tier System**: Automatic tier upgrades based on stay history
- **Smart Point Allocation**: Customizable point rates per hotel
- **Immutable Stay Records**: All stays are permanently recorded on-chain
- **Guest Profiles**: Comprehensive tracking of stays, points, and tier status
- **Certificate Trading**: Transfer NFT stay certificates between users
- **Multi-Chain Interoperability**: Access your points across supported blockchain networks

## 🌉 Cross-Chain Bridge

The revolutionary cross-chain bridge allows guests to transfer their loyalty points between different blockchain networks, providing unprecedented flexibility and access to diverse DeFi ecosystems.

### Supported Chains
- **Stacks** (Native)
- **Ethereum** 
- **Polygon**

### Bridge Features
- **Secure Point Transfers**: Burn points on source chain, mint on target chain
- **Authorized Operators**: Only verified bridge operators can process incoming transactions
- **Duplicate Protection**: Prevention of double-spending and replay attacks
- **Chain Management**: Dynamic addition/removal of supported chains
- **Bridge Statistics**: Track total points moved across chains
- **Emergency Controls**: Admin can pause/resume bridge operations

## 🏗️ Smart Contract Architecture

### Core Components

- **Hotel Management**: Registration, activation/deactivation, and point rate configuration
- **Guest Profiles**: User registration, point balances, and tier progression
- **Stay Tracking**: Complete stay lifecycle from check-in to completion
- **Point System**: Earning, tracking, and redemption of loyalty points
- **Tier System**: Bronze, Silver, Gold, and Platinum levels based on stay count
- **NFT Certificates**: Unique collectible tokens for each completed stay
- **Cross-Chain Bridge**: Secure point transfers between blockchain networks

### Key Functions

#### For Hotels
- `register-hotel`: Register hotel with custom point rates
- `record-stay`: Record guest stays and automatically award points
- `complete-stay`: Mark stays as completed, update guest profiles, and mint NFT certificate

#### For Guests
- `register-guest`: Create a new guest profile
- `redeem-points`: Redeem accumulated points for rewards
- `transfer-certificate`: Transfer NFT stay certificates to other users
- `bridge-points-out`: Transfer points to another blockchain network

#### Cross-Chain Bridge Functions
- `bridge-points-out`: Initiate point transfer to another chain
- `bridge-points-in`: Process incoming points from another chain (operators only)
- `add-bridge-operator`: Add authorized bridge operator (admin only)
- `remove-bridge-operator`: Remove bridge operator (admin only)
- `add-supported-chain`: Add new blockchain support (admin only)
- `remove-supported-chain`: Remove blockchain support (admin only)
- `toggle-bridge`: Enable/disable bridge functionality (admin only)

#### Read-Only Functions
- `get-hotel-info`: Retrieve hotel details and status
- `get-guest-profile`: Access guest profile information
- `get-guest-points`: Check current point balance
- `get-stay-info`: View stay details and history
- `get-nft-metadata`: Retrieve NFT certificate metadata
- `get-certificate-owner`: Check current owner of an NFT certificate
- `guest-owns-certificate`: Check if a guest owns a specific certificate
- `get-total-certificates`: Get total number of certificates minted
- `is-chain-supported`: Check if a blockchain is supported for bridging
- `is-bridge-operator`: Verify if a principal is an authorized bridge operator
- `get-bridge-transaction`: Get outgoing bridge transaction details
- `get-incoming-bridge-transaction`: Get incoming bridge transaction details
- `is-bridge-enabled`: Check if bridge is currently active
- `get-bridge-stats`: Get comprehensive bridge statistics
- `get-contract-stats`: Overall platform statistics including bridge data

## 🚀 Quick Start

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing
- Bridge operator setup for cross-chain functionality

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

### Cross-Chain Bridge Usage

#### Bridge Points Out (to Ethereum)
```clarity
(contract-call? .stayrewards bridge-points-out u1000 "ethereum" "0x742d35Cc6634C0532925a3b8D17Cc07d6b7bD5a1" "0x123abc...")
```

#### Process Incoming Points (Bridge Operator Only)
```clarity
(contract-call? .stayrewards bridge-points-in 
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
    u1000 
    "ethereum" 
    "0x742d35Cc6634C0532925a3b8D17Cc07d6b7bD5a1" 
    "0x456def...")
```

#### Check Bridge Status
```clarity
;; Check if bridge is enabled
(contract-call? .stayrewards is-bridge-enabled)

;; Check supported chains
(contract-call? .stayrewards is-chain-supported "ethereum")
(contract-call? .stayrewards is-chain-supported "polygon")

;; Get bridge statistics
(contract-call? .stayrewards get-bridge-stats)
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

## 🌉 Cross-Chain Benefits

### For Guests
- **Liquidity Access**: Use points in different DeFi ecosystems
- **Lower Fees**: Choose optimal blockchain for transactions
- **Broader Utility**: Access more redemption options across chains
- **Portfolio Diversification**: Spread assets across multiple networks

### For Hotels
- **Expanded Reach**: Attract guests from different blockchain communities
- **Reduced Friction**: Guests can use points regardless of their preferred chain
- **Competitive Advantage**: First-to-market with cross-chain loyalty points

### Bridge Security Features
- **Authorized Operators**: Only verified entities can process cross-chain transactions
- **Transaction Uniqueness**: Each bridge transaction has a unique hash to prevent duplicates
- **Admin Controls**: Emergency pause functionality and operator management
- **Audit Trail**: Complete record of all cross-chain transfers

## 🏆 Tier System

| Tier | Stays Required | Benefits |
|------|----------------|----------|
| Bronze | 0-4 stays | Basic rewards + NFT certificates |
| Silver | 5-9 stays | Enhanced rewards + NFT certificates |
| Gold | 10-19 stays | Premium rewards + NFT certificates |
| Platinum | 20+ stays | Exclusive benefits + NFT certificates + Priority bridge processing |

## 🔒 Security Features

- Input validation on all parameters
- Proper error handling with descriptive error codes
- Authorization checks for sensitive operations
- Protection against duplicate registrations
- Immutable stay records for audit trails
- NFT ownership verification for transfers
- Protected NFT minting process
- **Bridge Security**: Authorized operators, duplicate transaction prevention, emergency controls
- **Cross-Chain Validation**: Chain support verification, transaction hash uniqueness

## 📊 Contract Statistics

The contract tracks:
- Total registered hotels
- Total registered guests
- Total points issued across the platform
- Total NFT certificates minted
- **Cross-Chain Metrics**: Points bridged in/out, bridge status
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
- `u110`: Bridge not authorized
- `u111`: Invalid chain
- `u112`: Bridge paused
- `u113`: Invalid bridge operator
- `u114`: Duplicate bridge transaction

### Testing
Comprehensive test suite covering:
- Hotel registration and management
- Guest profile creation and updates
- Stay recording and completion
- Point earning and redemption
- Tier system progression
- NFT certificate minting and transfers
- **Cross-chain bridge functionality**
- **Bridge operator management**
- **Chain support management**
- **Bridge security and validation**
- Error handling scenarios

## 🎯 NFT Use Cases

- **Travel Portfolio**: Build a digital collection of hotel experiences
- **Loyalty Rewards**: Special benefits for certificate holders
- **Social Proof**: Share travel achievements on social platforms
- **Marketplace Trading**: Buy and sell rare hotel stay certificates
- **Gaming Integration**: Use certificates in travel-based games
- **Membership Benefits**: Access exclusive events or services
- **Cross-Chain Collectibles**: Trade certificates across different blockchain networks

## 🌐 Multi-Chain Integration

### Bridge Architecture
The cross-chain bridge operates through a hub-and-spoke model with Stacks as the primary hub:

```
Ethereum ↔ Stacks (Hub) ↔ Polygon
```

### Bridge Operators
Authorized bridge operators run secure infrastructure to:
- Monitor cross-chain transactions
- Validate point transfers
- Process incoming bridge requests
- Maintain transaction integrity

### Supported Operations
- **Outgoing Transfers**: Guest initiates point transfer to target chain
- **Incoming Transfers**: Bridge operator processes points from source chain
- **Chain Management**: Admin controls for supported blockchain networks
- **Operator Management**: Authorization and access control for bridge operators

## 🚦 Bridge Operations Guide

### For Guests
1. **Check Bridge Status**: Verify bridge is enabled and target chain is supported
2. **Initiate Transfer**: Call `bridge-points-out` with target chain and address
3. **Monitor Transaction**: Points are burned on Stacks and pending on target chain
4. **Confirm Receipt**: Bridge operators process the transaction on target chain

### For Bridge Operators
1. **Authorization**: Must be added as authorized operator by contract admin
2. **Monitor Chains**: Watch for incoming transfer requests from supported chains
3. **Process Transfers**: Call `bridge-points-in` to mint points on Stacks
4. **Transaction Validation**: Ensure transaction uniqueness and validity

### For Administrators
1. **Operator Management**: Add/remove authorized bridge operators
2. **Chain Management**: Add support for new blockchain networks
3. **Emergency Controls**: Pause/resume bridge operations if needed
4. **Monitoring**: Track bridge statistics and transaction volumes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality, including bridge features
5. Submit a pull request

*Built with ❤️ on Stacks blockchain for the future of decentralized hospitality rewards*