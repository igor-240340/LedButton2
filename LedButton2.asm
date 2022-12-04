.include "m328def.inc"

.def tmp = r16
.def ledArray = r20

.equ START_PIN = 0                                          ; Start button pin
.equ STOP_PIN = 0                                           ; Stop button pin

.org 0x00
                jmp Reset
                jmp StartPressed
                jmp StopPressed

Reset:          ldi tmp, low(RAMEND)                        ; Stack Pointer
                out SPL, tmp
                ldi tmp, high(RAMEND)
                out SPH, tmp

                ser tmp                                     ; Potr B out
                out DDRB, tmp
                out PORTB, tmp
            
                clr tmp                                     ; Port D in
                out DDRD, tmp
                ldi tmp, 0b00001100                         ; Pull-up resistors
                out PORTD, tmp

                ldi tmp, (1 << INT0 | 1 << INT1)            ; Enable INT0, INT1
                out EIMSK, tmp
                ldi tmp, (0b00 << ISC00 | 0b00 << ISC10)    ; By low level
                sts EICRA, tmp

                sei                                         ; Enable all interrupts

                sec
                set                                         ; Left shift flag

                ldi ledArray, 0b11011111

MainLoop:       out PORTB, ledArray
                rcall Delay500ms
                ;rcall Delay0ms
                
                ser tmp
                out PORTB, tmp

                brts LeftShift

                sbrs ledArray, 0
                set
                ror ledArray
                rjmp MainLoop

EmptyLoop:      rjmp EmptyLoop

LeftShift:      sbrc ledArray, 4
                clt
                sec
                rol ledArray
                rjmp MainLoop

StartPressed:   pop tmp
                pop tmp
                reti

StopPressed:    ldi tmp, LOW(EmptyLoop)
                push tmp
                ldi tmp, HIGH(EmptyLoop)
                push tmp
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

Delay0ms:       ret

