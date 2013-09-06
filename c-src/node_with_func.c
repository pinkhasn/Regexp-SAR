
/*

every time that new regexp added, every node in trie structure
that got function handler switch on flag that it get function.
it prevent cases when some regexps (e.g. ab?b?b?c) set call
function in same node more that once.
when regexp finished build new nodes in trie we need to switch
off that flag so it could get call functions from other regexps.
nodes that need to switch off stored in linked list.

*/



typedef struct sarNodeWithFuncLL_t {
  sarNode_p node;
  struct sarNodeWithFuncLL_t * next;
} sarNodeWithFuncLL_t;

typedef sarNodeWithFuncLL_t * sarNodeWithFuncLL_p;


sarNodeWithFuncLL_p sar_buildNWFNode_c() {
  sarNodeWithFuncLL_p NWFNode;
  Newx(NWFNode, 1, sarNodeWithFuncLL_t);

  NWFNode->node = (sarNode_p)NULL;
  NWFNode->next = (sarNodeWithFuncLL_p)NULL;

  return NWFNode;
}

void sar_addNWF_c(sarNodeWithFuncLL_p firstNWF, sarNode_p node) {
  sarNodeWithFuncLL_p currNWF = firstNWF;
  while ( currNWF->next != (sarNodeWithFuncLL_p)NULL ) {
    currNWF = currNWF->next;
  }

  sarNodeWithFuncLL_p lastNWFNode =  sar_buildNWFNode_c();
  currNWF->node = node;
  currNWF->next = lastNWFNode;
}


void sar_clearNWFNodes_c(sarNodeWithFuncLL_p firstNWF) {
  sarNodeWithFuncLL_p currNWF = firstNWF;
  while ( currNWF->node != (sarNode_p)NULL ) {
    sarNode_p currNode = currNWF->node;
    currNode->nodeCalled = 0;
    sarNodeWithFuncLL_p nextNWF = currNWF->next;
    Safefree(currNWF);
    currNWF = nextNWF;
  }

  Safefree(currNWF);
}











