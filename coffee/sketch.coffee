#    c  d  h  s
# 2  0  1  2  3
# 3  4  5  6  7
# 4  8  9 10 11
# 5 12 13 14 15
# 6 16 17 18 19
# 7 20 21 22 23
# 8 24 25 26 27
# 9 28 29 30 31
# T 32 33 34 35
# J 36 37 38 39
# Q 40 41 42 43
# K 44 45 46 47
# A 48 49 50 51

# Färger rangordnas ej.
# Är valörerna lika, splittas potten.

# https://www.pokerlistings.com/which-hand-wins-calculator

range = _.range
ass = console.assert

sort = (lst) => lst.sort (a,b) => b-a
spaceOp =(a,b) =>
	if a == b then 0 # lika
	else if a < b then 1 else -1 # 1=stigande, -1=fallande

compare = (na,nb) =>
	a = hands[na]
	b = hands[nb]
	res = spaceOp(a.klartext,b.klartext) || spaceOp(a.vc(),b.vc())
	console.log na,'<=>',nb,'Vinnare:',[na,'split',nb][res+1]
	res

log = (x) ->
	console.log x
	x

COLORS = 'cdhs'.split '' # clubs, diamonds, hearts, spades
VALUES = '23456789TJQKA'.split '' # ten, jack, queen, king, ace

toNumber = (card) ->
	c = COLORS.indexOf card[0]
	v = VALUES.indexOf card[1]
	c + v*COLORS.length
ass 0 == toNumber 'c2'
ass 1 == toNumber 'd2'
ass 51 == toNumber 'sA'

toLitteral = (card) ->
	c = card %% COLORS.length
	v = card // COLORS.length
	COLORS[c] + VALUES[v]
ass 'c2' == toLitteral 0
ass 'd2' == toLitteral 1
ass 'hA' == toLitteral 50
ass 'sA' == toLitteral 51

value = (number) => number // 4
ass 12 == value 51
ass 0 == value 0

color = (number) => number %% 4
ass 3 == color 51
ass 0 == color 0

class Hand
	constructor : (@str) ->
		@lst = @str.split ' '
		@lst = _.map @lst, (card) => toNumber card
		@lst = sort @lst, (a,b) => b-a
		@evaluate()

	draw : (j) =>
		textAlign RIGHT
		text j,                      30, 40+30*j
		textAlign LEFT
		for card,i in @lst
			@show card,i,j
		fill 'black'
		text @valueCount[0],   240, 40+30*j
		text @valueCount[1],   320, 40+30*j
		text @klartext,        390, 40+30*j

	show : (card,i,j) =>
		c = card %% COLORS.length
		v = card // COLORS.length
		fill "black red red black".split(" ")[c]
		text COLORS[c] + VALUES[v], 40+40*i, 40+30*j
	
	vc : =>
		mapper = {A:'E',K:'D',Q:'C',J:'B',T:'A'}
		res = _.map @valueCount[1], (item) => mapper[item] or item
		res.join ""

	evaluate : =>
		@valueCount = @groupValues()
		@colorCount = @groupColors()
		@klartext = '0 Högsta kort'
		if @valueCount[0] == '2111' then @klartext = '1 Ett par'
		if @valueCount[0] == '221' then @klartext = '2 Två par'
		if @valueCount[0] == '311' then @klartext = '3 Triss'
		if @valueCount[0] == '32' then @klartext = '6 Kåk'
		if @valueCount[0] == '41' then @klartext = '7 Fyrtal'
		if @valueCount[0] == '11111'
			if @färg() and @stege() then @klartext = '8 Färgstege'
			else if @färg() then @klartext = '5 Färg'
			else if @stege() then @klartext = '4 Stege'

	stege : -> 
		if @valueCount[1] == 'A5432'
			@valueCount[1] = '5432A'
			return true
		4 == Math.abs value(@lst[0]) - value(@lst[4])
	färg : -> @colorCount == '5'

	groupValues : ->
		arr = []
		for card in @lst
			index = card // 4
			if not arr[index] then arr[index] = [0,card//4]
			arr[index][0]++
		arr = _.compact arr
		res = arr.sort (a,b) => b[0]-a[0] || b[1]-a[1]
		c0 = _.map res, (a) => a[0]
		c1 = _.map res, (a) => VALUES[a[1]]
		[c0.join(""), c1.join("")]

	groupColors : ->
		arr = [0,0,0,0]
		for card in @lst
			arr[card %% 4]++
		arr = _.compact arr # tar bort alla nollor
		if arr.length == 1 then '5' else ''

hands = []
hands.push new Hand "h3 d4 sA c5 c6" # 0
hands.push new Hand "h3 d4 sA c7 c6" # 1
hands.push new Hand "s3 dJ h3 cQ cT" # 2
hands.push new Hand "s3 dJ h3 cQ cK" # 3
hands.push new Hand "s3 dJ c3 cQ cK" # 4
hands.push new Hand "h5 h6 h7 h9 h3" # 5
hands.push new Hand "h5 h6 h8 h9 h3" # 6
hands.push new Hand "s5 s6 s7 s9 s3" # 7
hands.push new Hand "cK cT cJ cQ c9" # 8
hands.push new Hand "s5 h5 c9 d5 c5" # 9
hands.push new Hand "cA c2 c4 c3 c5" # 10
hands.push new Hand "cT cJ cQ cK cA" # 11
hands.push new Hand "c2 c3 c4 c5 c6" # 12

ass  0 == compare 0,  0
ass -1 == compare 1,  0
ass -1 == compare 2,  0
ass -1 == compare 3,  2
ass  0 == compare 3,  3
ass  0 == compare 3,  4
ass -1 == compare 6,  7
ass -1 == compare 6,  5
ass  0 == compare 5,  7
ass -1 == compare 8,  9
ass  1 == compare 10,11
ass  1 == compare 9,  8
ass  1 == compare 10,12

window.setup = ->
	createCanvas 550, 420
	background "lightgray"
	textSize 20
	textFont "Courier New"
	for hand,j in hands
		hand.draw j
