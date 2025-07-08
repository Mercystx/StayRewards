;; StayRewards - Decentralized Hotel Loyalty Program
;; A smart contract for managing hotel loyalty points and rewards

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

;; Data Variables
(define-data-var total-hotels uint u0)
(define-data-var total-guests uint u0)
(define-data-var total-points-issued uint u0)

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
    is-completed: bool
})

(define-map guest-points principal uint)
(define-map stay-counter uint uint)

;; Initialize stay counter
(map-set stay-counter u0 u0)

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
            is-completed: false
        })
        
        ;; Update counters
        (map-set stay-counter u0 stay-id)
        
        ;; Award points to guest - now properly validated
        (let ((award-result (award-points guest points-earned)))
            (unwrap! award-result err-invalid-amount)
        )
        
        (ok stay-id)
    )
)

;; Complete a hotel stay
(define-public (complete-stay (stay-id uint))
    (let (
        (stay-data (unwrap! (map-get? hotel-stays stay-id) err-not-found))
        (hotel-principal tx-sender)
        (guest-principal (get guest stay-data))
    )
        (asserts! (is-eq (get hotel stay-data) hotel-principal) err-unauthorized)
        (asserts! (not (get is-completed stay-data)) err-invalid-stay)
        
        (map-set hotel-stays stay-id (merge stay-data {
            check-out-block: stacks-block-height,
            is-completed: true
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
        
        (ok true)
    )
)

;; Award points to a guest
(define-private (award-points (guest principal) (points uint))
    (let (
        (current-points (default-to u0 (map-get? guest-points guest)))
        (guest-data (unwrap! (map-get? guest-profiles guest) err-not-found))
    )
        (map-set guest-points guest (+ current-points points))
        (map-set guest-profiles guest (merge guest-data {
            total-points: (+ (get total-points guest-data) points),
            last-activity: stacks-block-height
        }))
        
        (var-set total-points-issued (+ (var-get total-points-issued) points))
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

;; Get contract statistics
(define-read-only (get-contract-stats)
    {
        total-hotels: (var-get total-hotels),
        total-guests: (var-get total-guests),
        total-points-issued: (var-get total-points-issued)
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