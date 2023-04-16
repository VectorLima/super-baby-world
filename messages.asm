@includefrom message_box_expansion.asm

        ; put your message texts here.

        ; a message can have up to 10 lines with 26 characters each
        ; (260 characters in total).

        ; surround text with double quotes and put "db" before it.
        ; you can write all the text in one long line, but for
        ; readability's sake you should keep the line breaks at the same
        ; places as they are in-game (i.e. 26 characters per line),
        ; like I did in the example below.

        ; when you don't need all 10 lines, you can end the text prematurely
        ; by putting "db $FF" after the last line.
        ; this will save drawing time and ROM space.
        ; this only works when you put db $FF at the start of an in-game line.



;       db "this is how long a line is"

Message00:
        db "- TEST MESSAGE -          "
        db "                          "
        db "This is a demonstration of"
        db "what   the   message   box"
        db "expansion patch  can do --"
        db "just look at how much text"
        db "can go in these boxes!    "
        db "You'll  have  no  problems"
        db "fitting  your  message  in"
        db "here now, that's for sure."

Message01:
        db "Oi papais. Sou eu, o bebe."
        db "Estou tao feliz em saber  "
        db "que voces estao ansiosos  "
        db "para descobrir se serei um"
        db "menininho ou uma          "
        db "menininha. Criei um jogo  "
        db "especial para voces!      "
        db "Aproveitem cada momento   "
        db "enquanto jogam juntos e   "
        db "descobrem o segredo.      "

Message02:
        db "Hooray!  Thank you so much"
        db "for rescuing me.          "
        db "My name is Yoshi.         "
        db "When I went  to rescue  my"
        db "friends, Bowser trapped me"
        db "in that egg.              "
        db $FF

Message03:
        db "    - SWITCH  PALACE -    "
        db "                          "
        db "The  power  of  the switch"
        db "you have pushed  will turn"
        db "                          "
        db "           into    .      "
        db "                          "
        db "Your  progress  will  also"
        db "be saved.                 "
        db $FF

Message04:
        db "Durante o jogo, voces     "
        db "terao que trabalhar em    "
        db "equipe e passar o controle"
        db "um para o outro para      "
        db "completetar cada fase. Mas"
        db "nao se preocupem, tenho   "
        db "certeza de que voces serao"
        db "excelentes parceiros de   "
        db "jogo!                     "
        db $FF

Message05:
        db "Estou ansioso(a) para     "
        db "conhecer voces em breve.  "
        db "                          "
        db "Soube que teve gente que  "
        db "ate apostou hahaha!       "
        db $FF

Message06:
        db "A partir de agora, a mamae"
        db "fica no controle, ok?     "
        db "Para comecarmos a nossa   "
        db "aventura, vamos voltar um "
        db "pouco no tempo...         "
        db $FF

Message07:
        db "Meus papais se conheceram "
        db "ha muito tempo atras,     "
        db "ainda adolescentes em uma "
        db "festa na escola. E mesmo  "
        db "morando a um escadao de   "
        db "distancia, a maioria dos  "
        db "flertes eram via MSN,mamae"
        db "vivia indo na lan house   "
        db "para falar com o papai.   "
        db $FF

Message08:
        db "Mas tudo bem sabemos que o"
        db "escadao do guarani nao e  "
        db "facil ne?. O tempo passou "
        db "e a nossa familia comecou "
        db "a crescer. Primeiro eles  "
        db "decidiram adotar um       "
        db "cachorrinho muito especial"
        db "o Chokito, que ate hoje e "
        db "um membro muito especial  "
        db "da familia.               "

Message09:
        db "Depois, chegou a Nina para"
        db "completar a familia, pelo "
        db "menos ate agora, pois eu  "
        db "estou chegando hein...    "
        db "Mal posso esperar para    "
        db "conhecer meus irmaozinhos "
        db "e ser amado(a) por todos  "
        db "voces!                    "
        db $FF

Message10:
        db "Papai no controle agora!  "
        db "No ano de 2O14, surgiu uma"
        db "oportunidade incrivel para"
        db "o papai. Estudar fora, na "
        db "Irlanda. Os dois ainda    "
        db "muito jovens com suas res-"
        db "ponsabilidades e dificul- "
        db "dades financeiras, entao  "
        db "decidiram dar uma pausa no"
        db "relacionamento...         "


Message11:
        db "Foi um periodo muito difi-"
        db "cil para os dois, mas     "
        db "mesmo assim, eles nunca   "
        db "deixaram de se falar.     "
        db "Viviam atraves de video-  "
        db "chamadas no Skype e       "
        db "ligacoes. Papai surtava   "
        db "porque estava gastando    "
        db "bastante (Em euro ainda). "
        db $FF

Message12:
        db "Mas a saudade foi tanta   "
        db "que a mamae decidiu fazer "
        db "uma loucura de amor. Em   "
        db "meio a um mochilao na     "
        db "Europa que o papai estava "
        db "fazendo, ela juntou todas "
        db "as suas economias, comprou"
        db "um par de aliancas de     "
        db "novas e partiu com destino"
        db "a PARIS!                  "

Message13:
        db "Nem preciso dizer que foi "
        db "                          "
        db "LE...     GEN...          "
        db "                          "
        db "(espera um pouquinho...)  "
        db "                          "
        db "DARIO!!                   "
        db "                          "
        db "Mamae no controle agora.. "
        db $FF

Message14:
        db "Me desculpe mamae, mas eu "
        db "nao pude esquecer que essa"
        db "semana foi aniversario do "
        db "papai, e quer um presente "
        db "melhor do que ele         "
        db "finalizar essa aventura?  "
        db "                          "
        db "Passe o controle pro papai"
        db $FF

Message15:
        db "Querido papai, bora usar a"
        db "sua habilidade em         "
        db "finalizar jogos? Tenho    "
        db "                          "
        db "CERTEZA                   "
        db "                          "
        db "que esse voce nunca       "
        db "vai esquecer!             "
        db $FF
