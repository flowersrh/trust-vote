;; TrustVote - Simple DAO Voting Contract

(define-constant MAX_DESC u200)
(define-constant ERR_EMPTY_DESC u100)
(define-constant ERR_PROPOSAL_NOT_FOUND u101)
(define-constant ERR_ALREADY_VOTED u102)
(define-constant ERR_VOTING_NOT_STARTED u103)
(define-constant ERR_VOTING_ENDED u104)

(define-data-var proposal-counter uint u0)

;; Map to store proposals
(define-map proposals  
  { id: uint }  
  {    
    creator: principal,
    description: (string-utf8 200),
    start-block: uint,
    end-block: uint,
    yes: uint,
    no: uint
  })

;; Map to track votes
(define-map votes  
  { id: uint, voter: principal }  
  { voted: bool })

;; Submit a new proposal
(define-public (create-proposal (desc (string-utf8 200)) (duration uint))
  (let (
    (id (var-get proposal-counter))
    (start stacks-block-height)
    (end (+ stacks-block-height duration))
  )
    (begin
      (asserts! (> (len desc) u0) (err ERR_EMPTY_DESC))
      (map-set proposals { id: id } {
        creator: tx-sender,
        description: desc,
        start-block: start,
        end-block: end,
        yes: u0,
        no: u0
      })
      (var-set proposal-counter (+ id u1))
      (ok { proposal-id: id, start: start, end: end })
    )))

;; Vote on a proposal
(define-public (vote (id uint) (support bool))
  (let (
    (proposal (unwrap! (map-get? proposals { id: id }) (err ERR_PROPOSAL_NOT_FOUND)))
    (has-voted (is-some (map-get? votes { id: id, voter: tx-sender })))
  )
    (begin
      (asserts! (not has-voted) (err ERR_ALREADY_VOTED))
      (asserts! (>= stacks-block-height (get start-block proposal)) (err ERR_VOTING_NOT_STARTED))
      (asserts! (<= stacks-block-height (get end-block proposal)) (err ERR_VOTING_ENDED))
      
      ;; Record vote
      (map-set votes { id: id, voter: tx-sender } { voted: true })
      
      ;; Tally vote
      (if support
        (map-set proposals { id: id } (merge proposal { yes: (+ (get yes proposal) u1) }))
        (map-set proposals { id: id } (merge proposal { no: (+ (get no proposal) u1) })))
      
      (ok { voted: support, proposal-id: id })
    )))

;; Read-only: Get proposal data
(define-read-only (get-proposal (id uint))
  (map-get? proposals { id: id }))

;; Read-only: Has voter already voted?
(define-read-only (has-voted (id uint) (voter principal))
  (is-some (map-get? votes { id: id, voter: voter })))

;; Read-only: Get current proposal counter
(define-read-only (get-proposal-count)
  (var-get proposal-counter))

;; Read-only: Get proposal results
(define-read-only (get-proposal-results (id uint))
  (match (map-get? proposals { id: id })
    proposal (ok {
      yes: (get yes proposal),
      no: (get no proposal),
      total: (+ (get yes proposal) (get no proposal)),
      ended: (> stacks-block-height (get end-block proposal))
    })
    (err ERR_PROPOSAL_NOT_FOUND)))
