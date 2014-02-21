//
//  ImageProcessor.h
//  image
//
//  Created by renren on 14-2-20.
//
//

#ifndef image_ImageProcessor_h
#define image_ImageProcessor_h


#include <stdio.h>

static int swapEachRow(unsigned char *a, unsigned char *b, int widthStep)
{
    if (NULL == a || NULL == b) {
        return -1;
    }
    unsigned char temp = 0;
    for (int i=0; i<widthStep;i++) {
        temp = *a;
        *a = *b;
        *b = temp;
        a++;
        b++;
    }
    return 1;
}

static int reverseImage(unsigned char *src,int w, int h, int nChannels)
{
    //unsigned char *dst = src;
    int i=0, j=h-1;
    int widthStep = w*nChannels;
    unsigned char *a = NULL;
    unsigned char *b = NULL;
    for (; i<j; i++,j--) {
        a = src+i*widthStep;
        b = src+j*widthStep;
        if(!swapEachRow(a, b, widthStep)) {
            return -1;
        }
    }
    return 1;
}

#endif
