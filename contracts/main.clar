;; Hosptital DAO
;; 

;; errors
;;
(define-constant UNAUTH_CALLER (err u001))
(define-constant AUTH_CALLER_DOESNT_EXIST (err u010))
(define-constant PATIENT_ALREADY_EXISTS (err u011))
;; constants
;;
(define-constant admin 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; data maps and vars
;;
(define-map authorised_callers {address: principal} {authorised: bool})
(define-map patient_data {id: principal} {name: (string-ascii 20), gender: (string-ascii 1), age: uint, contactNo: uint})

;; private functions
;;

;; public functions
;;

(map-set authorised_callers {address: 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP } {authorised: true})


(define-public (add_authosrised_caller (address principal) (authorised bool))
(begin
(asserts! (is-eq tx-sender admin) UNAUTH_CALLER)

(ok (map-set authorised_callers {address: address} {authorised: authorised}))

)
)


(define-public (add_patient (id principal) (name (string-ascii 20)) (gender (string-ascii 1)) (age uint) (contactNo uint))
(begin 

;; only allows authorised users to add patient data
(asserts! (is-eq (get authorised (unwrap! (map-get? authorised_callers {address: tx-sender}) AUTH_CALLER_DOESNT_EXIST)) true) UNAUTH_CALLER)

;; checks if patient records alreadt exists or not 
(asserts! (is-eq (is-none (map-get? patient_data {id: id})) true) PATIENT_ALREADY_EXISTS)

(ok (map-set patient_data {id: id} {name: name, gender: gender, age: age, contactNo: contactNo}))

)
)