	list      p=10F200            ; list directive to define processor
	#include <p10F200.inc>        ; processor specific variable definitions

	__CONFIG   _MCLRE_OFF & _CP_OFF & _WDT_ON

; '__CONFIG' directive is used to embed configuration word within .asm file.
; The lables following the directive are located in the respective .inc file. 
; See respective data sheet for additional information on configuration word.
    
;***** VARIABLE DEFINITIONS
            UDATA
outer_loop_cnt  RES 1
inner_loop_cnt  RES 1
dc_phase        RES 1
;gp0_threshold   RES 1
gp1_threshold   RES 1
gp2_threshold   RES 1
gp1_shift       RES 1
;gp2_shift       RES 1
port_state      RES 1
zero            RES 1
temp            RES 1

;GP0_BIT  EQU D'0'
GP1_BIT  EQU D'1'
GP2_BIT  EQU D'2'

GP1_SHIFT       EQU D'85'
;GP2_SHIFT       EQU D'170'

OUTER_LOOP_CNT  EQU D'6'
INNER_LOOP_CNT  EQU H'FF'

;GP0_ON          EQU b'001'
;GP0_MASK        EQU GP0_ON
;GP0_OFF         EQU b'110'

GP1_ON          EQU b'010'
GP1_MASK        EQU GP1_ON
GP1_OFF         EQU b'101'

GP2_ON          EQU b'100'
GP2_MASK        EQU GP2_ON
GP2_OFF         EQU b'011'

GP_ALL_OFF      EQU b'000'

;***** MACRO DEFINITIONS
INIT macro
  CLRF      dc_phase
  CLRF      zero

  ; Set GP2 out as active since the switch-on
  CLRF      port_state
  BSF       port_state, GP2_BIT

  ; Prepare GP1 phase shift relative to GP2
  MOVLW     GP1_SHIFT
  MOVWF     gp1_shift
  ; Enable Wake-up on Pin Change (GP0, GP1, GP3) |
  ; Enable weak pull-ups (GP0, GP1, GP3) |
  ; Transition on internal Fosc/4 | 
  ; Increment on high-to-low transition |
  ; Prescaler assigned to WDT |
  ; Prescaler rate 1 : 1
  MOVLW     b'10011000'
  OPTION
  SET_LED_OUTPUTS
  endm
 
SET_LED_OUTPUTS macro
  CLRF      GPIO

  ; GP1 and GP2 out, GP0 and GP3 in
  MOVLW     b'1001'
  TRIS      GPIO
  endm

RESET_LOOP_COUNTERS macro
  MOVLW     OUTER_LOOP_CNT
  MOVWF     outer_loop_cnt
  MOVFW     zero
  MOVWF     inner_loop_cnt
  endm

SET_THRESHOLD macro port_mask
  GET_PHASE_VALUE port_mask
  endm

TURN_LED_OFF macro and_mask
  MOVLW     and_mask
  ANDWF     GPIO, F
  endm

TURN_LED_ON macro or_mask
  MOVLW     or_mask
  IORWF     GPIO, F
  endm

GET_PHASE_VALUE macro port_mask
  MOVLW     port_mask
  MOVWF     temp
  MOVF      dc_phase, W

  ; If GP1 phase value being retrieved,
  ; subtract GP1 phase shift from current
  ; duty cycle to get correct GP1 value
	BTFSC     temp, GP1_BIT
	SUBWF     gp1_shift, W
	
  ; GP2 / GP1 (based on port_mask) phase 
  ; value has now been prepared. Get true
  ; on/off phase duty cycle threshold from  
  ; the lookup table based on the phase
  ; value. This will then be used to do
  ; PWM switching of each output, in sync 
  ; with inner main loop counter.

  ; If phase value is in the "falling" side
  ; of the simulated sine curve, flip it
  ; back to the "rising" side. By doing this,
  ; we only need to implement half of the
  ; lookup table (total of 128 values), because
  ; flipping automatically mirrors the values.
  ; Otherwise the entire 256-step lookup would
  ; have to be implemented, which can't be
  ; done due to very limited PIC10F200 RAM.
  MOVWF     temp  ; save arg
  BTFSC     temp, 7 ; is arg in the 2nd half?
  COMF      temp, W ; yes, complement to reduce to 1st
  
  ; Get true duty cycle on/off threshold
	CALL      PHASE_VALUE_LOOKUP
	endm

;**********************************************************************
RESET_VECTOR  CODE   0xFF       ; processor reset vector

; Internal RC calibration value is placed at location 0xFF by Microchip
; as a movlw k, where the k is a literal value.
  RES       1

MAIN  CODE    0x000
  MOVWF     OSCCAL          ; update register with factory cal value 
  INIT
LOOP_START
  RESET_LOOP_COUNTERS             ; 6 255
  
  BTFSS     port_state, GP1_BIT   ; GP1 not yet activated?
  CALL      GP1_ACTIVATION_CHECK ; True -> check if GP1 needs to be activated
  
  CALL      SET_GP2_THRESHOLD ; GP2 lookup tbl value
  CALL      SET_GP1_THRESHOLD ; GP1 .., 0 if inactive
OUTER_LOOP
  CLRWDT
  DECFSZ    outer_loop_cnt, F
  GOTO      INNER_LOOP
  GOTO      OUT_OF_LOOP
INNER_LOOP
  ; Update GP2 and GP1 on/off states
  ; for this inner loop iteration cycle
  CALL      ADJUST_LED_STATES
  INCFSZ    inner_loop_cnt, F
  GOTO      INNER_LOOP
  GOTO      OUTER_LOOP
OUT_OF_LOOP  
  INCF      dc_phase, F
  BTFSC     STATUS, Z
  NOP
  GOTO      LOOP_START

REST CODE

GP1_ACTIVATION_CHECK
  ; Activate GP1 out after initial switch-on
  ; only once phase shift period has elapsed
  MOVF      dc_phase, W
  XORLW     GP1_SHIFT
  BTFSC     STATUS, Z
  BSF       port_state, GP1_BIT
  RETLW     0

SET_GP2_THRESHOLD
  GET_PHASE_VALUE GP2_MASK ; GP2 lookup tbl value
  MOVWF     gp2_threshold
  RETLW     0

SET_GP1_THRESHOLD
  ; Init GP1 threshold to zero and check
  ; if the switch-on phase shift period has
  ; elapsed. If so, get actual duty cycle
  MOVLW     0
  MOVWF     gp1_threshold
  BTFSC     port_state, GP1_BIT
  GOTO      GET_GP1_PHASE_VALUE
  RETLW     0

; Compare inner loop counter
; to duty cycle thresholds and
; switch GP2 and GP1 outputs
; on/off accordingly
ADJUST_LED_STATES
  MOVF      gp2_threshold, W
  SUBWF     inner_loop_cnt, W
  ; If inner loop counter is past the 
  ; duty cycle threshold, switch led off. 
  ; There's more than one step in both
  ; true and else conditional branches, 
  ; so must GOTO forth and back instead 
  ; of using a macro.
  BTFSC     STATUS, C
  GOTO      ADJUST_BRANCH_GP2_OFF
  TURN_LED_ON GP2_ON
ADJUST_RETURN_GP2
  MOVF      gp1_threshold, W
  SUBWF     inner_loop_cnt, W
  BTFSC     STATUS, C
  GOTO      ADJUST_BRANCH_GP1_OFF
  TURN_LED_ON GP1_ON
  RETLW     0
  
ADJUST_BRANCH_GP2_OFF
  TURN_LED_OFF GP2_OFF
  GOTO ADJUST_RETURN_GP2
ADJUST_BRANCH_GP1_OFF
  TURN_LED_OFF GP1_OFF
  RETLW     0
      
; Get GP1 duty cycle threshold
GET_GP1_PHASE_VALUE
  GET_PHASE_VALUE GP1_MASK 
  MOVWF     gp1_threshold
  RETLW     0
 
PHASE_VALUE_LOOKUP
  ADDWF   PCL, F
  RETLW  000h
  RETLW  001h
  RETLW  001h
  RETLW  003h
  RETLW  003h
  RETLW  004h
  RETLW  004h
  RETLW  005h
  RETLW  005h
  RETLW  006h
  RETLW  006h
  RETLW  008h
  RETLW  009h
  RETLW  009h
  RETLW  00Ah
  RETLW  00Ah
  RETLW  00Bh
  RETLW  00Bh
  RETLW  00Dh
  RETLW  00Eh
  RETLW  00Eh
  RETLW  00Fh
  RETLW  00Fh
  RETLW  010h
  RETLW  012h
  RETLW  012h
  RETLW  013h
  RETLW  014h
  RETLW  014h
  RETLW  015h
  RETLW  017h
  RETLW  017h
  RETLW  018h
  RETLW  019h
  RETLW  019h
  RETLW  01Ah
  RETLW  01Ch
  RETLW  01Ch
  RETLW  01Dh
  RETLW  01Eh
  RETLW  01Fh
  RETLW  01Fh
  RETLW  021h
  RETLW  022h
  RETLW  023h
  RETLW  023h
  RETLW  024h
  RETLW  026h
  RETLW  027h
  RETLW  028h
  RETLW  028h
  RETLW  029h
  RETLW  02Bh
  RETLW  02Ch
  RETLW  02Dh
  RETLW  02Eh
  RETLW  02Eh
  RETLW  030h
  RETLW  031h
  RETLW  032h
  RETLW  033h
  RETLW  035h
  RETLW  036h
  RETLW  037h
  RETLW  038h
  RETLW  03Ah
  RETLW  03Bh
  RETLW  03Ch
  RETLW  03Dh
  RETLW  03Fh
  RETLW  040h
  RETLW  041h
  RETLW  042h
  RETLW  044h
  RETLW  046h
  RETLW  047h
  RETLW  049h
  RETLW  04Ah
  RETLW  04Bh
  RETLW  04Eh
  RETLW  04Fh
  RETLW  050h
  RETLW  053h
  RETLW  054h
  RETLW  055h
  RETLW  058h
  RETLW  059h
  RETLW  05Ah
  RETLW  05Dh
  RETLW  05Eh
  RETLW  060h
  RETLW  063h
  RETLW  064h
  RETLW  067h
  RETLW  069h
  RETLW  06Ah
  RETLW  06Dh
  RETLW  06Fh
  RETLW  072h
  RETLW  074h
  RETLW  077h
  RETLW  079h
  RETLW  07Ch
  RETLW  07Eh
  RETLW  081h
  RETLW  085h
  RETLW  087h
  RETLW  08Bh
  RETLW  08Dh
  RETLW  091h
  RETLW  095h
  RETLW  099h
  RETLW  09Ch
  RETLW  0A0h
  RETLW  0A4h
  RETLW  0A9h
  RETLW  0ADh
  RETLW  0B2h
  RETLW  0B7h
  RETLW  0BDh
  RETLW  0C2h
  RETLW  0C8h
  RETLW  0D0h
  RETLW  0D7h
  RETLW  0DFh
  RETLW  0E7h
  RETLW  0F1h
  RETLW  0FFh

	END                       ; directive 'end of program'

; ADDWF       f, d    Add W and f
; ANDWF       f, d    AND W with f
; CLRF        f       Clear f
; CLRW        —       Clear W
; COMF        f, d    Complement f
; DECF        f, d    Decrement f
; DECFSZ      f, d    Decrement f, Skip if 0
; INCF        f, d    Increment f
; INCFSZ      f, d    Increment f, Skip if 0
; IORWF       f, d    Inclusive OR W with f
; MOVF        f, d    Move f
; MOVWF       f       Move W to f
; NOP         —       No Operation
; RLF         f, d    Rotate left f through Carry
; RRF         f, d    Rotate right f through Carry
; SUBWF       f, d    Subtract W from f
; SWAPF       f, d    Swap f
; XORWF       f, d    Exclusive OR W with f

; BIT-ORIENTED FILE REG OPS
; BCF         f, b    Bit Clear f
; BSF         f, b    Bit Set f
; BTFSC       f, b    Bit Test f, Skip if Clear
; BTFSS       f, b    Bit Test f, Skip if Set

; LITERAL AND CONTROL OPS
; ANDLW       k       AND literal with W
; CALL        k       Call Subroutine
; CLRWDT              Clear Watchdog Timer
; GOTO        k       Unconditional branch
; IORLW       k       Inclusive OR literal with W
; MOVLW       k       Move literal to W
; OPTION      —       Load OPTION register
; RETLW       k       Return, place Literal in W
; SLEEP       —       Go into Standby mode
; TRIS        f       Load TRIS register
; XORLW       k       Exclusive OR literal to W