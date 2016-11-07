8350 // Shell.
8351 // 2015-12-21. Added very simple processing for builtin commands
8352 
8353 #include "types.h"
8354 #include "user.h"
8355 #include "fcntl.h"
8356 
8357 // Parsed command representation
8358 #define EXEC  1
8359 #define REDIR 2
8360 #define PIPE  3
8361 #define LIST  4
8362 #define BACK  5
8363 
8364 #define MAXARGS 10
8365 
8366 struct cmd {
8367   int type;
8368 };
8369 
8370 struct execcmd {
8371   int type;
8372   char *argv[MAXARGS];
8373   char *eargv[MAXARGS];
8374 };
8375 
8376 struct redircmd {
8377   int type;
8378   struct cmd *cmd;
8379   char *file;
8380   char *efile;
8381   int mode;
8382   int fd;
8383 };
8384 
8385 struct pipecmd {
8386   int type;
8387   struct cmd *left;
8388   struct cmd *right;
8389 };
8390 
8391 struct listcmd {
8392   int type;
8393   struct cmd *left;
8394   struct cmd *right;
8395 };
8396 
8397 
8398 
8399 
8400 struct backcmd {
8401   int type;
8402   struct cmd *cmd;
8403 };
8404 
8405 int fork1(void);  // Fork but panics on failure.
8406 void panic(char*);
8407 struct cmd *parsecmd(char*);
8408 
8409 // Execute cmd.  Never returns.
8410 void
8411 runcmd(struct cmd *cmd)
8412 {
8413   int p[2];
8414   struct backcmd *bcmd;
8415   struct execcmd *ecmd;
8416   struct listcmd *lcmd;
8417   struct pipecmd *pcmd;
8418   struct redircmd *rcmd;
8419 
8420   if(cmd == 0)
8421     exit();
8422 
8423   switch(cmd->type){
8424   default:
8425     panic("runcmd");
8426 
8427   case EXEC:
8428     ecmd = (struct execcmd*)cmd;
8429     if(ecmd->argv[0] == 0)
8430       exit();
8431     exec(ecmd->argv[0], ecmd->argv);
8432     printf(2, "exec %s failed\n", ecmd->argv[0]);
8433     break;
8434 
8435   case REDIR:
8436     rcmd = (struct redircmd*)cmd;
8437     close(rcmd->fd);
8438     if(open(rcmd->file, rcmd->mode) < 0){
8439       printf(2, "open %s failed\n", rcmd->file);
8440       exit();
8441     }
8442     runcmd(rcmd->cmd);
8443     break;
8444 
8445   case LIST:
8446     lcmd = (struct listcmd*)cmd;
8447     if(fork1() == 0)
8448       runcmd(lcmd->left);
8449     wait();
8450     runcmd(lcmd->right);
8451     break;
8452 
8453   case PIPE:
8454     pcmd = (struct pipecmd*)cmd;
8455     if(pipe(p) < 0)
8456       panic("pipe");
8457     if(fork1() == 0){
8458       close(1);
8459       dup(p[1]);
8460       close(p[0]);
8461       close(p[1]);
8462       runcmd(pcmd->left);
8463     }
8464     if(fork1() == 0){
8465       close(0);
8466       dup(p[0]);
8467       close(p[0]);
8468       close(p[1]);
8469       runcmd(pcmd->right);
8470     }
8471     close(p[0]);
8472     close(p[1]);
8473     wait();
8474     wait();
8475     break;
8476 
8477   case BACK:
8478     bcmd = (struct backcmd*)cmd;
8479     if(fork1() == 0)
8480       runcmd(bcmd->cmd);
8481     break;
8482   }
8483   exit();
8484 }
8485 
8486 int
8487 getcmd(char *buf, int nbuf)
8488 {
8489   printf(2, "$ ");
8490   memset(buf, 0, nbuf);
8491   gets(buf, nbuf);
8492   if(buf[0] == 0) // EOF
8493     return -1;
8494   return 0;
8495 }
8496 
8497 
8498 
8499 
8500 #ifdef USE_BUILTINS
8501 // ***** processing for shell builtins begins here *****
8502 
8503 int
8504 strncmp(const char *p, const char *q, uint n)
8505 {
8506     while(n > 0 && *p && *p == *q)
8507       n--, p++, q++;
8508     if(n == 0)
8509       return 0;
8510     return (uchar)*p - (uchar)*q;
8511 }
8512 
8513 int
8514 makeint(char *p)
8515 {
8516   int val = 0;
8517 
8518   while ((*p >= '0') && (*p <= '9')) {
8519     val = 10*val + (*p-'0');
8520     ++p;
8521   }
8522   return val;
8523 }
8524 
8525 int
8526 setbuiltin(char *p)
8527 {
8528   int i;
8529 
8530   p += strlen("_set");
8531   while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
8532   if (strncmp("uid", p, 3) == 0) {
8533     p += strlen("uid");
8534     while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
8535     i = makeint(p); // ugly
8536     return (setuid(i));
8537   } else
8538   if (strncmp("gid", p, 3) == 0) {
8539     p += strlen("gid");
8540     while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
8541     i = makeint(p); // ugly
8542     return (setgid(i));
8543   }
8544   printf(2, "Invalid _set parameter\n");
8545   return -1;
8546 }
8547 
8548 
8549 
8550 int
8551 getbuiltin(char *p)
8552 {
8553   p += strlen("_get");
8554   while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
8555   if (strncmp("uid", p, 3) == 0) {
8556     printf(2, "%d\n", getuid());
8557     return 0;
8558   }
8559   if (strncmp("gid", p, 3) == 0) {
8560     printf(2, "%d\n", getgid());
8561     return 0;
8562   }
8563   printf(2, "Invalid _get parameter\n");
8564   return -1;
8565 }
8566 
8567 typedef int funcPtr_t(char *);
8568 typedef struct {
8569   char       *cmd;
8570   funcPtr_t  *name;
8571 } dispatchTableEntry_t;
8572 
8573 // Use a simple function dispatch table (FDT) to process builtin commands
8574 dispatchTableEntry_t fdt[] = {
8575   {"_set", setbuiltin},
8576   {"_get", getbuiltin}
8577 };
8578 int FDTcount = sizeof(fdt) / sizeof(fdt[0]); // # entris in FDT
8579 
8580 void
8581 dobuiltin(char *cmd) {
8582   int i;
8583 
8584   for (i=0; i<FDTcount; i++)
8585     if (strncmp(cmd, fdt[i].cmd, strlen(fdt[i].cmd)) == 0)
8586      (*fdt[i].name)(cmd);
8587 }
8588 
8589 
8590 
8591 
8592 
8593 
8594 
8595 
8596 
8597 
8598 
8599 
8600 // ***** processing for shell builtins ends here *****
8601 #endif
8602 
8603 int
8604 main(void)
8605 {
8606   static char buf[100];
8607   int fd;
8608 
8609   // Assumes three file descriptors open.
8610   while((fd = open("console", O_RDWR)) >= 0){
8611     if(fd >= 3){
8612       close(fd);
8613       break;
8614     }
8615   }
8616 
8617   // Read and run input commands.
8618   while(getcmd(buf, sizeof(buf)) >= 0){
8619 // add support for built-ins here. cd is a built-in
8620     if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
8621       // Clumsy but will have to do for now.
8622       // Chdir has no effect on the parent if run in the child.
8623       buf[strlen(buf)-1] = 0;  // chop \n
8624       if(chdir(buf+3) < 0)
8625         printf(2, "cannot cd %s\n", buf+3);
8626       continue;
8627     }
8628 #ifdef USE_BUILTINS
8629     if (buf[0]=='_') {     // assume it is a builtin command
8630       dobuiltin(buf);
8631       continue;
8632     }
8633 #endif
8634     if(fork1() == 0)
8635       runcmd(parsecmd(buf));
8636     wait();
8637   }
8638   exit();
8639 }
8640 
8641 void
8642 panic(char *s)
8643 {
8644   printf(2, "%s\n", s);
8645   exit();
8646 }
8647 
8648 
8649 
8650 int
8651 fork1(void)
8652 {
8653   int pid;
8654 
8655   pid = fork();
8656   if(pid == -1)
8657     panic("fork");
8658   return pid;
8659 }
8660 
8661 // Constructors
8662 
8663 struct cmd*
8664 execcmd(void)
8665 {
8666   struct execcmd *cmd;
8667 
8668   cmd = malloc(sizeof(*cmd));
8669   memset(cmd, 0, sizeof(*cmd));
8670   cmd->type = EXEC;
8671   return (struct cmd*)cmd;
8672 }
8673 
8674 struct cmd*
8675 redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
8676 {
8677   struct redircmd *cmd;
8678 
8679   cmd = malloc(sizeof(*cmd));
8680   memset(cmd, 0, sizeof(*cmd));
8681   cmd->type = REDIR;
8682   cmd->cmd = subcmd;
8683   cmd->file = file;
8684   cmd->efile = efile;
8685   cmd->mode = mode;
8686   cmd->fd = fd;
8687   return (struct cmd*)cmd;
8688 }
8689 
8690 
8691 
8692 
8693 
8694 
8695 
8696 
8697 
8698 
8699 
8700 struct cmd*
8701 pipecmd(struct cmd *left, struct cmd *right)
8702 {
8703   struct pipecmd *cmd;
8704 
8705   cmd = malloc(sizeof(*cmd));
8706   memset(cmd, 0, sizeof(*cmd));
8707   cmd->type = PIPE;
8708   cmd->left = left;
8709   cmd->right = right;
8710   return (struct cmd*)cmd;
8711 }
8712 
8713 struct cmd*
8714 listcmd(struct cmd *left, struct cmd *right)
8715 {
8716   struct listcmd *cmd;
8717 
8718   cmd = malloc(sizeof(*cmd));
8719   memset(cmd, 0, sizeof(*cmd));
8720   cmd->type = LIST;
8721   cmd->left = left;
8722   cmd->right = right;
8723   return (struct cmd*)cmd;
8724 }
8725 
8726 struct cmd*
8727 backcmd(struct cmd *subcmd)
8728 {
8729   struct backcmd *cmd;
8730 
8731   cmd = malloc(sizeof(*cmd));
8732   memset(cmd, 0, sizeof(*cmd));
8733   cmd->type = BACK;
8734   cmd->cmd = subcmd;
8735   return (struct cmd*)cmd;
8736 }
8737 
8738 
8739 
8740 
8741 
8742 
8743 
8744 
8745 
8746 
8747 
8748 
8749 
8750 // Parsing
8751 
8752 char whitespace[] = " \t\r\n\v";
8753 char symbols[] = "<|>&;()";
8754 
8755 int
8756 gettoken(char **ps, char *es, char **q, char **eq)
8757 {
8758   char *s;
8759   int ret;
8760 
8761   s = *ps;
8762   while(s < es && strchr(whitespace, *s))
8763     s++;
8764   if(q)
8765     *q = s;
8766   ret = *s;
8767   switch(*s){
8768   case 0:
8769     break;
8770   case '|':
8771   case '(':
8772   case ')':
8773   case ';':
8774   case '&':
8775   case '<':
8776     s++;
8777     break;
8778   case '>':
8779     s++;
8780     if(*s == '>'){
8781       ret = '+';
8782       s++;
8783     }
8784     break;
8785   default:
8786     ret = 'a';
8787     while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
8788       s++;
8789     break;
8790   }
8791   if(eq)
8792     *eq = s;
8793 
8794   while(s < es && strchr(whitespace, *s))
8795     s++;
8796   *ps = s;
8797   return ret;
8798 }
8799 
8800 int
8801 peek(char **ps, char *es, char *toks)
8802 {
8803   char *s;
8804 
8805   s = *ps;
8806   while(s < es && strchr(whitespace, *s))
8807     s++;
8808   *ps = s;
8809   return *s && strchr(toks, *s);
8810 }
8811 
8812 struct cmd *parseline(char**, char*);
8813 struct cmd *parsepipe(char**, char*);
8814 struct cmd *parseexec(char**, char*);
8815 struct cmd *nulterminate(struct cmd*);
8816 
8817 struct cmd*
8818 parsecmd(char *s)
8819 {
8820   char *es;
8821   struct cmd *cmd;
8822 
8823   es = s + strlen(s);
8824   cmd = parseline(&s, es);
8825   peek(&s, es, "");
8826   if(s != es){
8827     printf(2, "leftovers: %s\n", s);
8828     panic("syntax");
8829   }
8830   nulterminate(cmd);
8831   return cmd;
8832 }
8833 
8834 struct cmd*
8835 parseline(char **ps, char *es)
8836 {
8837   struct cmd *cmd;
8838 
8839   cmd = parsepipe(ps, es);
8840   while(peek(ps, es, "&")){
8841     gettoken(ps, es, 0, 0);
8842     cmd = backcmd(cmd);
8843   }
8844   if(peek(ps, es, ";")){
8845     gettoken(ps, es, 0, 0);
8846     cmd = listcmd(cmd, parseline(ps, es));
8847   }
8848   return cmd;
8849 }
8850 struct cmd*
8851 parsepipe(char **ps, char *es)
8852 {
8853   struct cmd *cmd;
8854 
8855   cmd = parseexec(ps, es);
8856   if(peek(ps, es, "|")){
8857     gettoken(ps, es, 0, 0);
8858     cmd = pipecmd(cmd, parsepipe(ps, es));
8859   }
8860   return cmd;
8861 }
8862 
8863 struct cmd*
8864 parseredirs(struct cmd *cmd, char **ps, char *es)
8865 {
8866   int tok;
8867   char *q, *eq;
8868 
8869   while(peek(ps, es, "<>")){
8870     tok = gettoken(ps, es, 0, 0);
8871     if(gettoken(ps, es, &q, &eq) != 'a')
8872       panic("missing file for redirection");
8873     switch(tok){
8874     case '<':
8875       cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
8876       break;
8877     case '>':
8878       cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
8879       break;
8880     case '+':  // >>
8881       cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
8882       break;
8883     }
8884   }
8885   return cmd;
8886 }
8887 
8888 
8889 
8890 
8891 
8892 
8893 
8894 
8895 
8896 
8897 
8898 
8899 
8900 struct cmd*
8901 parseblock(char **ps, char *es)
8902 {
8903   struct cmd *cmd;
8904 
8905   if(!peek(ps, es, "("))
8906     panic("parseblock");
8907   gettoken(ps, es, 0, 0);
8908   cmd = parseline(ps, es);
8909   if(!peek(ps, es, ")"))
8910     panic("syntax - missing )");
8911   gettoken(ps, es, 0, 0);
8912   cmd = parseredirs(cmd, ps, es);
8913   return cmd;
8914 }
8915 
8916 struct cmd*
8917 parseexec(char **ps, char *es)
8918 {
8919   char *q, *eq;
8920   int tok, argc;
8921   struct execcmd *cmd;
8922   struct cmd *ret;
8923 
8924   if(peek(ps, es, "("))
8925     return parseblock(ps, es);
8926 
8927   ret = execcmd();
8928   cmd = (struct execcmd*)ret;
8929 
8930   argc = 0;
8931   ret = parseredirs(ret, ps, es);
8932   while(!peek(ps, es, "|)&;")){
8933     if((tok=gettoken(ps, es, &q, &eq)) == 0)
8934       break;
8935     if(tok != 'a')
8936       panic("syntax");
8937     cmd->argv[argc] = q;
8938     cmd->eargv[argc] = eq;
8939     argc++;
8940     if(argc >= MAXARGS)
8941       panic("too many args");
8942     ret = parseredirs(ret, ps, es);
8943   }
8944   cmd->argv[argc] = 0;
8945   cmd->eargv[argc] = 0;
8946   return ret;
8947 }
8948 
8949 
8950 // NUL-terminate all the counted strings.
8951 struct cmd*
8952 nulterminate(struct cmd *cmd)
8953 {
8954   int i;
8955   struct backcmd *bcmd;
8956   struct execcmd *ecmd;
8957   struct listcmd *lcmd;
8958   struct pipecmd *pcmd;
8959   struct redircmd *rcmd;
8960 
8961   if(cmd == 0)
8962     return 0;
8963 
8964   switch(cmd->type){
8965   case EXEC:
8966     ecmd = (struct execcmd*)cmd;
8967     for(i=0; ecmd->argv[i]; i++)
8968       *ecmd->eargv[i] = 0;
8969     break;
8970 
8971   case REDIR:
8972     rcmd = (struct redircmd*)cmd;
8973     nulterminate(rcmd->cmd);
8974     *rcmd->efile = 0;
8975     break;
8976 
8977   case PIPE:
8978     pcmd = (struct pipecmd*)cmd;
8979     nulterminate(pcmd->left);
8980     nulterminate(pcmd->right);
8981     break;
8982 
8983   case LIST:
8984     lcmd = (struct listcmd*)cmd;
8985     nulterminate(lcmd->left);
8986     nulterminate(lcmd->right);
8987     break;
8988 
8989   case BACK:
8990     bcmd = (struct backcmd*)cmd;
8991     nulterminate(bcmd->cmd);
8992     break;
8993   }
8994   return cmd;
8995 }
8996 
8997 
8998 
8999 
