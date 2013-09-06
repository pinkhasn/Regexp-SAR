


typedef struct sarNode_t {
  int charNumber;
  char * sarPathChars;
  struct sarNode_t ** sarNodes;
  int plusCharSize;
  char * plusChars;
  struct sarNode_t ** plusNodes;
  bool nodeCalled;
  SV ** callFunc;
} sarNode_t;

typedef sarNode_t * sarNode_p;

