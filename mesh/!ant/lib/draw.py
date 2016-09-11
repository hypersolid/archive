import matplotlib.pyplot as plt
import numpy as np
from numpy import *
from scipy.interpolate import *

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