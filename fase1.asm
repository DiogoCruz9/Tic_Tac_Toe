	#Diogo Cruz 33962
	#Vitor Silva 34080
	
	.data
   	turno:                 .word 0
    	
    	array:                 .word -15, -15, -15, -15, -15, -15, -15, -15, -15 #cada posicao do vetor (9 posicoes)
    	linha:                 .asciiz  "   |   |   \n"  
    	separador:             .asciiz  "---+---+---\n"
    	
    	jogador1:               .byte  'X'
    	jogador2:               .byte  'O'
    	vazio:                  .byte  ' '
    	
    	insira_linha:          .asciiz  "\n\nInsira a linha:"
    	insira_coluna:         .asciiz  "Insira a coluna:"
    	
    	print_jogador1_ganhou: .asciiz  "\nGanhou o jogador 1!\n"
    	print_jogador2_ganhou: .asciiz  "\n Ganhou o jogador 2!\n"
    	print_empate:          .asciiz  "Empatou!\n"
    	print_jogada_invalida: .asciiz  "\nJogada invalida! Jogue novamente...\n"
    	
    	stats_jogos1: 		.asciiz "Numero de jogos ganhos pelo jogador 1:\n"
    	stats_jogos2: 		.asciiz "Numero de jogos ganhos pelo jogador 2:\n"
    	
    	stats: 		   .asciiz  "Numero de pontos ganhos pelo jogador 1:\n"
    	stats2:		   .asciiz " numero de pontos ganhos pelo jogador 2:\n"

	.text
	.globl  main

main:
   
inicio:
        jal print_jogo  #processo do jogo
        jal jogada	#vai imprimir o tabuleiro, vai dar a oportunidade de cada jogador ter a sua vez e depois verifica se a jogada é válida
        j   verifica


print_jogo:
        la $s2, array # i  = *array
        la $s0, linha # s0 = *linha
        li $s1, 1     # s1 = indice

desenho:
        lw   $t1, ($s2)         # t1 = array[i]
        bltz $t1, desenha_vazio # vai para desenha_vazio  se t1<0
        bgtz $t1, desenha_o     # vai paradesenha_o se t1>0
        bgez $t1, desenha_x     # vai para desenha_x se t1>=0

desenha_o:
        lb  $t2, jogador2  # caracter = '0'
        j next

desenha_x:
        lb  $t2, jogador1  # caracter = 'X'
        j next

desenha_vazio:
        lb  $t2, vazio    # caracter = ' '
        j next

next: #funcao para mudar de jogador
        add $t1, $s0, $s1          # t1 = *linha[index]
        sb  $t2, ($t1)             # linha[index] = caracter
        addi $s2, $s2, 4           # i++
        addi $s1, $s1, 4           # index += 4
        li   $t1, 13               # t1 = 13 (index 13 nao existe em linha)
        beq  $t1, $s1, print_linha # reset linha if s1 == 13 
        j desenho
 
print_linha:
        la   $a0, linha                    # a0 = *linha
        li   $v0, 4                        # print
        syscall                            # string
        li   $s1, 1                        # index = 1 
        li   $t2, 36                       # array.length
        la   $t3, array                    # t3  = *array
        add  $t2, $t2, $t3                 # endereco array + 36 (9 words)
        beq  $s2, $t2, exit_print_desenho  # exit_print_desenho if i == fim do array
        la   $a0, separador                # a0 = *separador
        li   $v0, 4                        # print
        syscall                            # string
        j desenho
    
exit_print_desenho:
        jr $ra

jogada:
        la $a0, insira_linha
        li $v0, 4
        syscall
        li $v0, 5
        syscall       # Leitura
        move $s1, $v0 # linha
        la $a0, insira_coluna
        li $v0, 4
        syscall
        li $v0, 5
        syscall       # Leitura
        move $s2, $v0 # coluna

        li   $t3, 3        # t3 = 3 (tamanho_da_linha)
        mult $s1, $t3      # linha * 3 (offset_da_linha)
        mflo $s3           # s3 = offset_da_linha
        add  $s4, $s3, $s2 # s4 = offset_da_linha + coluna (posicao_vetor)
        la   $t0, array    # t0 = carrega endereco de array[0]
        li   $t5, 4        # t1 = 4 (tamanho da word no array)
        mult $s4, $t5      # 4 * posicao_vetor
        mflo $s1           # s1 = 4 * posicao_vetor
        add  $t1, $t0, $s1 # t1 = endereco array[0] + posicao calculada em s1 
        lw   $t3, turno    # t3 = turno
        li   $t2, 2        # t2 = 2
        div  $t3, $t2      # turno / 2
        mfhi $t2           # t2 = turno % 2
        li   $t6, 1        # t6 = 1
        add  $t3, $t3, $t6 # t3 += 1
        beq  $t2, $zero, jogada_player_1 # se turno par jogador1 se impar jogador2 
        li   $t5, 1 # jogador2
        j verifica_jogada
    
jogada_player_1:
        li   $t5, 0 # jogador1

verifica_jogada:
        lw   $t6, ($t1)       
        bgez $t6, jogada_invalida # Branch on greater than or equal to zero(0 ou 1 já na posição)
        j store_jogada

jogada_invalida:
        la  $a0, print_jogada_invalida 
        li  $v0, 4
        syscall
        j jogada

store_jogada: #guarda a jogada e passa para o proximo turno de jogadas
        sw   $t3, turno    # turno++
        sw   $t5, ($t1)
        jr   $ra

verifica: # se a soma=4, significa que houve empate, ou seja, nao houve nenhuma sequencia de 3 simbolos X ou O
	  # se a soma=3, significa que houve um vencedor
        la  $s5, array
        lw  $s0, 4($s5)      # 012      x1x
        lw  $s1, 16($s5)     # 345      x1x
        lw  $s2, 24($s5)     # 678      1x1 1+4+6+7 = 4 || 0
        lw  $s3, 32($s5)
        jal soma_empate
        
        lw  $s0, 4($s5)      # 012      x1x
        lw  $s1, 12($s5)     # 345      11x
        lw  $s2, 16($s5)     # 678      xx1 1+3+4+8 = 4 || 0
        lw  $s3, 32($s5)
        jal soma_empate
        
        lw  $s0, 4($s5)      # 012      x1x
        lw  $s1, 16($s5)     # 345      x11
        lw  $s2, 20($s5)     # 678      1xx 1+4+5+6 = 4 || 0
        lw  $s3, 24($s5)
        jal soma_empate
        
        lw  $s0, 0($s5)      # 012      1xx
        lw  $s1, 16($s5)     # 345      x11
        lw  $s2, 20($s5)     # 678      x1x 0+4+5+7 = 4 || 0
        lw  $s3, 28($s5)
        jal soma_empate
        
        lw  $s0, 8($s5)      # 012      xx1
        lw  $s1, 12($s5)     # 345      11x
        lw  $s2, 16($s5)     # 678      x1x 2+3+4+7 = 4 || 0
        lw  $s3, 28($s5)
        jal soma_empate
        
        lw  $s0, 0($s5)      # 012      1x1
        lw  $s1, 8($s5)      # 345      x1x
        lw  $s2, 16($s5)     # 678      x1x 0+2+4+7 = 4 || 0
        lw  $s3, 28($s5)
        jal soma_empate
        
        lw  $s0, 0($s5)      # 012      1xx
        lw  $s1, 16($s5)     # 345      x11
        lw  $s2, 20($s5)     # 678      1xx 0+4+5+6 = 4 || 0
        lw  $s3, 24($s5)
        jal soma_empate
        
        lw  $s0, 8($s5)      # 012      xx1
        lw  $s1, 12($s5)     # 345      11x
        lw  $s2, 16($s5)     # 678      xx1 2+3+4+8 = 4 || 0
        lw  $s3, 32($s5)
        jal soma_empate

        lw  $s0, 0($s5)      # 012      111 
        lw  $s1, 4($s5)      # 345      xxx 
        lw  $s2, 8($s5)      # 678      xxx (0 + 1 + 2) = 3 || 0
        jal soma_ganha
        
        lw  $s0, 12($s5)     # 012      xxx 
        lw  $s1, 16($s5)     # 345      111 
        lw  $s2, 20($s5)     # 678      xxx (3 + 4 + 5) = 3 || 0
        jal soma_ganha
        
        lw  $s0, 24($s5)     # 012      xxx 
        lw  $s1, 28($s5)     # 345      xxx 
        lw  $s2, 32($s5)     # 678      111 (6 + 7 + 8) = 3 || 0
        jal soma_ganha
        
        lw  $s0, 0($s5)       # 012     1xx
        lw  $s1, 12($s5)      # 345     1xx
        lw  $s2, 24($s5)      # 678     1xx (0 + 3 + 6) = 3 || 0
        jal soma_ganha
        
        lw  $s0, 4($s5)       # 012     x1x
        lw  $s1, 16($s5)      # 345     x1x
        lw  $s2, 28($s5)      # 678     x1x (1 + 4 + 7) = 3 || 0
        jal soma_ganha
        
        lw  $s0, 8($s5)       # 012     xx1 
        lw  $s1, 20($s5)      # 345     xx1 
        lw  $s2, 32($s5)      # 678     xx1 (2 + 5 + 8) = 3 || 0
        jal soma_ganha
        
        lw  $s0, 0($s5)       # 012     1xx
        lw  $s1, 16($s5)      # 345     x1x
        lw  $s2, 32($s5)      # 678     xx1 (0 + 4 + 8) = 3 || 0
        jal soma_ganha
        
        lw  $s0, 8($s5)       # 012     xx1
        lw  $s1, 16($s5)      # 345     x1x
        lw  $s2, 24($s5)      # 678     1xx (2 + 4 + 6) = 3 || 0
        jal soma_ganha

        j   inicio            # se não empatou nem ganhou continua o jogo

soma_ganha:
        add $t1, $s0, $s1
        add $t1, $t1, $s2
        li  $t2, 3
        beq $t1, $t2,   jogador2_ganhou
        beq $t1, $zero, jogador1_ganhou
        jr  $ra

soma_empate:
        add $t1, $s0, $s1
        add $t1, $t1, $s2
        add $t1, $t1, $s3
        li  $t2, 4
        beq $t2, $t1, empate
        jr  $ra

jogador1_ganhou:
        jal print_jogo
        
       
        #syscall
        
        #la $a1, stats
        #jal soma_pontosJ1
        #li $v0, 8
        #syscall
        
        #addiu   $sp,$sp,-32
        #sw      $ra,28($sp)
        #sw      $fp,24($sp)
        #move    $fp,$sp
        #sw      $a0,32($fp)
        
        # move $a0, $s0
        #addi $a1,$a0,1
        #jal soma_pontosJ1
        # add $s0, $s0, $v0
        
         
         la  $a0, print_jogador1_ganhou
         li  $v0, 4
         #la $a0, stats
         #syscall
         
         #move $a0, $s0
         syscall
        
        
        
        j   exit
   
jogador2_ganhou:
        jal print_jogo
        la  $a0, print_jogador2_ganhou
        li  $v0, 4
        syscall
        
      	
      	#jal soma_pontosJ2
      	#la $a0, stats2
      	#li $v0, 4
        j   exit

empate:
        la $a0, print_empate
        li $v0, 4
        syscall
        j exit


jogos_ganhos1: #irá incrementar cada vez que o jogador 1 ganhar
	#addiu   $sp,$sp,-32
        #sw      $ra,28($sp)
        #sw      $fp,24($sp)
        #move    $fp,$sp
        #sw      $a0,32($fp)
        
        #lw      $a1,32($fp)
        #lui     $at, 29
        #ori     $at, $at, 8
        #addiu   $a0,$v0,$at
        #jal     stats_jogos1
        
        
        #move    $sp,$fp
        #lw      $ra,28($sp)
        #lw      $fp,24($sp)
        #addiu   $sp,$sp,32
   
        addi $v0, $a0, 1
	jr $ra
	
jogos_ganhos2:#irá incrementar cada vez que o jogador 2 ganhar
	addi $v0, $a0, 1
	jr $ra

soma_pontosJ1: #irá somar sempre 3 pontos se o jogador 1 ganhar e tirar 1 ponto se o jogador 2 perder
	addiu $v0, $a0, 3
	addiu $v1, $a1, -1
	jr $ra
	
soma_pontosJ2:  #irá somar sempre 3 pontos se o jogador 2 ganhar e tirar 1 ponto se o jogador 1 perder
	addiu  $v0, $a0, -1
	addiu $v1, $a1, 3
	jr $ra
	
exit: #fecho do programa
        li  $v0, 10
        syscall




