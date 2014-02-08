love = /Applications/love.app/Contents/MacOS/love

game.love: *.lua *.png
	zip -r game.love *.lua *.png

.PHONY: clean
clean:
	rm game.love

.PHONY: run
run: game.love
	$(love) game.love
