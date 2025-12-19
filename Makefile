all: bof

bof:
	@(mkdir _bin 2>/dev/null) && echo 'creating _bin directory' || echo '_bin directory exists'
	@(x86_64-w64-mingw32-gcc -I _include -Os -s -c nbtscan/nbtscan.c -o _bin/nbtscan.x64.o -DBOF && x86_64-w64-mingw32-strip --strip-unneeded _bin/nbtscan.x64.o) && echo '[+] nbtscan' || echo '[!] nbtscan'


clean:
	@(rm -rf _bin)