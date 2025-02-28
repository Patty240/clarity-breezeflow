;; BreezeFlow Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-weather (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-rating (err u103))
(define-constant err-invalid-temperature (err u104))

;; Data Variables
(define-map authorized-oracles principal bool)
(define-map weather-data 
  { location: (string-ascii 64) }
  { temperature: int,
    conditions: (string-ascii 32),
    timestamp: uint,
    updated-by: principal })

(define-map activities
  { location: (string-ascii 64),
    condition: (string-ascii 32) }
  { suggestions: (list 10 (string-ascii 64)),
    ratings: uint,
    total-votes: uint })

;; Events
(define-data-var last-event-id uint u0)
(define-map events 
  { id: uint }
  { event-type: (string-ascii 32),
    data: (string-ascii 256) })

;; Authorization Functions
(define-public (add-oracle (oracle principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set authorized-oracles oracle true))))

(define-public (remove-oracle (oracle principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-delete authorized-oracles oracle))))

;; Weather Functions
(define-private (validate-temperature (temp int))
  (and (>= temp -100) (<= temp 150)))

(define-public (submit-weather (location (string-ascii 64)) (temperature int) (conditions (string-ascii 32)))
  (begin
    (asserts! (is-authorized tx-sender) err-unauthorized)
    (asserts! (validate-temperature temperature) err-invalid-temperature)
    (map-set weather-data
      { location: location }
      { temperature: temperature,
        conditions: conditions,
        timestamp: block-height,
        updated-by: tx-sender })
    (log-event "weather-update" location)
    (ok true)))

;; Activity Functions
(define-public (add-activity (location (string-ascii 64)) (condition (string-ascii 32)) (activity (string-ascii 64)))
  (let ((current-activities (default-to { suggestions: (list), ratings: u0, total-votes: u0 }
          (map-get? activities { location: location, condition: condition }))))
    (ok (map-set activities
      { location: location, condition: condition }
      { suggestions: (append (get suggestions current-activities) activity),
        ratings: (get ratings current-activities),
        total-votes: (get total-votes current-activities) }))))

(define-public (rate-activity (location (string-ascii 64)) (condition (string-ascii 32)) (rating uint))
  (begin
    (asserts! (<= rating u5) err-invalid-rating)
    (let ((current-data (unwrap! (map-get? activities { location: location, condition: condition }) err-invalid-weather)))
      (ok (map-set activities
        { location: location, condition: condition }
        { suggestions: (get suggestions current-data),
          ratings: (+ (get ratings current-data) rating),
          total-votes: (+ (get total-votes current-data) u1) })))))

;; Read Only Functions
(define-read-only (get-weather (location (string-ascii 64)))
  (ok (map-get? weather-data { location: location })))

(define-read-only (get-activities (location (string-ascii 64)) (condition (string-ascii 32)))
  (ok (map-get? activities { location: location, condition: condition })))

(define-read-only (get-activity-rating (location (string-ascii 64)) (condition (string-ascii 32)))
  (let ((activity-data (map-get? activities { location: location, condition: condition })))
    (if (is-some activity-data)
      (let ((data (unwrap-panic activity-data)))
        (ok (/ (get ratings data) (get total-votes data))))
      (err err-invalid-weather))))

;; Private Functions
(define-private (is-authorized (caller principal))
  (default-to false (map-get? authorized-oracles caller)))

(define-private (log-event (event-type (string-ascii 32)) (data (string-ascii 256)))
  (let ((event-id (+ (var-get last-event-id) u1)))
    (var-set last-event-id event-id)
    (map-set events
      { id: event-id }
      { event-type: event-type, data: data })))
