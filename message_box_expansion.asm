
        ; #################################################
        ; #                                               #
        ; #             message box expansion             #
        ; #  made between 2012 and 2019 by WhiteYoshiEgg  #
        ; #                                               #
        ; #################################################

        ; refer to README.txt and HOW_TO_USE.txt
        ; for instructions and further information.





header
lorom



; #######################
; # SA-1 and LM3 checks #
; #######################

; LM 3.0 and above (=extended level support)
!LMVersion #= ((read1($0FF0B4)-'0')*100)+((read1($0FF0B6)-'0')*10)+(read1($0FF0B7)-'0')
if !LMVersion >= 257
	!EXLEVEL = 1
else
	!EXLEVEL = 0
endif



; SA-1
if read1($00FFD5) == $23
        sa1rom
        !base = $6000
	!bank = $000000
	!14C8 = $3242
else
        !base = $0000
	!bank = $800000
	!14C8 = $14C8
endif



macro getScreenNumber()
	PHX
	PHY
	PHP : SEP #$30
if !EXLEVEL
	JSL $03BCDC
else
	LDX $95
	PHA
	LDA $5B
	LSR
	PLA
	BCC ?+
	LDX $97
?+
endif
	TXA
	PLP
	PLY
	PLX
endmacro





; ###############
; # Definitions #
; ###############

        ; special messages
        ; (the values must be labels in message_list.asm)
        !DefaultMessage         = Message00
        !IntroMessage           = Message01
        !YoshiMessage           = Message02
        !YellowSwitchMessage    = Message14
        !BlueSwitchMessage      = Message03
        !RedSwitchMessage       = Message03
        !GreenSwitchMessage     = Message03

        ; what HDMA channel to use for the message box window
        ; (apparently needs to be the same as the one SMW uses,
        ; which is 7 unless you have some DMA remapping patch applied)
        !HDMAChannel            = 7

        ; the three RAM addresses below were only used by SMW's message boxes,
        ; which this patch obsoletes. I recommend not changing them.
        !MessageBoxState        = $1426|!base
        !MessageBoxTimer        = $1B88|!base
        !MessageToShow          = $1B89|!base





; ###########
; # Hijacks #
; ###########

org $00A1DA
        LDA !MessageBoxState
        BEQ +
        autoclean JSL MessageBoxMain
        RTS
        +

org $038D87
        autoclean JSL OnMessageBoxHit : NOP #8

org $01EC3B
        autoclean JML OnYoshiRescue

org $01E768
        autoclean JML DisplayMessage1Sprite

if read1($05B1A3) != $A2                ; \
org read3($05B1A4)+$39                  ;  | make LM's message hack
        RTL                             ;  | only set the switch palace number
org read3($05B1A4)+$BF                  ;  | and nothing else
        INX                             ;  |
        INX                             ;  |
        STX !MessageToShow              ;  |
        PLX                             ;  |
        RTS                             ; /
else
print ""
print " ! Lunar Magic's message ASM hack is not installed yet."
print " ! If you use switch palaces in your hack, please save"
print " ! the overworld in Lunar Magic, then re-apply this patch."
print ""
endif



        ; saving the current level number to $010B,
        ; just in case someone doesn't have uberASM or something installed

org $05D8B9
        JSR LevelNum
org $05DC46
LevelNum:
        LDA $0E
        STA $010B|!base
        ASL
        RTS





; ###############
; # Custom code #
; ###############

freecode
prot MessageList, Messages
reset bytes
print " Inserted at $", pc





        ; main message box routine

MessageBoxMain:

        PHB : PHK : PLB                 ; \
        REP #$20                        ;  |
        LDA $00 : PHA                   ;  | preserve stuff just to be safe
        LDA $02 : PHA                   ;  |
        LDA $04 : PHA                   ;  |
        SEP #$20                        ; /

        JSR .handleMessageBoxState

        REP #$20
        PLA : STA $04
        PLA : STA $02
        PLA : STA $00
        SEP #$20
        PLB

        RTL



.handleMessageBoxState

        LDA $71                         ; \
        CMP #$09                        ;  | instantly remove the box window
        BNE .notDying                   ;  | when the player is dying
        JMP .closing_nextState          ;  | (otherwise the death animation would stop
                                        ;  | with the death music still playing)
.notDying                               ; /


        LDA !MessageBoxState            ; \
        DEC                             ;  |
        JSL $0086DF|!bank               ;  | Handle the message box state
        dw .opening                     ;  | (minus one since it's never zero at this point)
        dw .there                       ;  |
        dw .closing                     ; /



        ; message box state 01: opening

.opening

        LDA #$22                        ; \
        STA $41                         ;  |
        LDY $13D2|!base                 ;  | change the screen settings
        BEQ +                           ;  | and enable HDMA
        LDA #$20                        ;  |
+       STA $43                         ;  |
        LDA #$22                        ;  |
        STA $44                         ;  |
        STZ $42                         ;  |
        LDA #$01<<!HDMAChannel          ;  |
        TSB $0D9F|!base                 ; /

        LDA !MessageBoxTimer            ; \
        CMP #23                         ;  | change the state after 22 frames
        BEQ ..nextState                 ; /

        TAX                             ; \
        LDA.w .boxWidths,x              ;  | save current window with and height
        STA $00                         ;  | in $00-$01
        LDA.w .boxHeights,x             ;  |
        STA $01                         ; /

        LDA #$FF                        ; \
        SEC : SBC $00 : LSR             ;  | save horizontal start and end points
        STA $02                         ;  | in $02-$03
        CLC : ADC $00                   ;  |
        STA $03                         ; /

        LDA #$B0                        ; \  determine the vertical starting point
        SEC : SBC $01                   ;  | (=index to the windowing HDMA table at $04A0)
        AND #$FE                        ;  | (making sure it's an even number too)
        TAX                             ; /  #$B0 is basically the box center's Y position times two

        REP #$10                        ; \
..loop                                  ;  |
        LDA $02                         ;  | write the horizontal start and end points to $04A0+
        STA $04A0|!base,x               ;  | using the box height as the loop counter
        LDA $03                         ;  |
        STA $04A1|!base,x               ;  |
        INX #2                          ;  |
        DEC $01                         ;  |
        LDA $01                         ;  |
        BNE ..loop                      ;  |
        SEP #$10                        ; /

        INC !MessageBoxTimer            ;    increment the timer

        RTS


..nextState                             ;    when we're finished...

        if read1($05B1A3) != $A2        ; \  run LM's message hack
        JSL read3($05B1A4)              ;  | (which now only sets the switch palace number)
        endif                           ; /

        STZ !MessageBoxTimer            ; \  reset the timer
        INC !MessageBoxState            ; /  and increment the box state

        LDA $13D2|!base                 ; \
        BEQ ..noSwitchPalace            ;  | if this is a switch palace message,
        JSR DrawSwitchPalaceTiles       ;  | draw switch blocks
..noSwitchPalace                        ; /

        RTS



        ; message box state 02: displaying text

.there

        LDA !MessageBoxTimer            ; \  if the timer has exceeded 9
        CMP #10                         ;  | (meaning all lines have been drawn),
        BCS ..textFinished              ; /  jump right to the "waiting for input" code

        LDA $13                         ; \  if the timer's still ticking
        AND #$01                        ;  | (meaning text is still being drawn),
        BEQ ..return                    ; /  do nothing every second frame

        JSR .displayText                ; \  draw the current line,
        INC !MessageBoxTimer            ;  | increment the timer
        BRA ..return                    ; /  and skip the "waiting for input" code

..textFinished

        LDA $0109|!base                 ; \
        ORA $13D2|!base                 ;  |
        BEQ ...canDismissMessage        ;  | recreate the routine from SMW
        LDA $1DF5|!base                 ;  | that keeps you from dismissing
        BEQ ...canDismissMessage        ;  | intro and switch palace messages
        LDA $13                         ;  | when the timer is active
        AND #$03                        ;  | and also marks a switch palace beaten
        BNE ..return                    ;  | when the timer reaches zero
        DEC $1DF5|!base                 ;  |
        BNE ..return                    ;  |
        LDA $13D2|!base                 ;  |
        BEQ ...canDismissMessage        ;  |
        INC $1DE9|!base                 ;  |
        LDA #$01                        ;  |
        STA $13CE|!base                 ;  |
        STA $0DD5|!base                 ;  |
        LDA #$0B                        ;  |
        STA $0100|!base                 ;  |
        RTS                             ;  |
...canDismissMessage                    ; /

...waitForInput
        LDA $15                         ; \
        AND #$F0                        ;  |
        BEQ ..return                    ;  | close the box
        EOR $16                         ;  | when certain buttons are being pressed
        AND #$F0                        ;  |
        BEQ ..closeBox                  ;  | (copied from SMW)
        LDA $17                         ;  |
        AND #$C0                        ;  |
        BEQ ..return                    ;  |
        EOR $18                         ;  |
        AND #$C0                        ;  |
        BNE ..return                    ; /

..closeBox
        LDA $0109|!base
        ORA $13D2|!base
        BNE ..doIntroStuff

..nextState
        JSR .eraseText                  ; \
        LDA #22                         ;  | when we're done, erase the text,
        STA !MessageBoxTimer            ;  | set the timer to 22 and increment the box state
        INC !MessageBoxState            ; /

        RTS

..doIntroStuff
        STZ $0109|!base                 ; \
        STZ $0DD5|!base                 ;  | intro level behavior
        LDA #$0B                        ;  | (send the player to the overworld)
        STA $0100|!base                 ; /

..return
        RTS



        ; message box state 03: closing

.closing

        LDA !MessageBoxTimer            ; \  the timer counts down
        BEQ ..nextState                 ; /  from 22 to zero here

        REP #$30                        ; \
        LDX #448                        ;  |
-                                       ;  | remove existing windows
        LDA #$00FF                      ;  | before drawing the current one
        STA $04A0|!base,x               ;  | (necessary here since every window is
        DEX #2                          ;  | smaller than the preceding one)
        BPL -                           ;  |
        SEP #$30                        ; /

        LDA !MessageBoxTimer            ; \
        TAX                             ;  |
        LDA.w .boxWidths,x              ;  | same math the "opening" code uses,
        STA $00                         ;  | only with the box dimensions
        LDA.w .boxHeights,x             ;  | getting smaller each frame
        STA $01                         ;  | since the timer's reversed
                                        ;  |
        LDA #$FF                        ;  |
        SEC : SBC $00 : LSR             ;  |
        STA $02                         ;  |
        CLC : ADC $00                   ;  |
        STA $03                         ;  |
                                        ;  |
        LDA #$B0                        ;  |
        SEC : SBC $01                   ;  |
        AND #$FE                        ;  |
        TAX                             ;  |
                                        ;  |
        REP #$10                        ;  |
..loop                                  ;  |
        LDA $02                         ;  |
        STA $04A0|!base,x               ;  |
        LDA $03                         ;  |
        STA $04A1|!base,x               ;  |
        INX #2                          ;  |
        DEC $01                         ;  |
        LDA $01                         ;  |
        BNE ..loop                      ;  |
        SEP #$10                        ; /

        DEC !MessageBoxTimer            ;    decrement the timer

        RTS


..nextState
        STZ !MessageBoxTimer            ; \  reset box timer and state
        STZ !MessageBoxState            ; /

        REP #$30                        ; \
        LDX #448                        ;  |
-                                       ;  |
        LDA #$00FF                      ;  | reset HDMA table
        STA $04A0|!base,x               ;  | (=remove all windowing)
        DEX #2                          ;  |
        BPL -                           ;  |
        SEP #$30                        ; /

        LDA #$01<<!HDMAChannel          ; \  disable HDMA
        TRB $0D9F|!base                 ; /

        RTS





        ; box widths and heights for each frame
        ; (used during opening/closing)

.boxWidths
        db 4,14,24,34,44,54,64,74,84,94,104,114,124,134,144,154,164,174,184,194,204,214,224
.boxHeights
        db 8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96





        ; displaying message text

.displayText

        ; uses:
        ; $00-$02: address of the tilemap for the current line being shown
        ; $03: current line's y position
        ; X: index to $7F837D
        ; Y: loop counter (current character in the line)

        REP #$30

        LDA !MessageToShow              ; \
        AND #$00FF                      ;  |
        ASL                             ;  | use !MessageToShow * 6 as an index to the message list
        STA $00                         ;  | and load the address of the corresponding message
        ASL                             ;  |
        CLC : ADC $00                   ;  |
        TAX                             ;  |
        LDA MessageList+3,x             ;  |
        STA $00                         ; /

        LDA !MessageBoxTimer            ; \
        AND #$00FF                      ;  |
        ASL                             ;  | multiply the timer by the number of characters per line
        STA $03                         ;  | and add the address of the current message
        ASL #2                          ;  | (this determines the address of the current line to show)
        STA $05                         ;  |
        ASL                             ;  |
        CLC : ADC $03                   ;  |
        CLC : ADC $05                   ;  |
        CLC : ADC $00                   ; /

        STA $00                         ;    save the above to $00-$01

        SEP #$20                        ; \  save the bank to $02
        LDA.b #Messages>>16             ;  | (all the above makes [$00] the address of
        STA $02                         ; /  the tilemap for the current line to show)

        LDA [$00]                       ; \
        CMP #$FF                        ;  |
        BNE ..continue                  ;  | if the current line starts with $FF,
..stopDrawing                           ;  | skip drawing this line
        SEP #$30                        ;  | and set the timer so that no more lines will be drawn
        LDA #10                         ;  |
        STA !MessageBoxTimer            ;  |
        RTS                             ;  |
..continue                              ; /

        REP #$30                        ; \
        LDA $7F837B : TAX               ;  | X = index to $7F837D,
        LDY #$0000                      ;  | Y = 0
        SEP #$20                        ; /

        LDA !MessageBoxTimer            ; \
        CLC : ADC #$20                  ;  | save current line's y position to $03
        STA $03                         ; /



        ; saving the current line's stripe image data
        ; to the layer 3 tilemap table at $7F837D

..header

        LDA $03                         ; \
        AND #$20                        ;  |
        LSR #2                          ;  | stripe image header, Byte 1
        STA $7F837D,x                   ;  |
        LDA $03                         ;  | (bitwise shenanigans galore
        AND #$18                        ;  | to cram the y position in there)
        LSR #3                          ;  |
        ORA $7F837D,x                   ;  |
        ORA #$50                        ;  |
        STA $7F837D,x                   ;  |
        INX                             ; /

        LDA $03                         ; \
        ASL #5                          ;  |
        AND #$E0                        ;  | byte 2
        ORA #$03                        ;  | (x position, remaining bits of y position)
        STA $7F837D,x                   ;  |
        INX                             ; /

        LDA #$00                        ; \
        STA $7F837D,x                   ;  | byte 3 (direction, RLE, some length bits)
        INX                             ; /

        LDA #51                         ; \
        STA $7F837D,x                   ;  | byte 4 (length = [26 characters] * [2 bytes per character] - 1 = 51)
        INX                             ; /


..body

...loop
        LDA [$00],y                     ; \
        STA $7F837D,x                   ;  | save the character and the property byte
        INX                             ;  | for each of the 26 characters in the line
        LDA #$39                        ;  |
        STA $7F837D,x                   ;  |
        INX                             ;  |
        INY                             ;  |
        CPY.w #26                       ;  |
        BNE ...loop                     ; /

..return                                ;    at the end of the line,

        LDA #$FF                        ; \  put an FF byte
        STA $7F837D,x                   ; /
        REP #$20                        ; \  and save the new index
        TXA : STA $7F837B               ; /
        SEP #$30

        STZ $12                         ;    tell SMW to upload an image from $7F837D
        RTS                             ;    done~





        ; message removing

.eraseText

        REP #$30                        ; \
        LDA $7F837B : TAX               ;  |
        LDY.w #$07                      ;  | put a stripe image with empty tiles
        SEP #$20                        ;  | to overwrite the message at $7F837D
..loop                                  ;  |
        LDA ..emptyTilemap,x            ;  |
        STA $7F837D,x                   ;  |
        INX                             ;  |
        DEY                             ;  |
        BPL ..loop                      ;  |
                                        ;  |
        REP #$20                        ;  |
        TXA : STA $7F837B               ;  |
        SEP #$30                        ;  |
                                        ;  |
        STZ $12                         ;  |
        RTS                             ; /

..emptyTilemap
        db $58,$03,$42,$72
        db $FC,$38
        db $FF



        ; drawing switch block tiles

DrawSwitchPalaceTiles:

        DEC                             ; \
        ASL #4                          ;  |
        PHX                             ;  | copied this from smw again
        TAX                             ;  | (this is your run-of-the-mill graphics routine,
        STZ $00                         ;  | except tiles/properties and x/y positions
        REP #$20                        ;  | are merged into the same table respectively )
        LDY #$1C                        ;  |
.loop                                   ;  |
        LDA .switchBlockTilemap,x       ;  |
        STA $0202|!base,y               ;  |
        PHX                             ;  |
        LDX $00                         ;  |
        LDA .switchBlockPositions,x     ;  |
        STA $0200|!base,y               ;  |
        PLX                             ;  |
        INX #2                          ;  |
        INC $00                         ;  |
        INC $00                         ;  |
        DEY #4                          ;  |
        BPL .loop                       ;  |
                                        ;  |
        STZ $0400|!base                 ;  |
        SEP #$20                        ;  |
        PLX                             ; /

        RTS


.switchBlockTilemap     ; odd entries are tile numbers, even entries are properties
..yellow
        db $AD,$35,$AD,$75,$AD,$B5,$AD,$F5
        db $A7,$35,$A7,$75,$B7,$35,$B7,$75
..blue
        db $BD,$37,$BD,$77,$BD,$B7,$BD,$F7
        db $A7,$37,$A7,$77,$B7,$37,$B7,$77
..red
        db $AD,$39,$AD,$79,$AD,$B9,$AD,$F9
        db $A7,$39,$A7,$79,$B7,$39,$B7,$79
..green
        db $BD,$3B,$BD,$7B,$BD,$BB,$BD,$FB
        db $A7,$3B,$A7,$7B,$B7,$3B,$B7,$7B

.switchBlockPositions   ; odd entries are x positions, even entries are y positions
        db $58,$51,$60,$51,$58,$59,$60,$59
        db $9A,$51,$A2,$51,$9A,$59,$A2,$59




        ; determining the current message number
        ; and activating the message box

        ; X: index to message list (loop counter * 6)
        ; Y: preserves X

OnMessageBoxHit:
SetMessage:

        !TableLength = MessageList_end-MessageList_customEntries

        LDA #$07
        STA !MessageToShow
        REP #$30
        PHY
        TXY
        LDX #$0000
.loop
        CPX.w #!TableLength
        BEQ .useDefaultMessage
        LDA MessageList_customEntries,x
        CMP $010B|!base
        BNE .continue
        SEP #$20
	%getScreenNumber()
        CMP MessageList_customEntries+2,x
        BEQ .break
.continue
        INX #6
        SEP #$20
        INC !MessageToShow
        REP #$20
        BRA .loop
.useDefaultMessage
        STZ !MessageToShow
.break
        TYX
        PLY
        SEP #$30

        LDA #$01                        ; \  activate the message box
        STA !MessageBoxState            ; /

        RTL





        ; setting the yoshi message

OnYoshiRescue:

        LDA #$02
        STA !MessageToShow

        LDA #$01
        STA !MessageBoxState

        JML $01EC40|!bank



print " ", bytes, " bytes used."





        ; making the "display level message 1" sprite
        ; show the intro message if used in the intro level

DisplayMessage1Sprite:

        STZ !14C8,x                     ; \
        LDA #$01                        ;  | restore hijacked code
        STA !MessageBoxState            ; /

        LDA $0109|!base                 ; \
        BEQ .notIntro                   ;  |
        LDA #$01                        ;  | Use the intro message in the intro level
        STA !MessageToShow              ;  | and the current screen's settings otherwise
        BRA +                           ;  |
.notIntro                               ;  |
        JSL SetMessage                  ;  |
+       JML $01E76E|!bank               ; /





        ; misc. data

freedata
reset bytes
print " Message list inserted at $", pc





        ; the table determining which message to show where

MessageList:

.specialEntries
        dl $000000 : dl !DefaultMessage
        dl $000000 : dl !IntroMessage
        dl $000000 : dl !YoshiMessage
        dl $000000 : dl !YellowSwitchMessage
        dl $000000 : dl !BlueSwitchMessage
        dl $000000 : dl !RedSwitchMessage
        dl $000000 : dl !GreenSwitchMessage

.customEntries
        incsrc message_list.asm
.end

print " ", bytes, " bytes used."





        ; actual message texts

freedata
reset bytes
print " Messages inserted at $",pc

Messages:

        cleartable : table ascii.txt
        incsrc messages.asm

print " ", bytes, " bytes used."
