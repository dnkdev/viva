exe := viva
deps := common.c
cc := gcc

run: 
	v -d trace -o $(exe) crun examples/simple.v

