love = /Applications/love.app/Contents/MacOS/love

game.love: *.lua *.png *.json
	zip -r game.love *.lua *.png *.json

.PHONY: clean
clean:
	rm game.love

.PHONY: run
run: game.love
	$(love) game.love
