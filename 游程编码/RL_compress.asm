j _start
sll $0, $0, 0
j _exceptions
sll $0, $0, 0


_start:
lui $a0,0x1001 #a0Ϊdmemȡ���׵�ַ
lui $a1,0x1081 #a1Ϊvga in ��ַ

lui $a2,0x1081
addiu $a2,$a2,0x0004 #a2Ϊvga status ��ַ

lui $a3,0x1001 #a3Ϊ���ݵ�ַ
ori $s1,$0,0x8000 #s1�����ж������Ƿ�ѹ��
ori $s2,$0,0x4000 #s1�����ж����ݷ���ѹ��ʱ����0����1
lui $s6,0x8000 #s6 �����0x8000_0000
sra $s7,$s6,31    # s7=ffff_ffff
ori $t8,$0,0x0020 # t8��Ϊ32
ori $t9,$0,0x001f # t9��Ϊ31
ori $t7,$0,0x3fff # t7 ��Ϊ  0011_1111_1111_1111


cycle:
ori $v1,$0,0x0020
ori $v1,$0,0x0020
ori $v1,$0,0x0020
ori $v1,$0,0x0020
ori $v1,$0,0x0020
ori $v1,$0,0x0020
ori $v1,$0,0x0020
ori $v1,$0,0x0020
ori $v1,$0,0x0020
ori $v1,$0,0x0020
j cycle


_exceptions:
#��ѡVGA״̬�Ĵ�����ַ���鿴�Ƿ���Ҫ�����ݵ�ַ��Ϊ0
lw $t0,($a2)
and $s5,$0,$s0
beq $t0,$0,no_restart #����0��ʱ����Ҫ���ã���������
#���²���ͼƬ �Ĵ���ȫ������
addu $a3,$a0,$0
and $v0,$0,$0


no_restart:
bne $v0,$0,no_fatch #���ж��Ƿ���ʣ��λ
fatch_num:
lhu $s0,($a3) #��ʱҪȡ��  �����޷�����չ
addiu  $a3,$a3,0x0002 #��ַ+2
and $t1,$s1,$s0 #�ж��Ƿ�ѹ��
sltu $s3,$t1,$s1 #0000000 -1   , 0000_8000 - 0

beq $s3,$0,label3
#��ѹ��
and $s0,$s0,$t7 #����14λ��Ч
addiu $v0,$0,0x000e # v0 =14
j no_fatch

label3:
#ѹ��
and $t1,$s2,$s0 #�ж�ѹ��0/1
sltu $s4,$t1,$s2 #0000000 -1   , 0000_4000 - 0
and $v0,$s0,$t7 #����14λ��Ч


no_fatch:
bne $s3,$0,no_compress

compress:
sltu $t0,$v0,$v1 # v0<v1 -- 1   , v0>=v1 ---0
bne $t0,$0,cp_2

#v1<=v0 
sllv $s5,$s5,$v1  #������������
and $t2,$0,$0 #��0����֤ѹ��0��ʱ��Ҳ�ܵõ���ȷ���
bne $s4,$0,label1
or $t2,$0,$s7
beq $v1,$t8,label1 #v1=32ʱ�����⴦��
#��1��ѹ��

subu $t1,$t9,$v1
srav $t2,$s6,$t1
xor $t2,$t2,$s7

label1:
or $s5,$s5,$t2 #ƴװ�������
subu $v0,$v0,$v1
j output

cp_2:
# v0<v1 
sllv $s5,$s5,$v0  #������������
and $t2,$0,$0 #��0����֤ѹ��0��ʱ��Ҳ�ܵõ���ȷ���
bne $s4,$0,label2
#��1��ѹ��
subu $t1,$t9,$v0
srav $t2,$s6,$t1
xor $t2,$t2,$s7

label2:
or $s5,$s5,$t2 #ƴװ�������
subu $v1,$v1,$v0
j fatch_num


no_compress:
sltu $t0,$v0,$v1 # v0<v1 -- 1   , v0>=v1 ---0
beq $t0,$0,no_cp_1

# v0<v1 
sllv $s5,$s5,$v0  #������������
or $s5,$s5,$s0  #ƴװ��S5
subu $v1,$v1,$v0 #�޸�ʣ�� ��Ҫ��ƴװλ��
j fatch_num

no_cp_1:
#v1<=v0 
sllv $s5,$s5,$v1  #������������
subu $v0,$v0,$v1
srlv $t2,$s0,$v0 #���������� λ
or $s5,$s5,$t2 #ƴװ�������
#s0���� v0λ
subu $t2,$t8,$v0
sllv $s0,$s0,$t2
srlv $s0,$s0,$t2

output:
sw $s5,($a1) #�������͵�vga
#j _epc_plus4

#_epc_plus4:
#sll $0, $0, 0
mfc0 $k0, $14
addi $k0, $k0, 0x4
mtc0 $k0, $14
eret