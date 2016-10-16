8900 #ifdef CS333_P4
8901 // this is an ugly series of if statements but it works
8902 void
8903 print_mode(struct stat* st)
8904 {
8905   switch (st->type) {
8906     case T_DIR: printf(1, "d"); break;
8907     case T_FILE: printf(1, "-"); break;
8908     case T_DEV: printf(1, "c"); break;
8909     default: printf(1, "?");
8910   }
8911 
8912   if (st->mode.flags.u_r)
8913     printf(1, "r");
8914   else
8915     printf(1, "-");
8916 
8917   if (st->mode.flags.u_w)
8918     printf(1, "w");
8919   else
8920     printf(1, "-");
8921 
8922   if ((st->mode.flags.u_x) & (st->mode.flags.setuid))
8923     printf(1, "S");
8924   else if (st->mode.flags.u_x)
8925     printf(1, "x");
8926   else
8927     printf(1, "-");
8928 
8929   if (st->mode.flags.g_r)
8930     printf(1, "r");
8931   else
8932     printf(1, "-");
8933 
8934   if (st->mode.flags.g_w)
8935     printf(1, "w");
8936   else
8937     printf(1, "-");
8938 
8939   if (st->mode.flags.g_x)
8940     printf(1, "x");
8941   else
8942     printf(1, "-");
8943 
8944   if (st->mode.flags.o_r)
8945     printf(1, "r");
8946   else
8947     printf(1, "-");
8948 
8949 
8950   if (st->mode.flags.o_w)
8951     printf(1, "w");
8952   else
8953     printf(1, "-");
8954 
8955   if (st->mode.flags.o_x)
8956     printf(1, "x");
8957   else
8958     printf(1, "-");
8959 
8960   return;
8961 }
8962 #endif
8963 
8964 
8965 
8966 
8967 
8968 
8969 
8970 
8971 
8972 
8973 
8974 
8975 
8976 
8977 
8978 
8979 
8980 
8981 
8982 
8983 
8984 
8985 
8986 
8987 
8988 
8989 
8990 
8991 
8992 
8993 
8994 
8995 
8996 
8997 
8998 
8999 
