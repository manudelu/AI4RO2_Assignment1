(define (domain coffee-shop)

  (:requirements
    :adl
    :durative-actions 
    :fluents
    :duration-inequalities
  )

                        ;;;;; TYPES ;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (:types
    barista waiter - robot
    customer location drink biscuit - object 
    bar table - location 
    hot icy - drink
  )

  ;;;;; PREDICATES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (:predicates
    (barista ?r)  ;-- Represents the robot at bar
    (waiter ?w)   ;-- Represents the waiter
    (customer ?c) ;-- Represents the customer
    (location ?l) ;-- Location representation
    (bar ?b)      ;-- Bar representation
    (table ?t)    ;-- Table representation
    (drink ?d)    ;-- Drink representation
    (biscuit ?u)  ;-- Biscuit representation
    (hot ?d)
    (icy ?d)

    (empty-hand ?w) ;-- Represent if the hand is empty or not
    (different ?d1 - drink ?d2 - drink)
    (different-c ?c1 - customer ?c2 - customer)
    (free-bar ?r - barista) ; Represents the free status of the barista robot
    (delivered ?d - drink)
    (with-tray ?w - waiter) ; Represents the presence of a tray by a waiter
    (holding-drink ?w - waiter ?d - drink) ; Represents the holding of a drink by a waiter
    (holding-biscuit ?w - waiter  ?u - biscuit) ; Represents the holding of a biscuit by a waiter
    (is-static ?w - waiter) ; Represents if the waiter is static or not
    (left ?c - customer)
    (served-drink ?t - table) ; Represents the served drink status of a customer
    (served-biscuit ?c -customer ?u - biscuit) ; Represents the served biscuit status of the customer
    (waiting-biscuit ?c )
    (delivered-biscuit ?c -customer ?u - biscuit)
    (finished-drink ?c - customer ?t - table) ; Represents the finished drink status of a customer ; Represents the finished biscuit status of a customer
    (finished-all ?c - customer) ; Represents the finished status of a customer  ; Represents the waiting status of a customer for a biscuit
    (empty-tray ?w) ; Represents the empty status of the tray
    (at ?w - waiter ?l - location) ; Represents the location of a waiter
    (clean ?t - table) ; Represents if the table is clean or not
    (free-location ?l - location) ; Location ?l (generic, means bar or table) is free

    (on-bar ?d - drink) ; Represents the presence of drinks at the bar
    (ready-drink ?d - drink) ; Represents the ready drink
    (drink-info ?c - customer ?d - drink ?l - location) ; Represents the drink information
    (biscuit-info ?c - customer ?u - biscuit ?l - location) ; Represents the biscuit information
  
    (without-customer ?t - table) ; Represents the initial state of the table, without customer
    (two-customer ?t - table) ; Represents the presence of two customers at the table
    (four-customer ?t - table) ; Represents the presence of four customers at the table
    (empty ?t)
    (customer-left ?c)
    (different-b ?u1 ?u2)

    (ready-hot-drink) ; Represents the ready hot drink
  
    (duty-waiter ?w ?t) ; Represents the fact that each waiter can only serve two of the four tables
    )

                    ;;;;; FUNCTIONS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (:functions
    (dist ?l1 - location ?l2 - location)  ; Represents the numbers of customer at the table
    (width ?t - table) ; Width of a table
    (drinks-on-bar) ; Number of drinks on the bar

    (number-of-customers ?l - location) ; Represents the numbers of customer at the table
    (number-of-customers-left ?l - location )  ; Represents the numbers of customer at the table who left
    
    (velocity ?w - waiter) ; Velocity of the waiter robot
    
    (drinks-on-tray ?w - waiter)
    (drinks-on-tray-left ?w - waiter)

    (biscuits-on-tray ?w - waiter);number of drinks on trey of waiter
    (biscuits-on-tray-left ?w) 
  )

                ;;;;; Preparation Drink ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (:durative-action PrepareIcyDrink
    ; Barista prepares icy drink at the bar
    :parameters (?d - drink ?r - barista)
    :duration (= ?duration 3)
    :condition  (and 
                  (at start (free-bar ?r))
                  (at start (not (ready-drink ?d)))
                  (at start (icy ?d))
                    (at end (not(ready-hot-drink)))
                )
    :effect (and 
                (at start (not (free-bar ?r))) 
                  (at end (ready-drink ?d))
                  (at end (free-bar ?r))
                  (at end (increase (drinks-on-bar) 1))
                  (at end (on-bar ?d))
            )
  )

  (:durative-action PrepareHotDrink
    ; Barista prepares hot drink at the bar
    :parameters (?d - drink ?r - barista)
    :duration (= ?duration 5)
    :condition  (and 
                  (at start (free-bar ?r))
                  (at start (not (ready-drink ?d)))
                  (at start (hot ?d))
                  (at start (not (ready-hot-drink)))
                )
    :effect (and 
                (at start (not (free-bar ?r))) 
                  (at end (ready-drink ?d))
                  (at end (free-bar ?r))
                  (at end (increase (drinks-on-bar) 1))
                  (at end (on-bar ?d))
                  (at end (ready-hot-drink))
            )
  )

  (:action PickOne-HOT-Drink
    ; Waiter picks up one drink at the bar
    :parameters (?d - drink ?w - waiter ?b - bar)
    :precondition (and (empty-hand ?w) (is-static ?w) (at ?w ?b) (not (with-tray ?w)) 
                    (ready-drink ?d) (on-bar ?d) (hot ?d))
    :effect (and (holding-drink ?w ?d) (not (on-bar ?d)) (not (empty-hand ?w)) 
              (not (ready-hot-drink)) (decrease (drinks-on-bar) 1))
  )

  (:action PickOne-ICY-Drink
    ; Waiter picks up one drink at the bar
    :parameters (?d - drink ?w - waiter ?b - bar)
    :precondition (and (empty-hand ?w) (is-static ?w) (at ?w ?b) (not (with-tray ?w)) 
                    (ready-drink ?d) (on-bar ?d) (icy ?d) (not (ready-hot-drink)) (< (drinks-on-bar) 2))
    :effect (and (holding-drink ?w ?d) (not (on-bar ?d)) (not (empty-hand ?w)) (decrease (drinks-on-bar) 1))
  )


  (:action PutDownOneDrink
    ; Waiter delivers drink to customer with gripper
    :parameters (?d - drink ?w - waiter  ?t - table ?c - customer)
    :precondition (and (not(empty-hand ?w)) (is-static ?w) (at ?w ?t) (not (with-tray ?w)) 
                    (holding-drink ?w ?d)  (> (number-of-customers ?t) 0) 
                      (drink-info ?c ?d ?t) (duty-waiter ?w ?t))
    :effect (and (not (holding-drink ?w ?d)) (empty-hand ?w) (delivered ?d))
  )

  (:action PickTwoDrinks
    ;Waiter picks up two drinks at the bar with a tray
    :parameters (?d1 - drink ?d2 - drink ?w - waiter ?b - bar)
    :precondition (and (not (empty-hand ?w)) (is-static ?w) (at ?w ?b) (with-tray ?w) (empty-tray ?w)
                    (different ?d1 ?d2) (> (drinks-on-bar) 1) (ready-drink ?d1) (ready-drink ?d2)
                      (not (hot ?d1)) (not (hot ?d2)) (on-bar ?d1) (on-bar ?d2) (not (ready-hot-drink)) (< (biscuits-on-tray ?w) 1)
                  ) 
    :effect (and (holding-drink ?w ?d1) (holding-drink ?w ?d2) (not (on-bar ?d1)) (not (on-bar ?d2))
              (not (empty-tray ?w)) (increase (drinks-on-tray ?w) 2) (decrease (drinks-on-bar) 2) )   
  )

  (:action PickThreeDrinks
    ;Waiter picks up two drinks at the bar with a tray
    :parameters (?d1 - drink ?d2 - drink  ?d3 - drink ?w - waiter ?b - bar)
    :precondition (and (not (empty-hand ?w)) (is-static ?w) (at ?w ?b) (with-tray ?w) (> (drinks-on-bar) 2)
                    (ready-drink ?d1) (ready-drink ?d2) (ready-drink ?d3)
                      (different ?d1 ?d2) (different ?d1 ?d3) (different ?d2 ?d3)
                        (not (hot ?d1)) (not (hot ?d2)) (on-bar ?d1) (on-bar ?d2) (on-bar ?d3) (< (biscuits-on-tray ?w) 1)
                  ) ;(not (hot ?d3)))
    :effect (and (holding-drink ?w ?d1) (holding-drink ?w ?d2) (holding-drink ?w ?d3)
              (not (on-bar ?d1)) (not (on-bar ?d2)) (not (on-bar ?d3)) (not (empty-tray ?w))
                (decrease (drinks-on-bar) 3) (increase (drinks-on-tray ?w) 3))   
  )

  (:action PutDownOneDrinksWithTray
    :parameters (?d - drink ?w - waiter ?t - table ?c - customer)
    :precondition (and (not (empty-hand ?w)) (is-static ?w) (at ?w ?t) (with-tray ?w) (not (empty-tray ?w))
                    (drink-info ?c ?d ?t) (holding-drink ?w ?d) (> (number-of-customers ?t) 0)
                      (duty-waiter ?w ?t))
    :effect (and (delivered ?d) (increase (drinks-on-tray-left ?w) 1) (not (holding-drink ?w ?d)))
  )

  (:action TrayEmptyDrink 
    :parameters (?w - waiter)
    :precondition (and (>= (drinks-on-tray-left ?w) (drinks-on-tray ?w)) (with-tray ?w) (not (empty-tray ?w)) (< (biscuits-on-tray ?w) 1)
    )
    :effect (and (empty-tray ?w) (assign (drinks-on-tray ?w) 0) (assign (drinks-on-tray-left ?w) 0))
  )

  (:action PickUpTray
    ; Waiter picks up tray at the bar
    :parameters (?w - waiter ?b - bar)
    :precondition (and (is-static ?w) (empty-hand ?w) (at ?w ?b) (not (with-tray ?w)) (> (drinks-on-bar) 1))
    :effect (and (with-tray ?w) (empty-tray ?w) (decrease (velocity ?w) 1) (not (empty-hand ?w)))
  )

  (:action DropTray
    ; Waiter picks up tray at the bar
    :parameters (?w - waiter ?b - bar)
    :precondition (and (is-static ?w) (not (empty-hand ?w)) (at ?w ?b) (with-tray ?w) (empty-tray ?w) (< (drinks-on-bar) 2))
    :effect (and (not (with-tray ?w)) (increase (velocity ?w) 1) (empty-hand ?w))
  )


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (:action PickOneBiscuit
    ; Waiter picks up one biscuit at the bar
    :parameters (?u - biscuit ?w - waiter ?b - bar ?c - customer)
    :precondition (and (empty-hand ?w) (is-static ?w) (at ?w ?b) (not (with-tray ?w)) 
                    (waiting-biscuit ?c) (biscuit-info ?c ?u ?b)
                    )
    :effect (and (holding-biscuit ?w ?u) (not (empty-hand ?w)))
  )

  (:action PutDownOneBiscuit
    ; Waiter delivers biscuit to customer with gripper
    :parameters (?u - biscuit ?w - waiter  ?t - table ?c - customer) 
    :precondition (and (not(empty-hand ?w)) (is-static ?w) (at ?w ?t) (holding-biscuit ?w ?u) (not (with-tray ?w)) 
                    (> (number-of-customers ?t) 0) (biscuit-info ?c ?u ?t))
    :effect (and (not (holding-biscuit ?w ?u)) (empty-hand ?w) (delivered-biscuit ?c ?u))
  )

  (:action PickOneBiscuitWithTray
    ; Waiter picks up one biscuit at the bar
    :parameters (?u - biscuit ?w - waiter ?b - bar ?c - customer)
    :precondition (and (is-static ?w) (at ?w ?b) (with-tray ?w) (not (empty-hand ?w))
                    (waiting-biscuit ?c) (biscuit-info ?c ?u ?b) (<= (biscuits-on-tray ?w) 3) (< (drinks-on-tray ?w) 1)
                    )
    :effect (and (holding-biscuit ?w ?u) (increase (biscuits-on-tray ?w) 1) (not (empty-tray ?w)))
  )

  (:action PutDownOneBiscuitWithTray
    :parameters (?u - biscuit ?w - waiter ?t - table ?c - customer)
    :precondition (and (not (empty-hand ?w)) (is-static ?w) (at ?w ?t) (with-tray ?w) (not (empty-tray ?w))
                    (waiting-biscuit ?c) (holding-biscuit ?w ?u) (> (number-of-customers ?t) 0) (biscuit-info ?c ?u ?t))
    :effect (and (not (holding-biscuit ?w ?u)) (delivered-biscuit ?c ?u)
              (increase (biscuits-on-tray-left ?w) 1))
  )

  (:action TrayEmptyBiscuit
    :parameters (?w - waiter)
    :precondition (and (>= (biscuits-on-tray-left ?w) (biscuits-on-tray ?w)) (with-tray ?w) (not (empty-tray ?w)) (< (drinks-on-tray ?w) 1)
                  )
    :effect (and (empty-tray ?w) (assign (biscuits-on-tray ?w) 0) (assign (biscuits-on-tray-left ?w) 0))
  )
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  
  (:durative-action ConsumeHotDrink 
    ;Simulates the consume of the icy drink of the customer after recieving it
    :parameters (?d - drink ?c - customer ?t - table)
    :duration (= ?duration 4)
    :condition  (and 
                  (at start (drink-info ?c ?d ?t))
                  (at start (delivered ?d))
                  (at start (hot ?d))
                )
    :effect (and (at end (finished-drink ?c ?t)))
  )

  (:durative-action ConsumeIcyDrink 
    ;Simulates the consume of the icy drink of the customer after recieving it
    :parameters (?d - drink ?c - customer ?t - table)
    :duration (= ?duration 4)
    :condition  (and 
                  (at start (drink-info ?c ?d ?t))
                  (at start (delivered ?d))
                  (at start (icy ?d))
                )
    :effect (and (at end (waiting-biscuit ?c)))
  )

  (:durative-action ConsumeBiscuit
    ;Simulates the consume of the icy drink of the customer after recieving it
    :parameters (?u - biscuit ?c - customer ?t - table)
    :duration (= ?duration 1)
    :condition  (and 
                  (at start (delivered-biscuit ?c ?u))
                  (at start (biscuit-info ?c ?u ?t))
                )
    :effect (and
              (at end (not (delivered-biscuit ?c ?u))) 
              (at end (finished-drink ?c ?t))           
            )
  )

  (:action LeaveTable 
    ;simulates the departure of the customer from the table after eating the biscuit 
    :parameters (?t - table ?c - customer)
    :precondition (and (finished-drink ?c ?t) (not (left ?c)) )
    :effect (and (increase (number-of-customers-left ?t) 1) (left ?c) )
  )

  (:action EmptyTable
    :parameters (?t - table)
    :precondition (and (>= (number-of-customers-left ?t) (number-of-customers ?t)))
    :effect (and (empty ?t))
  )

  (:durative-action CleanTable
    ; Waiter cleans the table
    :parameters (?w - waiter ?t - table)
    :duration (= ?duration (* 2 (width ?t)))
    :condition  (and 
                  (at start (empty-hand ?w))
                  (at start (at ?w ?t))
                  (at start (not (with-tray ?w)))
                  (at start (is-static ?w))
                  (at start (not (clean ?t)))
                  (at start (empty ?t))
                )
    :effect (and 
              (at start (not (is-static ?w)))
              (at start (not (empty-hand ?w)))
                (at end (clean ?t))
                (at end (is-static ?w))
                (at end (empty-hand ?w))
            )
  )

  (:durative-action MoveFromTo
    ; Simulates the waiter's ?w motion from location ?from to location ?to
    :parameters (?from - location ?to - location ?w - waiter)
    :duration (= ?duration (/ (dist ?from ?to) (velocity ?w)))
    :condition  (and 
                  (at start (is-static ?w))
                  (at start (free-location ?to))
                  (at start (not(free-location ?from)))
                  (at start (at ?w ?from))
                )
    :effect (and 
              (at start (not (is-static ?w)))
              (at start (free-location ?from))
              (at start (not (at ?w ?from)))
                (at end (at ?w ?to))
                (at end (not (free-location ?to)))
                (at end (is-static ?w))
            )
  )
)

