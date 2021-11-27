;; Hosptital DAO
;; 

;; errors
;;
(define-constant UNAUTH_CALLER (err u001))
(define-constant AUTH_CALLER_DOESNT_EXIST (err u010))
(define-constant PATIENT_ALREADY_EXISTS (err u011))
(define-constant PATIENT_DOESNT_EXISTS (err u100))
(define-constant INVALID_GENDER (err u101))

;; constants
;;
(define-constant admin 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; data maps and vars
;;
(define-map authorised_callers {address: principal} {authorised: bool})
(define-map patient_data {id: principal} {name: (string-ascii 20), gender: (string-ascii 1), age: uint, contactNo: uint})
(define-map appointments {doctor_id: principal} {patient_id: principal, date: (string-ascii 10)})

;; private functions
;;
(define-private (is_auth_caller)

(if (is-eq (get authorised (unwrap! (map-get? authorised_callers {address: tx-sender}) false)) true)

true

false
) 


)
(define-private (is_valid_gender (gender (string-ascii 1)) )

(if (is-eq gender "m") true

(if (is-eq gender "f") true 

(if (is-eq gender "o") true

false)))

)

;; public functions
;;

(map-set authorised_callers {address: 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP } {authorised: true})
(map-set authorised_callers {address: 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 } {authorised: false})

(define-public (add_authosrised_caller (address principal) (authorised bool))
(begin

;; check if the funtion is called by admin or not
(asserts! (is-eq tx-sender admin) UNAUTH_CALLER)

(ok (map-set authorised_callers {address: address} {authorised: authorised}))

)
)


(define-public (add_patient_data (id principal) (name (string-ascii 20)) (gender (string-ascii 1)) (age uint) (contactNo uint))
(begin 

;; only allows authorised users to add patient data
(asserts! (is-eq (is_auth_caller) true) UNAUTH_CALLER)

;; checks if patient records already exists or not 
(asserts! (is-eq (is-none (map-get? patient_data {id: id})) true) PATIENT_ALREADY_EXISTS)

;; checks if a valid gender option is entered
(asserts! (is_valid_gender gender) INVALID_GENDER)

(ok (map-set patient_data {id: id} {name: name, gender: gender, age: age, contactNo: contactNo}))

)
)

(define-public (edit_patient_data (id principal) (name (string-ascii 20)) (gender (string-ascii 1)) (age uint) (contactNo uint))
(begin 

;; only allows authorised users to add patient data
(asserts! (is-eq (is_auth_caller) true) UNAUTH_CALLER)

;; checks if patient records already exists or not 
(asserts! (is-eq (is-some (map-get? patient_data {id: id})) true) PATIENT_DOESNT_EXISTS)

(ok (map-set patient_data {id: id} {name: name, gender: gender, age: age, contactNo: contactNo}))

)
)

(define-public (delete_patient_data (id principal))
(begin 

;; only allows authorised users to add patient data
(asserts! (is-eq (is_auth_caller) true) UNAUTH_CALLER)

;; checks if patient records already exists or not 
(asserts! (is-eq (is-some (map-get? patient_data {id: id})) true) PATIENT_DOESNT_EXISTS)

(ok (map-delete patient_data {id: id}))

)
)


;; read-only funtions
