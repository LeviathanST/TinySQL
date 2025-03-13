compile-main:
	gcc -Wall src/main.c src/soul.c -o tinysql
	./tinysql
