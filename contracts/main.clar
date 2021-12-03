;; Hosptital DAO
;; 

;; errors
;;
(define-constant UNAUTH_CALLER (err "Unauthorised Caller"))
(define-constant AUTH_CALLER_ALREADY_EXISTS (err "Authorised record already exists"))
(define-constant AUTH_CALLER_DOESNT_EXIST (err "Authorised record doesnt exists"))
(define-constant PATIENT_ALREADY_EXISTS (err "Patient record already exists"))
(define-constant PATIENT_DOESNT_EXISTS (err "Patient record doesnt exists"))
(define-constant INVALID_GENDER (err "Invalid gender option entered"))
(define-constant APP_DOESNT_EXISTS (err "Appointment doesnt exists"))

;; constants
;;
(define-constant admin 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)


;; data maps and vars
;;
(define-map authorised_callers {address: principal} {authorised: bool})
(define-map patient_data {id: principal} {name: (string-ascii 20), gender: (string-ascii 1), age: uint, contactNo: uint})
;;(define-map appointments {doctor_id: principal} {patient_id: principal, date: (string-ascii 10)})

(define-data-var radiology_app_number uint u0)
(define-data-var dentist_app_number uint u0)
(define-data-var general_physician_app_number uint u0)

(define-map radiology {appointment_number: uint} {id: principal, time: uint, date: (string-ascii 10)} )
(define-map dentist {appointment_number: uint} {id: principal, time: uint, date: (string-ascii 10)} )
(define-map general_physician {appointment_number: uint} {id: principal, time: uint, date: (string-ascii 10)} )


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

;; checks if auth caller already exists or not 
(asserts! (is-eq (is-none (map-get? authorised_callers {address: address})) true) AUTH_CALLER_ALREADY_EXISTS)

(ok (map-set authorised_callers {address: address} {authorised: authorised}))

)
)

(define-public (delete_authosrised_caller (address principal) (authorised bool))
(begin

;; check if the funtion is called by admin or not
(asserts! (is-eq tx-sender admin) UNAUTH_CALLER)

;; checks if auth caller already exists or not 
(asserts! (is-eq (is-some (map-get? authorised_callers {address: address})) true) AUTH_CALLER_DOESNT_EXIST)

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



(define-public (set-appointment (app_num uint) (name principal) (department uint) (date (string-ascii 10)) (time uint ))

    (begin
    
        (asserts! (is-eq (is-none (map-get? patient_data {id: name}) ) true) (err "patient doesnt exist")) 
        
        
        (if (is-eq department u0)
        (begin

            (asserts! (> u20 (var-get radiology_app_number )) (err "radiology no more appointments"))
            (asserts!  (is-eq (is-none (map-get? radiology {appointment_number: app_num})) true) (err "radio app already exists"))

            (map-set radiology {appointment_number: (var-get radiology_app_number)} {id: name, time: time, date: date})
            (var-set radiology_app_number (+ (var-get radiology_app_number) u1))
            (ok true)
        )
        
        (if (is-eq department u1)
        (begin 

            (asserts! (> u20 (var-get dentist_app_number )) (err "no more appointments"))
            (asserts!  (is-eq (is-none (map-get? dentist {appointment_number: app_num})) true) (err "dentist app already exists"))

            (map-set dentist {appointment_number: (var-get dentist_app_number)} {id: name, time: time, date: date})
            (var-set dentist_app_number (+ (var-get dentist_app_number) u1))
            (ok true)   
        )
                    
        (if (is-eq department u2)
        (begin  

            (asserts! (> u20 (var-get general_physician_app_number )) (err "no more appointments"))
            (asserts!  (is-eq (is-none (map-get? general_physician {appointment_number: app_num})) true) (err "general physician app already exists"))

            (map-set general_physician {appointment_number: (var-get general_physician_app_number)} {id: name, time: time, date: date})
            (var-set general_physician_app_number (+ (var-get general_physician_app_number) u1))
            (ok true)
        )

            (err "select a number between u0 - u2")
        )
        )
        )

    )
)

(define-public (delete-appointment (department uint) (app_num uint))

    (begin
        
        
        (if (is-eq department u0)
        (begin

            (asserts! (< u0 (var-get radiology_app_number )) (err "no radiology appointments"))
            (asserts!  (is-eq (is-some (map-get? radiology {appointment_number: app_num})) true) (err "radio app doesnt exists"))

            (map-delete radiology {appointment_number: app_num})
            (var-set radiology_app_number (- (var-get radiology_app_number) u1))
            (ok true)
        )
        
        (if (is-eq department u1)
        (begin 

            (asserts! (< u0 (var-get dentist_app_number )) (err "no dentist appointments"))
            (asserts!  (is-eq (is-some (map-get? dentist {appointment_number: app_num})) true) (err "dentist app doesnt exists"))

            (map-delete dentist {appointment_number: app_num})
            (var-set dentist_app_number (- (var-get dentist_app_number) u1))
            (ok true)   
        )
                    
        (if (is-eq department u2)
        (begin

            (asserts! (< u0 (var-get general_physician_app_number )) (err "no general physician appointments"))  
            (asserts!  (is-eq (is-none (map-get? general_physician {appointment_number: app_num})) true) (err "general physician app doesnt exists"))

            (map-delete general_physician {appointment_number: app_num})
            (var-set general_physician_app_number (- (var-get general_physician_app_number) u1))
            (ok true)
        )

            (err "select a number between u0 - u2")
        )
        )
        )

    )
)


;; read-only funtions

(define-read-only (read_patient_data (id principal))
(begin

(asserts! (is-eq (is_auth_caller) true) UNAUTH_CALLER)
(ok (unwrap! (map-get? patient_data {id: id}) PATIENT_DOESNT_EXISTS))

)
)

(define-read-only (check_radiology_app (app_num uint))
(begin

(asserts! (is-eq (is_auth_caller) true) UNAUTH_CALLER)
(ok (unwrap! (map-get? radiology {appointment_number: app_num}) APP_DOESNT_EXISTS))

)
)

(define-read-only (check_dentist_app (app_num uint))
(begin

(asserts! (is-eq (is_auth_caller) true) UNAUTH_CALLER)
(ok (unwrap! (map-get? dentist {appointment_number: app_num}) APP_DOESNT_EXISTS))

)
)

(define-read-only (check_general_physician_app (app_num uint))
(begin

(asserts! (is-eq (is_auth_caller) true) UNAUTH_CALLER)
(ok (unwrap! (map-get? general_physician {appointment_number: app_num}) APP_DOESNT_EXISTS))

)
)

(define-read-only (read_radiology_app_number) 

(var-get radiology_app_number)

)


(define-read-only (read_dentist_app_number) 

(var-get dentist_app_number)

)


(define-read-only (read_general_physician_app_number) 

(var-get general_physician_app_number)

)

