.include "m328def.inc"

.def tmp = r16
.def ledArray = r20

.equ START_PIN = 0                          ; Start button pin

.org 0x00
                jmp Start
                jmp StopPressed

Start:          ldi tmp, low(RAMEND)        ; Stack Pointer
                out SPL, tmp
                ldi tmp, high(RAMEND)
                out SPH, tmp

                ser tmp                     ; Potr B out
                out DDRB, tmp
                out PORTB, tmp
            
                clr tmp                     ; Port D in
                out DDRD, tmp
                ldi tmp, 0b00000101         ; Pull-up resistors
                out PORTD, tmp

                ldi tmp, (1 << INT0)        ; Enable INT0
                out EIMSK, tmp
                ldi tmp, (0b00 << ISC00)    ; By low level
                sts EICRA, tmp
                sei                         ; Enable all interrupts

                sec
                set                         ; Left shift flag

                ldi ledArray, 0b11111110

WaitStart:      sbic PIND, START_PIN
                rjmp WaitStart

Loop:           out PORTB, ledArray
                rcall Delay500ms
                
                ser tmp
                out PORTB, tmp

                brts LeftShift

                sbrs ledArray, 0
                set
                ror ledArray
                rjmp Loop

LeftShift:      sbrs ledArray, 5
                clt                         ; Disable left shift
                rol ledArray
                rjmp Loop

StopPressed:
WaitStart2:     sbic PIND, START_PIN
                rjmp WaitStart2
                reti

Delay500ms:     ldi r19, 100
Dec0:           ldi r17, 249
Dec1:           ldi r18, 106
Dec2:           dec r18
                brne Dec2
                dec r17
                brne Dec1
                dec r19
                brne Dec0
                ret

