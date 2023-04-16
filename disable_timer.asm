;#######################################################################################;
; Time disable by JackTheSpades															;
;																						;
; Gets rid of SMW's timer in the status bar and leaves the area open for some other		;
; ASM to write their stuff there.														;
; Doesn't require freespace.															;
; Koopster update: now also removes the timer tallying in the "Course Clear!" march.	;
;																						;
; Note: 																				;
; You might as well install Alcaro's Time Up Fix patch.									;
; This patch alone might disable the timer, but you'll still get the "TIME UP" message	;
; if you die in a level with no time in it (Which probably looks stupid if you don't	;
; even have a timer)																	;
; DL: http://www.smwcentral.net/?p=section&a=details&id=4366							;
; Alternatively, just make sure no levels have the timer set to 0.						;
;																						;
;#######################################################################################;

!sa1 = 0
!addr = $0000

if read1($00FFD5) == $23
	sa1rom
	!sa1	= 1
	!addr	= $6000
endif

ORG $008E3F
	NOP #3	;Decrement the timer?
	db $80	;I think not

ORG $008E6B
	NOP #4	;Disable killing player when timer is 0

ORG $008E4F
        db $80	;Disable music speed up when going below 100 seconds by always skipping it

;Yeah, the above two might not be absolutely necessary since the timer is stopped anyway,
;but no harm done having them in.

ORG $008E6F
	NOP #18 ;Disable writing the numbers to the status bar.

ORG $008E8C
	NOP #3	;Disable placing of empty tiles instead of '0'

ORG $008CAB
	db $FC,$38 ;\
	db $FC,$38 ; | Writes blanks instead of TIME to the status bar when level is loaded
	db $FC,$38 ;/
ORG $008CE1
	db $FC,$38 ;\ Gets rid of the black boxes,
	db $FC,$38 ;/ which are usually overwritten by the timer.
	db $FC,$38 ; and of the default '0' that is written in the last place.

;course clear hijacks

org $05CC42	: NOP #31	;remove tiles

org $05CC66 : db $80,$1C	;remove timer-related 1-up functionality

org $05CCFB : NOP #3	;don't call time->score calculation subroutine
org $05CD02 : NOP #5	;and don't store anything to score

org $05CEAF : db $FC	;remove the residual 0 that shows up

org $05CDE3
JSR $CE4C		;jump to drumroll sound check
RTS : NOP

org $05CF48 : JSR $CE57	: NOP #2	;jump to star points check for the drumroll end sound

org $05CE4C		;hijacking the old time->score subroutine
;hijack 1
LDA $1424|!addr
BEQ +		;only play the sfx if there's star points to tally
LDA #$11			;\
STA $1DFC|!addr		;/play drumroll sfx
+
RTS
;hijack 2
PHA
LDA $1424|!addr
BEQ +			;branch if star tallying is not done
LDX #$12			;\
STX $1DFC|!addr		;/play drumroll end sfx
+
PLA
RTS
;leftover
NOP #63