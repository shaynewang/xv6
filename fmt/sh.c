8050 // Shell.
8051 // 2015-12-21. Added very simple processing for builtin commands
8052 
8053 #include "types.h"
8054 #include "user.h"
8055 #include "fcntl.h"
8056 
8057 // Parsed command representation
8058 #define EXEC  1
8059 #define REDIR 2
8060 #define PIPE  3
8061 #define LIST  4
8062 #define BACK  5
8063 
8064 #define MAXARGS 10
8065 
8066 struct cmd {
8067   int type;
8068 };
8069 
8070 struct execcmd {
8071   int type;
8072   char *argv[MAXARGS];
8073   char *eargv[MAXARGS];
8074 };
8075 
8076 struct redircmd {
8077   int type;
8078   struct cmd *cmd;
8079   char *file;
8080   char *efile;
8081   int mode;
8082   int fd;
8083 };
8084 
8085 struct pipecmd {
8086   int type;
8087   struct cmd *left;
8088   struct cmd *right;
8089 };
8090 
8091 struct listcmd {
8092   int type;
8093   struct cmd *left;
8094   struct cmd *right;
8095 };
8096 
8097 
8098 
8099 
8100 struct backcmd {
8101   int type;
8102   struct cmd *cmd;
8103 };
8104 
8105 int fork1(void);  // Fork but panics on failure.
8106 void panic(char*);
8107 struct cmd *parsecmd(char*);
8108 
8109 // Execute cmd.  Never returns.
8110 void
8111 runcmd(struct cmd *cmd)
8112 {
8113   int p[2];
8114   struct backcmd *bcmd;
8115   struct execcmd *ecmd;
8116   struct listcmd *lcmd;
8117   struct pipecmd *pcmd;
8118   struct redircmd *rcmd;
8119 
8120   if(cmd == 0)
8121     exit();
8122 
8123   switch(cmd->type){
8124   default:
8125     panic("runcmd");
8126 
8127   case EXEC:
8128     ecmd = (struct execcmd*)cmd;
8129     if(ecmd->argv[0] == 0)
8130       exit();
8131     exec(ecmd->argv[0], ecmd->argv);
8132     printf(2, "exec %s failed\n", ecmd->argv[0]);
8133     break;
8134 
8135   case REDIR:
8136     rcmd = (struct redircmd*)cmd;
8137     close(rcmd->fd);
8138     if(open(rcmd->file, rcmd->mode) < 0){
8139       printf(2, "open %s failed\n", rcmd->file);
8140       exit();
8141     }
8142     runcmd(rcmd->cmd);
8143     break;
8144 
8145   case LIST:
8146     lcmd = (struct listcmd*)cmd;
8147     if(fork1() == 0)
8148       runcmd(lcmd->left);
8149     wait();
8150     runcmd(lcmd->right);
8151     break;
8152 
8153   case PIPE:
8154     pcmd = (struct pipecmd*)cmd;
8155     if(pipe(p) < 0)
8156       panic("pipe");
8157     if(fork1() == 0){
8158       close(1);
8159       dup(p[1]);
8160       close(p[0]);
8161       close(p[1]);
8162       runcmd(pcmd->left);
8163     }
8164     if(fork1() == 0){
8165       close(0);
8166       dup(p[0]);
8167       close(p[0]);
8168       close(p[1]);
8169       runcmd(pcmd->right);
8170     }
8171     close(p[0]);
8172     close(p[1]);
8173     wait();
8174     wait();
8175     break;
8176 
8177   case BACK:
8178     bcmd = (struct backcmd*)cmd;
8179     if(fork1() == 0)
8180       runcmd(bcmd->cmd);
8181     break;
8182   }
8183   exit();
8184 }
8185 
8186 int
8187 getcmd(char *buf, int nbuf)
8188 {
8189   printf(2, "$ ");
8190   memset(buf, 0, nbuf);
8191   gets(buf, nbuf);
8192   if(buf[0] == 0) // EOF
8193     return -1;
8194   return 0;
8195 }
8196 
8197 
8198 
8199 
8200 #ifdef USE_BUILTINS
8201 // ***** processing for shell builtins begins here *****
8202 
8203 int
8204 strncmp(const char *p, const char *q, uint n)
8205 {
8206     while(n > 0 && *p && *p == *q)
8207       n--, p++, q++;
8208     if(n == 0)
8209       return 0;
8210     return (uchar)*p - (uchar)*q;
8211 }
8212 
8213 int
8214 makeint(char *p)
8215 {
8216   int val = 0;
8217 
8218   while ((*p >= '0') && (*p <= '9')) {
8219     val = 10*val + (*p-'0');
8220     ++p;
8221   }
8222   return val;
8223 }
8224 
8225 int
8226 setbuiltin(char *p)
8227 {
8228   int i;
8229 
8230   p += strlen("_set");
8231   while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
8232   if (strncmp("uid", p, 3) == 0) {
8233     p += strlen("uid");
8234     while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
8235     i = makeint(p); // ugly
8236     return (setuid(i));
8237   } else
8238   if (strncmp("gid", p, 3) == 0) {
8239     p += strlen("gid");
8240     while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
8241     i = makeint(p); // ugly
8242     return (setgid(i));
8243   }
8244   printf(2, "Invalid _set parameter\n");
8245   return -1;
8246 }
8247 
8248 
8249 
8250 int
8251 getbuiltin(char *p)
8252 {
8253   p += strlen("_get");
8254   while (strncmp(p, " ", 1) == 0) p++; // chomp spaces
8255   if (strncmp("uid", p, 3) == 0) {
8256     printf(2, "%d\n", getuid());
8257     return 0;
8258   }
8259   if (strncmp("gid", p, 3) == 0) {
8260     printf(2, "%d\n", getgid());
8261     return 0;
8262   }
8263   printf(2, "Invalid _get parameter\n");
8264   return -1;
8265 }
8266 
8267 typedef int funcPtr_t(char *);
8268 typedef struct {
8269   char       *cmd;
8270   funcPtr_t  *name;
8271 } dispatchTableEntry_t;
8272 
8273 // Use a simple function dispatch table (FDT) to process builtin commands
8274 dispatchTableEntry_t fdt[] = {
8275   {"_set", setbuiltin},
8276   {"_get", getbuiltin}
8277 };
8278 int FDTcount = sizeof(fdt) / sizeof(fdt[0]); // # entris in FDT
8279 
8280 void
8281 dobuiltin(char *cmd) {
8282   int i;
8283 
8284   for (i=0; i<FDTcount; i++)
8285     if (strncmp(cmd, fdt[i].cmd, strlen(fdt[i].cmd)) == 0)
8286      (*fdt[i].name)(cmd);
8287 }
8288 
8289 
8290 
8291 
8292 
8293 
8294 
8295 
8296 
8297 
8298 
8299 
8300 // ***** processing for shell builtins ends here *****
8301 #endif
8302 
8303 int
8304 main(void)
8305 {
8306   static char buf[100];
8307   int fd;
8308 
8309   // Assumes three file descriptors open.
8310   while((fd = open("console", O_RDWR)) >= 0){
8311     if(fd >= 3){
8312       close(fd);
8313       break;
8314     }
8315   }
8316 
8317   // Read and run input commands.
8318   while(getcmd(buf, sizeof(buf)) >= 0){
8319 // add support for built-ins here. cd is a built-in
8320     if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
8321       // Clumsy but will have to do for now.
8322       // Chdir has no effect on the parent if run in the child.
8323       buf[strlen(buf)-1] = 0;  // chop \n
8324       if(chdir(buf+3) < 0)
8325         printf(2, "cannot cd %s\n", buf+3);
8326       continue;
8327     }
8328 #ifdef USE_BUILTINS
8329     if (buf[0]=='_') {     // assume it is a builtin command
8330       dobuiltin(buf);
8331       continue;
8332     }
8333 #endif
8334     if(fork1() == 0)
8335       runcmd(parsecmd(buf));
8336     wait();
8337   }
8338   exit();
8339 }
8340 
8341 void
8342 panic(char *s)
8343 {
8344   printf(2, "%s\n", s);
8345   exit();
8346 }
8347 
8348 
8349 
8350 int
8351 fork1(void)
8352 {
8353   int pid;
8354 
8355   pid = fork();
8356   if(pid == -1)
8357     panic("fork");
8358   return pid;
8359 }
8360 
8361 // Constructors
8362 
8363 struct cmd*
8364 execcmd(void)
8365 {
8366   struct execcmd *cmd;
8367 
8368   cmd = malloc(sizeof(*cmd));
8369   memset(cmd, 0, sizeof(*cmd));
8370   cmd->type = EXEC;
8371   return (struct cmd*)cmd;
8372 }
8373 
8374 struct cmd*
8375 redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
8376 {
8377   struct redircmd *cmd;
8378 
8379   cmd = malloc(sizeof(*cmd));
8380   memset(cmd, 0, sizeof(*cmd));
8381   cmd->type = REDIR;
8382   cmd->cmd = subcmd;
8383   cmd->file = file;
8384   cmd->efile = efile;
8385   cmd->mode = mode;
8386   cmd->fd = fd;
8387   return (struct cmd*)cmd;
8388 }
8389 
8390 
8391 
8392 
8393 
8394 
8395 
8396 
8397 
8398 
8399 
8400 struct cmd*
8401 pipecmd(struct cmd *left, struct cmd *right)
8402 {
8403   struct pipecmd *cmd;
8404 
8405   cmd = malloc(sizeof(*cmd));
8406   memset(cmd, 0, sizeof(*cmd));
8407   cmd->type = PIPE;
8408   cmd->left = left;
8409   cmd->right = right;
8410   return (struct cmd*)cmd;
8411 }
8412 
8413 struct cmd*
8414 listcmd(struct cmd *left, struct cmd *right)
8415 {
8416   struct listcmd *cmd;
8417 
8418   cmd = malloc(sizeof(*cmd));
8419   memset(cmd, 0, sizeof(*cmd));
8420   cmd->type = LIST;
8421   cmd->left = left;
8422   cmd->right = right;
8423   return (struct cmd*)cmd;
8424 }
8425 
8426 struct cmd*
8427 backcmd(struct cmd *subcmd)
8428 {
8429   struct backcmd *cmd;
8430 
8431   cmd = malloc(sizeof(*cmd));
8432   memset(cmd, 0, sizeof(*cmd));
8433   cmd->type = BACK;
8434   cmd->cmd = subcmd;
8435   return (struct cmd*)cmd;
8436 }
8437 
8438 
8439 
8440 
8441 
8442 
8443 
8444 
8445 
8446 
8447 
8448 
8449 
8450 // Parsing
8451 
8452 char whitespace[] = " \t\r\n\v";
8453 char symbols[] = "<|>&;()";
8454 
8455 int
8456 gettoken(char **ps, char *es, char **q, char **eq)
8457 {
8458   char *s;
8459   int ret;
8460 
8461   s = *ps;
8462   while(s < es && strchr(whitespace, *s))
8463     s++;
8464   if(q)
8465     *q = s;
8466   ret = *s;
8467   switch(*s){
8468   case 0:
8469     break;
8470   case '|':
8471   case '(':
8472   case ')':
8473   case ';':
8474   case '&':
8475   case '<':
8476     s++;
8477     break;
8478   case '>':
8479     s++;
8480     if(*s == '>'){
8481       ret = '+';
8482       s++;
8483     }
8484     break;
8485   default:
8486     ret = 'a';
8487     while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
8488       s++;
8489     break;
8490   }
8491   if(eq)
8492     *eq = s;
8493 
8494   while(s < es && strchr(whitespace, *s))
8495     s++;
8496   *ps = s;
8497   return ret;
8498 }
8499 
8500 int
8501 peek(char **ps, char *es, char *toks)
8502 {
8503   char *s;
8504 
8505   s = *ps;
8506   while(s < es && strchr(whitespace, *s))
8507     s++;
8508   *ps = s;
8509   return *s && strchr(toks, *s);
8510 }
8511 
8512 struct cmd *parseline(char**, char*);
8513 struct cmd *parsepipe(char**, char*);
8514 struct cmd *parseexec(char**, char*);
8515 struct cmd *nulterminate(struct cmd*);
8516 
8517 struct cmd*
8518 parsecmd(char *s)
8519 {
8520   char *es;
8521   struct cmd *cmd;
8522 
8523   es = s + strlen(s);
8524   cmd = parseline(&s, es);
8525   peek(&s, es, "");
8526   if(s != es){
8527     printf(2, "leftovers: %s\n", s);
8528     panic("syntax");
8529   }
8530   nulterminate(cmd);
8531   return cmd;
8532 }
8533 
8534 struct cmd*
8535 parseline(char **ps, char *es)
8536 {
8537   struct cmd *cmd;
8538 
8539   cmd = parsepipe(ps, es);
8540   while(peek(ps, es, "&")){
8541     gettoken(ps, es, 0, 0);
8542     cmd = backcmd(cmd);
8543   }
8544   if(peek(ps, es, ";")){
8545     gettoken(ps, es, 0, 0);
8546     cmd = listcmd(cmd, parseline(ps, es));
8547   }
8548   return cmd;
8549 }
8550 struct cmd*
8551 parsepipe(char **ps, char *es)
8552 {
8553   struct cmd *cmd;
8554 
8555   cmd = parseexec(ps, es);
8556   if(peek(ps, es, "|")){
8557     gettoken(ps, es, 0, 0);
8558     cmd = pipecmd(cmd, parsepipe(ps, es));
8559   }
8560   return cmd;
8561 }
8562 
8563 struct cmd*
8564 parseredirs(struct cmd *cmd, char **ps, char *es)
8565 {
8566   int tok;
8567   char *q, *eq;
8568 
8569   while(peek(ps, es, "<>")){
8570     tok = gettoken(ps, es, 0, 0);
8571     if(gettoken(ps, es, &q, &eq) != 'a')
8572       panic("missing file for redirection");
8573     switch(tok){
8574     case '<':
8575       cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
8576       break;
8577     case '>':
8578       cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
8579       break;
8580     case '+':  // >>
8581       cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
8582       break;
8583     }
8584   }
8585   return cmd;
8586 }
8587 
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
8600 struct cmd*
8601 parseblock(char **ps, char *es)
8602 {
8603   struct cmd *cmd;
8604 
8605   if(!peek(ps, es, "("))
8606     panic("parseblock");
8607   gettoken(ps, es, 0, 0);
8608   cmd = parseline(ps, es);
8609   if(!peek(ps, es, ")"))
8610     panic("syntax - missing )");
8611   gettoken(ps, es, 0, 0);
8612   cmd = parseredirs(cmd, ps, es);
8613   return cmd;
8614 }
8615 
8616 struct cmd*
8617 parseexec(char **ps, char *es)
8618 {
8619   char *q, *eq;
8620   int tok, argc;
8621   struct execcmd *cmd;
8622   struct cmd *ret;
8623 
8624   if(peek(ps, es, "("))
8625     return parseblock(ps, es);
8626 
8627   ret = execcmd();
8628   cmd = (struct execcmd*)ret;
8629 
8630   argc = 0;
8631   ret = parseredirs(ret, ps, es);
8632   while(!peek(ps, es, "|)&;")){
8633     if((tok=gettoken(ps, es, &q, &eq)) == 0)
8634       break;
8635     if(tok != 'a')
8636       panic("syntax");
8637     cmd->argv[argc] = q;
8638     cmd->eargv[argc] = eq;
8639     argc++;
8640     if(argc >= MAXARGS)
8641       panic("too many args");
8642     ret = parseredirs(ret, ps, es);
8643   }
8644   cmd->argv[argc] = 0;
8645   cmd->eargv[argc] = 0;
8646   return ret;
8647 }
8648 
8649 
8650 // NUL-terminate all the counted strings.
8651 struct cmd*
8652 nulterminate(struct cmd *cmd)
8653 {
8654   int i;
8655   struct backcmd *bcmd;
8656   struct execcmd *ecmd;
8657   struct listcmd *lcmd;
8658   struct pipecmd *pcmd;
8659   struct redircmd *rcmd;
8660 
8661   if(cmd == 0)
8662     return 0;
8663 
8664   switch(cmd->type){
8665   case EXEC:
8666     ecmd = (struct execcmd*)cmd;
8667     for(i=0; ecmd->argv[i]; i++)
8668       *ecmd->eargv[i] = 0;
8669     break;
8670 
8671   case REDIR:
8672     rcmd = (struct redircmd*)cmd;
8673     nulterminate(rcmd->cmd);
8674     *rcmd->efile = 0;
8675     break;
8676 
8677   case PIPE:
8678     pcmd = (struct pipecmd*)cmd;
8679     nulterminate(pcmd->left);
8680     nulterminate(pcmd->right);
8681     break;
8682 
8683   case LIST:
8684     lcmd = (struct listcmd*)cmd;
8685     nulterminate(lcmd->left);
8686     nulterminate(lcmd->right);
8687     break;
8688 
8689   case BACK:
8690     bcmd = (struct backcmd*)cmd;
8691     nulterminate(bcmd->cmd);
8692     break;
8693   }
8694   return cmd;
8695 }
8696 
8697 
8698 
8699 
