exe := viva
deps := common.c
cc := gcc

run: 
	v -d trace -o $(exe) crun .

crun: cbuild
	./$(exe)

cbuild: $(deps)
	$(cc) -g $(deps) -o ./$(exe)