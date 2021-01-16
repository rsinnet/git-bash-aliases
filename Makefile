OUT_DIR:=build

all:
	$(MAKE) dist

${OUT_DIR}:
	mkdir ${OUT_DIR}

dist: ${OUT_DIR}
	cd ${OUT_DIR} && cmake .. && cpack

install: dist
	sudo dpkg -i ${OUT_DIR}/*.deb

clean:
	rm -rf ${OUT_DIR}

.PHONY: all clean dist install
