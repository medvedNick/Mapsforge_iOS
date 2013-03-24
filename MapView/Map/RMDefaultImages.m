//
//  RMDefaultImages.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <math.h>

#import "RMDefaultImages.h"

#pragma mark Local constants

static const struct
{
  size_t width;
  size_t height;
  size_t bytesPerPixel; /* 3:RGB, 4:RGBA */ 
  unsigned char pixelData[16 * 16 * 4 + 1];
}
UserLocationImage =
{
  16, 16, 4,
  "\377\377\377\0\377\377\377\0\377\377\377\0\377\377\377\0\0\6\23(\0\16""6"
  "\226\0\21J\262\0\25\\\312\0\25]\313\0\23L\263\0\16""8\227\0\6\31)\377\377"
  "\377\0\377\377\377\0\377\377\377\0\377\377\377\0\377\377\377\0\377\377\377"
  "\0\0\0\0\2\0\12,\200\0\34x\327\0;\370\341\0<\377\340\0<\377\341\0<\377\342"
  "\0<\377\344\0:\370\350\0\35z\333\0\12-\201\0\0\0\2\377\377\377\0\377\377"
  "\377\0\377\377\377\0\0\0\0\2\0\15""6\262\0""0\316\337\0""9\377\323\0""4\377"
  "\300\0""4\377\277\0""8\377\321\0;\377\337\0<\377\342\0<\377\345\0<\377\350"
  "\0""1\320\351\10\27:\265\0\0\0\2\377\377\377\0\377\377\377\0\0\12,\200\0"
  """0\316\340\0""8\377\312\0+\377\237\0%\377\204\0#\377\203\0+\377\234\0""5"
  "\377\305\0<\377\340\0<\377\343\0<\377\346\0<\377\352\0""1\320\352\22\35""1"
  "\203\377\377\377\0\0\6\23(\0\34x\327\0<\377\336\0/\377\252\0\37\377t\0\25"
  "\377J\0\25\377H\0\36\377o\0,\377\244\0<\377\336\0<\377\342\0<\377\345\0<"
  "\377\351\0=\377\354,N\200\344\14\23\31)\0\16""6\226\0;\370\342\0:\377\332"
  "\0*\377\235\0\33\377_\0\10\377\"\0\11\377\35\0\27\377Y\0)\377\227\0""9\377"
  "\324\0<\377\341\0<\377\345\0<\377\350\0=\377\354T\231\371\377\24%:\231\0"
  "\23L\263\0<\377\342\0<\377\336\0-\377\246\0\36\377n\0\24\377A\0\20\377>\0"
  "\35\377i\0+\377\241\0;\377\333\0<\377\341\0<\377\345\0<\377\351\0=\377\354"
  "V\235\377\377\34""2Q\271\0\25]\313\0<\377\343\0;\377\337\0""6\377\303\0)"
  "\377\227\0!\377z\0\40\377x\0(\377\223\0""4\377\277\0;\377\337\0<\377\343"
  "\0<\377\346\0<\377\351\0<\377\355V\235\377\377\"<c\323\0\27^\314\0<\377\345"
  "\0<\377\342\0;\377\337\0""8\377\312\0""1\377\265\0""2\377\264\0""6\377\307"
  "\0;\377\337\0<\377\341\0<\377\344\0<\377\347\0<\377\353\15K\377\361V\235"
  "\377\377\"<c\323\0\22M\264\0<\377\347\0<\377\344\0<\377\342\0<\377\340\0"
  ";\377\337\0;\377\337\0<\377\340\0<\377\342\0<\377\344\0<\377\346\0<\377\351"
  "\0=\377\354V\235\377\377V\235\377\377\34""2Q\271\0\16""8\227\0;\370\352\0"
  "<\377\347\0<\377\345\0<\377\344\0<\377\343\0<\377\343\0<\377\343\0<\377\345"
  "\0<\377\347\0<\377\351\0=\377\3542t\377\370V\235\377\377T\231\371\377\24"
  "%:\231\6\14\31)\0\35{\334\0<\377\352\0<\377\350\0<\377\347\0<\377\346\0<"
  "\377\346\0<\377\347\0<\377\350\0<\377\352\0=\377\354\30W\377\363V\235\377"
  "\377V\235\377\377,N\200\344\14\23\31)\377\377\377\0\22\35""1\203\0""1\320"
  "\352\0=\377\354\0<\377\353\0<\377\352\0<\377\352\0<\377\353\0=\377\354\0"
  "<\377\355S\232\377\376V\235\377\377V\235\377\377H\202\323\371\22\35""1\203"
  "\377\377\377\0\377\377\377\0\0\0\0\2\24$<\267H\202\323\371\30W\377\363\0"
  "<\377\356\0<\377\356\23Q\377\362V\235\377\377V\235\377\377V\235\377\377V"
  "\235\377\377H\202\323\371\24$<\267\0\0\0\2\377\377\377\0\377\377\377\0\377"
  "\377\377\0\0\0\0\2\22\35""1\203,N\200\344T\231\371\377V\235\377\377V\235"
  "\377\377V\235\377\377V\235\377\377T\231\371\377,N\200\344\22\35""1\203\0"
  "\0\0\2\377\377\377\0\377\377\377\0\377\377\377\0\377\377\377\0\377\377\377"
  "\0\377\377\377\0\14\23\31)\24%:\231\34""2Q\271\"<c\323\"<c\323\34""2Q\271"
  "\24%:\231\14\23\31)\377\377\377\0\377\377\377\0\377\377\377\0\377\377\377"
  "\0"
};

#pragma mark Local function declarations

 /// Creates from RGB or RGBA images a premultiplied RGBA image
 /** @param pixelData     Image in RGB or RGBA format having color values ranging from 0 to 255.
   *                      Its size must be at least width*height*bytesPerPixel.
   * @param width         Width of the image in pixels (must be larger zero).
   * @param height        Height of the image in pixels (must be larger zero).
   * @param bytesPerPixel Number of bytes per pixel.
   * @return              If the construction of the image was successful a newly created image,
   *                      memory allocated by malloc, containing with alpha premultiplied RGB
   *                      and alpha values. If one of the parameters did not fulfill specs
   *                      NULL is returned. */
  static unsigned char* CreatePremultipliedRGBA(unsigned char const* pixelData, size_t width, size_t height, size_t bytesPerPixel);

 /// Returns an image created from internal image data
 /** @param @param pixelData     Image in RGB or RGBA format having color values ranging from 0 to 255.
   *                      Its size must be at least width*height*bytesPerPixel.
   * @param width         Width of the image in pixels (must be larger zero).
   * @param height        Height of the image in pixels (must be larger zero).
   * @param bytesPerPixel Number of bytes per pixel.
   * @return              An autorelease UIImage initialized with the passed image. If the construction
   *                      failed nil is returned. */
  static UIImage* GetDefaultImage(unsigned char const* pixelData, size_t width, size_t height, size_t bytesPerPixel);

#pragma mark Public functions
UIImage* GetDefaultUserLocationMarkerImage(void)
{
  return [UIImage imageNamed:@"blueCircle.png"];
  //return GetDefaultImage(UserLocationImage.pixelData,UserLocationImage.width,UserLocationImage.height,UserLocationImage.bytesPerPixel);
}

#pragma mark Local function definitions
static unsigned char* CreatePremultipliedRGBA(unsigned char const* pixelData, size_t width, size_t height, size_t bytesPerPixel)
{
  unsigned char* premultipliedRGBA = NULL;


  if ((pixelData != NULL) && (width > 0) && (height > 0))
  {
    if (bytesPerPixel == 3)
    {
      premultipliedRGBA = malloc(width*height*4);
      if (premultipliedRGBA != NULL)
      {
        size_t pixelBasedRowStartIndex = 0;

        for (size_t j=0; j<UserLocationImage.height; ++j)
        {
          for (size_t i=0; i<UserLocationImage.width; ++i)
          {
            premultipliedRGBA[4*(pixelBasedRowStartIndex+i)]   = pixelData[3*(pixelBasedRowStartIndex+i)];
            premultipliedRGBA[4*(pixelBasedRowStartIndex+i)+1] = pixelData[3*(pixelBasedRowStartIndex+i)+1];
            premultipliedRGBA[4*(pixelBasedRowStartIndex+i)+2] = pixelData[3*(pixelBasedRowStartIndex+i)+2];
            premultipliedRGBA[4*(pixelBasedRowStartIndex+i)+3] = (unsigned char)255; // for RGB images the alpha value is to be 255, 1 respectively
          }
          pixelBasedRowStartIndex += width;
        }
      }
    }
    else if (bytesPerPixel == 4)
    {
      premultipliedRGBA = malloc(width*height*4);
      if (premultipliedRGBA != NULL)
      {
        size_t pixelBasedRowStartIndex = 0;

        for (size_t j=0; j<UserLocationImage.height; ++j)
        {
          for (size_t i=0; i<UserLocationImage.width; ++i)
          {
            double scaledAlpha = (1.0/255.0)*(double)UserLocationImage.pixelData[4*(pixelBasedRowStartIndex+i)+3];

            premultipliedRGBA[4*(pixelBasedRowStartIndex+i)]   = (unsigned char)round((double)UserLocationImage.pixelData[4*(pixelBasedRowStartIndex+i)]*  scaledAlpha);
            premultipliedRGBA[4*(pixelBasedRowStartIndex+i)+1] = (unsigned char)round((double)UserLocationImage.pixelData[4*(pixelBasedRowStartIndex+i)+1]*scaledAlpha);
            premultipliedRGBA[4*(pixelBasedRowStartIndex+i)+2] = (unsigned char)round((double)UserLocationImage.pixelData[4*(pixelBasedRowStartIndex+i)+2]*scaledAlpha);
            premultipliedRGBA[4*(pixelBasedRowStartIndex+i)+3] = UserLocationImage.pixelData[4*(pixelBasedRowStartIndex+i)+3];
          }
          pixelBasedRowStartIndex += width;
        }
      }
    }
  }
  return premultipliedRGBA;
}

static UIImage* GetDefaultImage(unsigned char const* pixelData, size_t width, size_t height, size_t bytesPerPixel)
{
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

  UIImage* userLocationMarkerImage = nil;


  if (colorSpace != NULL)
  {
   // we can also use directly RGB images but at the moment we create only RGBA images and therefore
   // the following code does not have to be optimized for RGB images
    unsigned char* premultipliedRGBA = CreatePremultipliedRGBA(pixelData,width,height,bytesPerPixel);

    if (premultipliedRGBA != NULL)
    {
      CGContextRef bitmapContext = CGBitmapContextCreate(premultipliedRGBA,width,height,8,4*width,
                                                         colorSpace,kCGImageAlphaPremultipliedLast); // non-premultiplied alpha values are not supported

      if (bitmapContext != NULL)
      {
        CGImageRef bitmapImage = CGBitmapContextCreateImage(bitmapContext);
        
        if (bitmapImage != NULL)
        {
          userLocationMarkerImage = [UIImage imageWithCGImage:bitmapImage];
          CGImageRelease(bitmapImage);
        }
        CGContextRelease(bitmapContext);
      }
      free(premultipliedRGBA);
    }
    CGColorSpaceRelease(colorSpace);
  }
  return userLocationMarkerImage;
}

