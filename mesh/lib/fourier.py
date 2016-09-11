def rfft(data, number=1, draw=False):
    import numpy
    import numpy.fft as fft        

    fourier = fft.rfft(data)
    fourier = numpy.array(map(abs,fourier))
    peaks = numpy.r_[True, fourier[1:] > fourier[:-1]] & numpy.r_[fourier[:-1] > fourier[1:], True]
    filtered = [ peaks[i] and x  for i,x in enumerate(fourier)]

    if draw:
        from draw import peaks
        peaks(fourier, filtered)

    pairs = []
    for i,x in enumerate(filtered):
        if x:
            pairs.append((i,abs(x)))
            pairs = sorted(pairs, key=lambda x: x[1], reverse=True)
    return pairs[:number]

    
