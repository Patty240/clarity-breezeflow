;; BreezeFlow Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-weather (err u101))
(define-constant err-unauthorized (err u102))

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
    ratings: uint })

;; Public Functions
(define-public (submit-weather (location (string-ascii 64)) (temperature int) (conditions (string-ascii 32)))
  (begin
    (asserts! (is-authorized tx-sender) err-unauthorized)
    (ok (map-set weather-data
      { location: location }
      { temperature: temperature,
        conditions: conditions,
        timestamp: block-height,
        updated-by: tx-sender }))))

(define-public (add-activity (location (string-ascii 64)) (condition (string-ascii 32)) (activity (string-ascii 64)))
  (let ((current-activities (default-to { suggestions: (list), ratings: u0 }
          (map-get? activities { location: location, condition: condition }))))
    (ok (map-set activities
      { location: location, condition: condition }
      { suggestions: (append (get suggestions current-activities) activity),
        ratings: (get ratings current-activities) }))))

;; Read Only Functions
(define-read-only (get-weather (location (string-ascii 64)))
  (ok (map-get? weather-data { location: location })))

(define-read-only (get-activities (location (string-ascii 64)) (condition (string-ascii 32)))
  (ok (map-get? activities { location: location, condition: condition })))

;; Private Functions
(define-private (is-authorized (caller principal))
  (default-to false (map-get? authorized-oracles caller)))
