import matplotlib.pyplot as plt
import numpy as np
from numpy import *
from scipy.interpolate import *
import Tkinter, random
from PIL import Image

def peaks(data1, data2):
    ax = plt.subplot(111)
    ax.grid(color='#222222',which = 'major')
    
    px = [i for i,x in enumerate(data1)] 
    py = data1
    ax.plot(px, py)
    
    px = [i for i,x in enumerate(data2)] 
    py = data2
    ax.plot(px, py, 'o-')
    
    plt.show()
    
def plot(data):
    ax = plt.subplot(111)
    ax.grid(color='#222222',which = 'major')
    
    px = xrange(len(data)) 
    py = data
    ax.plot(px, py)
    
    plt.show()

def bitmap(matrix, filename):    
    import Image, ImageDraw
    
    d = matrix.shape
    mx = matrix.max()

    img = Image.new('RGB', d, (0, 0, 0)) 
    draw = ImageDraw.Draw(img)

    for i in xrange(0,d[0]):
        for j in xrange(0,d[1]):
               color = int(matrix[i,j]/mx * 255)
               img.putpixel((i,j), (color,color,color))
    
    img = img.resize((d[0]*10, d[1]*10))
    img.save('draw/%s.bmp' % filename)
    #img.show()





