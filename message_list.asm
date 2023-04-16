@includefrom message_box_expansion.asm

        ; this table determines which message to show
        ; depending on the current level and screen number.
        ; this is what you're supposed to edit.

        ; just follow the format and you'll be good.

        ; example:
        ; dw $0105 : db $00 : dl Message04
        ; means "in level 105, screen 00, use Message04".



;  level   screen   message
dw $0104 : db $00 : dl Message04


dw $0105 : db $00 : dl Message05
dw $0105 : db $03 : dl Message06
dw $0105 : db $05 : dl Message07
dw $0105 : db $07 : dl Message08

dw $01CB : db $00 : dl Message09

dw $0105 : db $09 : dl Message10
dw $0105 : db $0B : dl Message11
dw $0105 : db $0F : dl Message12
dw $0105 : db $12 : dl Message13

dw $014 : db $08 : dl Message14
dw $00CA : db $02 : dl Message15















