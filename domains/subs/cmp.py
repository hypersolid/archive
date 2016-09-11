words1 = map(lambda x: x.lower().strip(), open('list.txt').readlines())
words2 = map(lambda x: x.lower().strip(), open('list2.txt').readlines())

for word in words2:
	for match in words1:
		if word==match.replace(' ',''):
			print match
			break
