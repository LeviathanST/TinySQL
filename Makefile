debug:
	gcc -Wall -g tests/hash_table.c src/hash_table.c -o out
test:
	gcc -Wall tests/hash_table.c src/hash_table.c -o test
	./test
	rm ./test
compile:
	mkdir -p build
	gcc -Wall src/main.c src/hash_table.c src/soul.c -o build/tinysql
	./build/tinysql
