# Equivalentes
.eqv $A $s0
.eqv $B $s1
.eqv goDisplay $a0

# Array para os valores do Display
 .data
displayBytes:
.byte 0x3F #0111111 - 0
.byte 0x06 #0000110 - 1
.byte 0x5B #1011011 - 2
.byte 0x4F #1001111 - 3
.byte 0x66 #1100110 - 4
.byte 0x6D #1101101 - 5
.byte 0x7D #1111101 - 6
.byte 0x07 #0000111 - 7
.byte 0x7F #1111111 - 8
.byte 0x6F #1101111 - 9
.byte 0x77 #1110111 - A
.byte 0x7C #1111100 - B 
.word 0x00 #0000000 - 15

# Fun��es macro com argumentos/par�metros

# Fun��o para imprimir texto
.macro printString(%s)
.data
string: .asciiz %s	
.text
la $a0, string		# Carrega a string para o endere�o utilizado pelo syscall
li $v0, 4		# 4 � o c�digo do syscall para printar string
syscall
.end_macro

# Fun��o para imprimir inteiro
.macro printInt(%i)
add $a0, $zero, %i	# Carrega inteiro para o endere�o utilizado pelo syscall
li  $v0, 1		# 1 � o c�digo do syscall para printar inteiro
syscall
.end_macro

# Fun��o para ler inteiro digitado pelo usu�rio
.macro readInt(%i)
li  $v0, 5 		# 5 � o c�digo do syscall para ler inteiro
syscall
add %i, $zero, $v0  	# Carrega o inteiro digitado e armazenado em $v0 para o par�mtro de retorno
.end_macro

# Fun��o para o contador
.macro contador(%i)
printString("Contador: ")
addu $t0, $zero, %i	# Armazena tempo m�ximo a ser contado em $t0
addi $t1, $zero, 1	# Armazena para iniciar em 1 em $t1
Loop:
printInt($t1)
printString(" ")
addi $t1, $t1, 1	# Incrementa contador
slt  $at, $t0, $t1	# %at false se ainda n�o contou tudo
beq  $at, $zero, Loop	# Se $at false continua contando
printString("\n")
.end_macro

# Inicio do programa
.text
start: printString("Start (1 para iniciar): ")
readInt($t0)
bne  $t0, 1, start  	#Se $t0 for diferente de 1 continuando solicitando o start

LeA: printString("Digite o valor de A: ")                     
readInt($A)
slti $at, $A, 0		# $at true se A � negativo
bne $at, $zero, LeA  	# Se $at � true, solicita digitar o A novamete
slti $at, $A, 16 	# $at true se for menos de 4 bits
beq $at, $zero, LeA 	# Se $at false, solicita digitar o A novamente

LeB: printString("Digite o valor de B: ")                     
readInt($B)
slti $at, $B, 0		# $at true se B � negativo
bne $at, $zero, LeB  	# Se $at � true, solicita digitar o B novamete
slti $at, $B, 16 	# $at true se for menos de 4 bits
beq $at, $zero, LeB 	# Se $at false, solicita digitar o B novamente

# Manda o A e o B para o Display
add goDisplay, $zero, $A	# Carrega o valor para o registrador que vai ser convertido para impress�o no Display
add $a1, $zero, 0xFFFF0011 	# 1� Display
jal display 			# Jump and Link
add goDisplay, $zero, $B	# Carrega o valor para o registrador que vai ser convertido para impress�o no Display
add $a1, $zero, 0xFFFF0010 	# 2� Display
jal display			# Jump and Link - Armzaena esta posi��o em um registrador

contador(5)

# B<A
slt $at, $B, $A
bne $at, $zero, conversorBinarioGray

subtracao:
add goDisplay, $zero, 15	# 1� Display � desligado
add $a1,$zero, 0xFFFF0011	# 1� Display � desligado
jal display			# 1� Display � desligado
sub $t0, $A, $B			# A-B
printString("A - B = ")
printInt($t0)
mul $t0, $t0, -1
add goDisplay, $zero, $t0	# 2� Display
add $a1, $zero, 0xFFFF0010	# 2� Display
jal display			# 2� Display
j fim

conversorBinarioGray:                   
# Converte o A
printString("A convertido para Gray = ")
add goDisplay, $zero, $A
jal executaConversaoBinarioGray
add $t0, $zero, $v0  		# Armazena o n�mero convertido em $t0
printInt($t0)
add goDisplay, $zero, $t0
add $a1,$zero, 0xFFFF0011	# 1� Display
jal display
# Converte o B
printString("\nB convertido para Gray = ")
add goDisplay, $zero, $B
jal executaConversaoBinarioGray
add $t0, $zero, $v0 		# Armazena o n�mero convertido em $t0
printInt($t0)
printString("\n")
add goDisplay, $zero, $t0
add $a1,$zero, 0xFFFF0010	# 2� Display
jal display

contador(7)

# B<A
slt $at, $B, $A
bne $at, $zero, start

fim:
li $v0, 10	# 10 � o c�digo do syscall para encerrar a execu��o do programa
syscall

executaConversaoBinarioGray:
srl  $t0, goDisplay, 1		# Shif de 1 bit para a direita e armazena em $t0
xor  $v0, $t0, goDisplay	# Xor do valor recebido com o valor com 1 bit para a direita
jr   $ra

display:
la $t0, displayBytes		# Armazena o array com os valores a serem imprimidos do display em $t0
add $t1, $t0, goDisplay		# $t1 recebe o n�mero a ser convertido, que � exatamente o mesmo valor do �ndice do array
lbu  $t2, 0($t1)		# $t2 recebe $t1 convertido para 7 segmentos
sb $t2, ($a1)	        	# Armazena o valor no respectivo registrador que ser� utilizado para impress�o no display
jr   $ra			# Jump Register - Volta para o endere�o que o chamou armazenado no registrador $s0
