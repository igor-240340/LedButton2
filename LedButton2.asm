.include "m328def.inc"

.def tmp = r16
.def ledArray = r20

.equ START_BTN_INT = INT0
.equ STOP_BTN_INT = INT1

.org 0x00
                jmp Reset
                jmp StartPressed
                jmp StopPressed

Reset:          ldi tmp, low(RAMEND)                                ; Stack Pointer
                out SPL, tmp
                ldi tmp, high(RAMEND)
                out SPH, tmp

                ser tmp                                             ; Potr B out
                out DDRB, tmp
                out PORTB, tmp
            
                clr tmp                                             ; Port D in
                out DDRD, tmp
                ldi tmp, 0b00001100                                 ; Pull-up resistors
                out PORTD, tmp

                ldi tmp, (1 << STOP_BTN_INT)                        ; Enable stop button
                out EIMSK, tmp
                ldi tmp, (0b00 << ISC00 | 0b00 << ISC10)            ; Trigger all interrupts by low level
                sts EICRA, tmp

                sei                                                 ; Enable all interrupts

                sec
                set                                                 ; Left shift flag

                ldi ledArray, 0b11000001

MainLoop:       out PORTB, ledArray
                rcall Delay500ms
                ;rcall Delay0ms
                
                ser tmp
                out PORTB, tmp

                brts LeftShift

                sbrc ledArray, 1
                set
                ror ledArray
                rjmp MainLoop

LeftShift:      sbrc ledArray, 4
                clt
                clc
                rol ledArray
                rjmp MainLoop

StopPressed:    ldi tmp, (0 << STOP_BTN_INT | 1 << START_BTN_INT)   ; Diasble stop button. Enable start button
                out EIMSK, tmp

                ldi tmp, LOW(EmptyLoop)
                push tmp
                ldi tmp, HIGH(EmptyLoop)
                push tmp

                reti

StartPressed:   ldi tmp, (1 << STOP_BTN_INT | 0 << START_BTN_INT)   ; Enable stop button. Disable start button
                out EIMSK, tmp

                pop tmp                                             ; Prevent to return on EmptyLoop
                pop tmp

                reti

EmptyLoop:      rjmp EmptyLoop

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

