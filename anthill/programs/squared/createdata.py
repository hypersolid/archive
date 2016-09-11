import random
f=open('para5000.txt','w')
for i in range(5000):
    x1=random.random()*1000-500
    x2=random.random()*1000-500
    x3=random.random()*1000-500
    f.write('%s %s %s\n'%(str(x1),str(x2),str(x3)))
f.close()
  