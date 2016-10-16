6350 #include "types.h"
6351 #include "x86.h"
6352 
6353 void*
6354 memset(void *dst, int c, uint n)
6355 {
6356   if ((int)dst%4 == 0 && n%4 == 0){
6357     c &= 0xFF;
6358     stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
6359   } else
6360     stosb(dst, c, n);
6361   return dst;
6362 }
6363 
6364 int
6365 memcmp(const void *v1, const void *v2, uint n)
6366 {
6367   const uchar *s1, *s2;
6368 
6369   s1 = v1;
6370   s2 = v2;
6371   while(n-- > 0){
6372     if(*s1 != *s2)
6373       return *s1 - *s2;
6374     s1++, s2++;
6375   }
6376 
6377   return 0;
6378 }
6379 
6380 void*
6381 memmove(void *dst, const void *src, uint n)
6382 {
6383   const char *s;
6384   char *d;
6385 
6386   s = src;
6387   d = dst;
6388   if(s < d && s + n > d){
6389     s += n;
6390     d += n;
6391     while(n-- > 0)
6392       *--d = *--s;
6393   } else
6394     while(n-- > 0)
6395       *d++ = *s++;
6396 
6397   return dst;
6398 }
6399 
6400 // memcpy exists to placate GCC.  Use memmove.
6401 void*
6402 memcpy(void *dst, const void *src, uint n)
6403 {
6404   return memmove(dst, src, n);
6405 }
6406 
6407 int
6408 strncmp(const char *p, const char *q, uint n)
6409 {
6410   while(n > 0 && *p && *p == *q)
6411     n--, p++, q++;
6412   if(n == 0)
6413     return 0;
6414   return (uchar)*p - (uchar)*q;
6415 }
6416 
6417 char*
6418 strncpy(char *s, const char *t, int n)
6419 {
6420   char *os;
6421 
6422   os = s;
6423   while(n-- > 0 && (*s++ = *t++) != 0)
6424     ;
6425   while(n-- > 0)
6426     *s++ = 0;
6427   return os;
6428 }
6429 
6430 // Like strncpy but guaranteed to NUL-terminate.
6431 char*
6432 safestrcpy(char *s, const char *t, int n)
6433 {
6434   char *os;
6435 
6436   os = s;
6437   if(n <= 0)
6438     return os;
6439   while(--n > 0 && (*s++ = *t++) != 0)
6440     ;
6441   *s = 0;
6442   return os;
6443 }
6444 
6445 
6446 
6447 
6448 
6449 
6450 int
6451 strlen(const char *s)
6452 {
6453   int n;
6454 
6455   for(n = 0; s[n]; n++)
6456     ;
6457   return n;
6458 }
6459 
6460 
6461 
6462 
6463 
6464 
6465 
6466 
6467 
6468 
6469 
6470 
6471 
6472 
6473 
6474 
6475 
6476 
6477 
6478 
6479 
6480 
6481 
6482 
6483 
6484 
6485 
6486 
6487 
6488 
6489 
6490 
6491 
6492 
6493 
6494 
6495 
6496 
6497 
6498 
6499 
