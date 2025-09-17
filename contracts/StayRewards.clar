;; StayRewards - Decentralized Hotel Loyalty Program with NFT Stay Certificates
;; A smart contract for managing hotel loyalty points, rewards, and collectible stay NFTs
;; Now with Cross-Chain Points Bridge functionality

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-insufficient-points (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-hotel-not-registered (err u104))
(define-constant err-already-registered (err u105))
(define-constant err-invalid-stay (err u106))
(define-constant err-unauthorized (err u107))
(define-constant err-nft-not-found (err u108))
(define-constant err-not-nft-owner (err u109))
(define-constant err-bridge-not-authorized (err u110))
(define-constant err-invalid-chain (err u111))
(define-constant err-bridge-paused (err u112))
(define-constant err-invalid-bridge-operator (err u113))
(define-constant err-duplicate-bridge-tx (err u114))

;; NFT Definition
(define-non-fungible-token stay-certificate uint)

;; Data Variables
(define-data-var total-hotels uint u0)
(define-data-var total-guests uint u0)
(define-data-var total-points-issued uint u0)
(define-data-var last-token-id uint u0)
(define-data-var bridge-enabled bool true)
(define-data-var total-points-bridged-out uint u0)
(define-data-var total-points-bridged-in uint u0)

;; Data Maps
(define-map hotels principal {
    name: (string-ascii 50),
    is-active: bool,
    points-rate: uint,
    registration-block: uint
})

(define-map guest-profiles principal {
    total-points: uint,
    total-stays: uint,
    tier-level: uint,
    last-activity: uint
})

(define-map hotel-stays uint {
    guest: principal,
    hotel: principal,
    check-in-block: uint,
    check-out-block: uint,
    points-earned: uint,
    amount-spent: uint,
    is-completed: bool,
    nft-id: (optional uint)
})

(define-map guest-points principal uint)
(define-map stay-counter uint uint)

;; NFT Metadata Map
(define-map nft-metadata uint {
    stay-id: uint,
    hotel-name: (string-ascii 50),
    guest: principal,
    completion-date: uint,
    amount-spent: uint,
    points-earned: uint
})

;; Cross-Chain Bridge Maps
(define-map bridge-operators principal bool)
(define-map supported-chains (string-ascii 20) bool)
(define-map bridge-transactions (string-ascii 64) {
    guest: principal,
    amount: uint,
    target-chain: (string-ascii 20),
    target-address: (string-ascii 64),
    timestamp: uint,
    is-processed: bool
})

(define-map incoming-bridge-txs (string-ascii 64) {
    guest: principal,
    amount: uint,
    source-chain: (string-ascii 20),
    source-address: (string-ascii 64),
    timestamp: uint,
    is-processed: bool
})

;; Initialize stay counter and bridge settings
(map-set stay-counter u0 u0)
(map-set bridge-operators contract-owner true)
(map-set supported-chains "ethereum" true)
(map-set supported-chains "polygon" true)

;; Public Functions

;; Register a new hotel
(define-public (register-hotel (name (string-ascii 50)) (points-rate uint))
    (let ((hotel-principal tx-sender))
        (asserts! (> (len name) u0) err-invalid-amount)
        (asserts! (> points-rate u0) err-invalid-amount)
        (asserts! (is-none (map-get? hotels hotel-principal)) err-already-registered)
        
        (map-set hotels hotel-principal {
            name: name,
            is-active: true,
            points-rate: points-rate,
            registration-block: stacks-block-height
        })
        
        (var-set total-hotels (+ (var-get total-hotels) u1))
        (ok true)
    )
)

;; Register a new guest
(define-public (register-guest)
    (let ((guest-principal tx-sender))
        (asserts! (is-none (map-get? guest-profiles guest-principal)) err-already-registered)
        
        (map-set guest-profiles guest-principal {
            total-points: u0,
            total-stays: u0,
            tier-level: u1,
            last-activity: stacks-block-height
        })
        
        (map-set guest-points guest-principal u0)
        (var-set total-guests (+ (var-get total-guests) u1))
        (ok true)
    )
)

;; Record a hotel stay
(define-public (record-stay (guest principal) (amount-spent uint))
    (let (
        (hotel-principal tx-sender)
        (hotel-data (unwrap! (map-get? hotels hotel-principal) err-hotel-not-registered))
        (guest-data (unwrap! (map-get? guest-profiles guest) err-not-found))
        (stay-id (+ (default-to u0 (map-get? stay-counter u0)) u1))
        (points-rate (get points-rate hotel-data))
        (points-earned (* amount-spent points-rate))
    )
        (asserts! (get is-active hotel-data) err-hotel-not-registered)
        (asserts! (> amount-spent u0) err-invalid-amount)
        (asserts! (> points-rate u0) err-invalid-amount)
        (asserts! (>= (get total-points guest-data) u0) err-not-found)
        
        ;; Record the stay
        (map-set hotel-stays stay-id {
            guest: guest,
            hotel: hotel-principal,
            check-in-block: stacks-block-height,
            check-out-block: u0,
            points-earned: points-earned,
            amount-spent: amount-spent,
            is-completed: false,
            nft-id: none
        })
        
        ;; Update counters
        (map-set stay-counter u0 stay-id)
        
        ;; Award points to guest
        (unwrap! (award-points guest points-earned) err-invalid-amount)
        
        (ok stay-id)
    )
)

;; Complete a hotel stay and mint NFT certificate
(define-public (complete-stay (stay-id uint))
    (let (
        (stay-data (unwrap! (map-get? hotel-stays stay-id) err-not-found))
        (hotel-principal tx-sender)
        (guest-principal (get guest stay-data))
        (hotel-data (unwrap! (map-get? hotels hotel-principal) err-hotel-not-registered))
    )
        (asserts! (is-eq (get hotel stay-data) hotel-principal) err-unauthorized)
        (asserts! (not (get is-completed stay-data)) err-invalid-stay)
        (asserts! (is-none (get nft-id stay-data)) err-invalid-stay)
        
        ;; Mint NFT certificate
        (let ((nft-id (+ (var-get last-token-id) u1)))
            ;; Update last token ID
            (var-set last-token-id nft-id)
            
            ;; Mint NFT to guest
            (unwrap! (nft-mint? stay-certificate nft-id guest-principal) err-invalid-stay)
            
            ;; Store NFT metadata
            (map-set nft-metadata nft-id {
                stay-id: stay-id,
                hotel-name: (get name hotel-data),
                guest: guest-principal,
                completion-date: stacks-block-height,
                amount-spent: (get amount-spent stay-data),
                points-earned: (get points-earned stay-data)
            })
            
            ;; Update stay with completion and NFT ID
            (map-set hotel-stays stay-id (merge stay-data {
                check-out-block: stacks-block-height,
                is-completed: true,
                nft-id: (some nft-id)
            }))
            
            ;; Update guest profile with proper validation
            (let ((guest-data (unwrap! (map-get? guest-profiles guest-principal) err-not-found)))
                (let ((new-stay-count (+ (get total-stays guest-data) u1)))
                    (map-set guest-profiles guest-principal (merge guest-data {
                        total-stays: new-stay-count,
                        last-activity: stacks-block-height,
                        tier-level: (calculate-tier-level new-stay-count)
                    }))
                )
            )
            
            (ok nft-id)
        )
    )
)

;; Transfer NFT stay certificate
(define-public (transfer-certificate (nft-id uint) (sender principal) (recipient principal))
    (let ((current-owner (unwrap! (nft-get-owner? stay-certificate nft-id) err-nft-not-found)))
        ;; Verify that the sender is the transaction sender
        (asserts! (is-eq tx-sender sender) err-unauthorized)
        ;; Verify that the sender actually owns the NFT
        (asserts! (is-eq current-owner sender) err-not-nft-owner)
        ;; Verify that sender and recipient are different
        (asserts! (not (is-eq sender recipient)) err-invalid-amount)
        
        ;; Perform the transfer
        (nft-transfer? stay-certificate nft-id sender recipient)
    )
)

;; Cross-Chain Bridge Functions

;; Bridge points to another chain
(define-public (bridge-points-out (amount uint) (target-chain (string-ascii 20)) (target-address (string-ascii 64)) (tx-hash (string-ascii 64)))
    (let (
        (guest-principal tx-sender)
        (current-points (default-to u0 (map-get? guest-points guest-principal)))
        (guest-data (unwrap! (map-get? guest-profiles guest-principal) err-not-found))
    )
        ;; Validate inputs
        (asserts! (var-get bridge-enabled) err-bridge-paused)
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (> (len target-chain) u0) err-invalid-chain)
        (asserts! (> (len target-address) u0) err-invalid-amount)
        (asserts! (> (len tx-hash) u0) err-invalid-amount)
        (asserts! (default-to false (map-get? supported-chains target-chain)) err-invalid-chain)
        (asserts! (>= current-points amount) err-insufficient-points)
        (asserts! (is-none (map-get? bridge-transactions tx-hash)) err-duplicate-bridge-tx)
        
        ;; Burn points from guest account
        (map-set guest-points guest-principal (- current-points amount))
        
        ;; Record bridge transaction
        (map-set bridge-transactions tx-hash {
            guest: guest-principal,
            amount: amount,
            target-chain: target-chain,
            target-address: target-address,
            timestamp: stacks-block-height,
            is-processed: false
        })
        
        ;; Update guest profile
        (map-set guest-profiles guest-principal (merge guest-data {
            last-activity: stacks-block-height
        }))
        
        ;; Update total points bridged out
        (var-set total-points-bridged-out (+ (var-get total-points-bridged-out) amount))
        
        (ok true)
    )
)

;; Process incoming bridge transaction (only by authorized bridge operators)
(define-public (bridge-points-in (guest principal) (amount uint) (source-chain (string-ascii 20)) (source-address (string-ascii 64)) (tx-hash (string-ascii 64)))
    (let (
        (operator tx-sender)
    )
        ;; Validate operator authorization first
        (asserts! (default-to false (map-get? bridge-operators operator)) err-bridge-not-authorized)
        (asserts! (var-get bridge-enabled) err-bridge-paused)
        
        ;; Validate all inputs
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (> (len source-chain) u0) err-invalid-chain)
        (asserts! (> (len source-address) u0) err-invalid-amount)
        (asserts! (> (len tx-hash) u0) err-invalid-amount)
        (asserts! (default-to false (map-get? supported-chains source-chain)) err-invalid-chain)
        (asserts! (is-none (map-get? incoming-bridge-txs tx-hash)) err-duplicate-bridge-tx)
        
        ;; Validate guest exists and amount is valid, then process
        (let ((guest-data (unwrap! (map-get? guest-profiles guest) err-not-found))
              (validated-guest guest)
              (validated-amount amount))
            ;; Additional validation after binding
            (asserts! (> validated-amount u0) err-invalid-amount)
            (asserts! (not (is-eq validated-guest 'SP000000000000000000002Q6VF78)) err-invalid-amount)
            
            ;; Record incoming transaction
            (map-set incoming-bridge-txs tx-hash {
                guest: validated-guest,
                amount: validated-amount,
                source-chain: source-chain,
                source-address: source-address,
                timestamp: stacks-block-height,
                is-processed: true
            })
            
            ;; Mint points to guest account using validated parameters
            (unwrap! (award-points validated-guest validated-amount) err-invalid-amount)
            
            ;; Update total points bridged in
            (var-set total-points-bridged-in (+ (var-get total-points-bridged-in) validated-amount))
            
            (ok true)
        )
    )
)

;; Admin Functions for Bridge Management

;; Add bridge operator
(define-public (add-bridge-operator (operator principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; Validate that the operator principal is not null/empty
        (asserts! (not (is-eq operator 'SP000000000000000000002Q6VF78)) err-invalid-amount)
        (map-set bridge-operators operator true)
        (ok true)
    )
)

;; Remove bridge operator
(define-public (remove-bridge-operator (operator principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; Validate that the operator exists and is not the contract owner
        (asserts! (not (is-eq operator contract-owner)) err-unauthorized)
        (asserts! (not (is-eq operator 'SP000000000000000000002Q6VF78)) err-invalid-amount)
        ;; Check that the operator is currently authorized before removing
        (asserts! (default-to false (map-get? bridge-operators operator)) err-not-found)
        (map-set bridge-operators operator false)
        (ok true)
    )
)

;; Add supported chain
(define-public (add-supported-chain (chain (string-ascii 20)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> (len chain) u0) err-invalid-chain)
        (map-set supported-chains chain true)
        (ok true)
    )
)

;; Remove supported chain
(define-public (remove-supported-chain (chain (string-ascii 20)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> (len chain) u0) err-invalid-chain)
        (map-set supported-chains chain false)
        (ok true)
    )
)

;; Toggle bridge enabled/disabled
(define-public (toggle-bridge (enabled bool))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set bridge-enabled enabled)
        (ok true)
    )
)

;; Award points to a guest
(define-private (award-points (guest principal) (points uint))
    (let (
        (current-points (default-to u0 (map-get? guest-points guest)))
        (guest-data (unwrap! (map-get? guest-profiles guest) err-not-found))
        (validated-points points)
    )
        (asserts! (> validated-points u0) err-invalid-amount)
        
        (map-set guest-points guest (+ current-points validated-points))
        (map-set guest-profiles guest (merge guest-data {
            total-points: (+ (get total-points guest-data) validated-points),
            last-activity: stacks-block-height
        }))
        
        (var-set total-points-issued (+ (var-get total-points-issued) validated-points))
        (ok true)
    )
)

;; Redeem points
(define-public (redeem-points (points uint))
    (let (
        (guest-principal tx-sender)
        (current-points (default-to u0 (map-get? guest-points guest-principal)))
        (guest-data (unwrap! (map-get? guest-profiles guest-principal) err-not-found))
    )
        (asserts! (> points u0) err-invalid-amount)
        (asserts! (>= current-points points) err-insufficient-points)
        
        (map-set guest-points guest-principal (- current-points points))
        (map-set guest-profiles guest-principal (merge guest-data {
            last-activity: stacks-block-height
        }))
        
        (ok true)
    )
)

;; Admin function to deactivate hotel
(define-public (deactivate-hotel (hotel principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (let ((hotel-data (unwrap! (map-get? hotels hotel) err-not-found)))
            (asserts! (get is-active hotel-data) err-invalid-amount)
            (map-set hotels hotel (merge hotel-data { is-active: false }))
            (ok true)
        )
    )
)

;; Read-only Functions

;; Get hotel information
(define-read-only (get-hotel-info (hotel principal))
    (map-get? hotels hotel)
)

;; Get guest profile
(define-read-only (get-guest-profile (guest principal))
    (map-get? guest-profiles guest)
)

;; Get guest points balance
(define-read-only (get-guest-points (guest principal))
    (default-to u0 (map-get? guest-points guest))
)

;; Get stay information
(define-read-only (get-stay-info (stay-id uint))
    (map-get? hotel-stays stay-id)
)

;; Get NFT metadata
(define-read-only (get-nft-metadata (nft-id uint))
    (map-get? nft-metadata nft-id)
)

;; Get NFT owner
(define-read-only (get-certificate-owner (nft-id uint))
    (nft-get-owner? stay-certificate nft-id)
)

;; Get last token ID
(define-read-only (get-last-token-id)
    (var-get last-token-id)
)

;; Check if guest owns a specific certificate
(define-read-only (guest-owns-certificate (guest principal) (nft-id uint))
    (is-eq (some guest) (nft-get-owner? stay-certificate nft-id))
)

;; Get total number of certificates minted
(define-read-only (get-total-certificates)
    (var-get last-token-id)
)

;; Bridge-related read-only functions

;; Check if chain is supported
(define-read-only (is-chain-supported (chain (string-ascii 20)))
    (default-to false (map-get? supported-chains chain))
)

;; Check if principal is bridge operator
(define-read-only (is-bridge-operator (operator principal))
    (default-to false (map-get? bridge-operators operator))
)

;; Get bridge transaction info
(define-read-only (get-bridge-transaction (tx-hash (string-ascii 64)))
    (map-get? bridge-transactions tx-hash)
)

;; Get incoming bridge transaction info
(define-read-only (get-incoming-bridge-transaction (tx-hash (string-ascii 64)))
    (map-get? incoming-bridge-txs tx-hash)
)

;; Check if bridge is enabled
(define-read-only (is-bridge-enabled)
    (var-get bridge-enabled)
)

;; Get bridge statistics
(define-read-only (get-bridge-stats)
    {
        total-points-bridged-out: (var-get total-points-bridged-out),
        total-points-bridged-in: (var-get total-points-bridged-in),
        bridge-enabled: (var-get bridge-enabled)
    }
)

;; Get contract statistics
(define-read-only (get-contract-stats)
    {
        total-hotels: (var-get total-hotels),
        total-guests: (var-get total-guests),
        total-points-issued: (var-get total-points-issued),
        total-certificates: (var-get last-token-id),
        total-points-bridged-out: (var-get total-points-bridged-out),
        total-points-bridged-in: (var-get total-points-bridged-in),
        bridge-enabled: (var-get bridge-enabled)
    }
)

;; Calculate tier level based on total stays
(define-read-only (calculate-tier-level (total-stays uint))
    (if (>= total-stays u20)
        u4  ;; Platinum
        (if (>= total-stays u10)
            u3  ;; Gold
            (if (>= total-stays u5)
                u2  ;; Silver
                u1  ;; Bronze
            )
        )
    )
)

;; Get tier name
(define-read-only (get-tier-name (tier-level uint))
    (if (is-eq tier-level u4)
        "Platinum"
        (if (is-eq tier-level u3)
            "Gold"
            (if (is-eq tier-level u2)
                "Silver"
                "Bronze"
            )
        )
    )
)