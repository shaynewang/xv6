9200 #ifdef CS333_P4
9201 // this is an ugly series of if statements but it works
9202 void
9203 print_mode(struct stat* st)
9204 {
9205   switch (st->type) {
9206     case T_DIR: printf(1, "d"); break;
9207     case T_FILE: printf(1, "-"); break;
9208     case T_DEV: printf(1, "c"); break;
9209     default: printf(1, "?");
9210   }
9211 
9212   if (st->mode.flags.u_r)
9213     printf(1, "r");
9214   else
9215     printf(1, "-");
9216 
9217   if (st->mode.flags.u_w)
9218     printf(1, "w");
9219   else
9220     printf(1, "-");
9221 
9222   if ((st->mode.flags.u_x) & (st->mode.flags.setuid))
9223     printf(1, "S");
9224   else if (st->mode.flags.u_x)
9225     printf(1, "x");
9226   else
9227     printf(1, "-");
9228 
9229   if (st->mode.flags.g_r)
9230     printf(1, "r");
9231   else
9232     printf(1, "-");
9233 
9234   if (st->mode.flags.g_w)
9235     printf(1, "w");
9236   else
9237     printf(1, "-");
9238 
9239   if (st->mode.flags.g_x)
9240     printf(1, "x");
9241   else
9242     printf(1, "-");
9243 
9244   if (st->mode.flags.o_r)
9245     printf(1, "r");
9246   else
9247     printf(1, "-");
9248 
9249 
9250   if (st->mode.flags.o_w)
9251     printf(1, "w");
9252   else
9253     printf(1, "-");
9254 
9255   if (st->mode.flags.o_x)
9256     printf(1, "x");
9257   else
9258     printf(1, "-");
9259 
9260   return;
9261 }
9262 #endif
9263 
9264 
9265 
9266 
9267 
9268 
9269 
9270 
9271 
9272 
9273 
9274 
9275 
9276 
9277 
9278 
9279 
9280 
9281 
9282 
9283 
9284 
9285 
9286 
9287 
9288 
9289 
9290 
9291 
9292 
9293 
9294 
9295 
9296 
9297 
9298 
9299 
