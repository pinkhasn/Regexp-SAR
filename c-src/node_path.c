
int sar_searchChar_c(char * chars, int charsSize, char pathChar) {
  int imax = charsSize - 1;
  int imin = 0;

  while (imax >= imin) {
    int imid = (imin + imax) / 2;
    char checkChar = chars[imid];

    if (pathChar < checkChar) {
      imax = imid - 1;
    }
    else if (pathChar > checkChar) {
      imin = imid + 1;
    }
    else {
      return imid;
    }
  }

  return -1;
}



void sar_runCallFunc_c (SV* callFunc, int charOffset, int currStart) {
  dSP;
  int matchLength = charOffset - currStart + 1;

  ENTER;
  SAVETMPS;

  PUSHMARK(SP);
  XPUSHs(sv_2mortal(newSViv(currStart)));
  XPUSHs(sv_2mortal(newSViv(matchLength)));
  PUTBACK;

  call_sv(callFunc, G_DISCARD);

  FREETMPS;
  LEAVE;
}



void checkPosition(int charOffset, sarNode_p currNode, char * checkStr, int currStart) {
    char checkChar = checkStr[charOffset];

    int existNodePos = sar_searchChar_c(currNode->sarPathChars, currNode->charNumber, checkChar);
    if (existNodePos >= 0) {
      sarNode_p nextNode = currNode->sarNodes[existNodePos];
      int currCallIdx = 0;
      while ( nextNode->callFunc[currCallIdx] != (SV*)NULL ) {
	sar_runCallFunc_c(nextNode->callFunc[currCallIdx], charOffset, currStart);
	++currCallIdx;
      }

      checkPosition(charOffset+1, nextNode, checkStr, currStart);
    }

    int existPlusPos = sar_searchChar_c(currNode->plusChars, currNode->plusCharSize, checkChar);
    if (existPlusPos >= 0) {
      sarNode_p nextNode = currNode->plusNodes[existPlusPos];
      int currCallIdx = 0;
      while ( nextNode->callFunc[currCallIdx] != (SV*)NULL ) {
	sar_runCallFunc_c(nextNode->callFunc[currCallIdx], charOffset, currStart);
	++currCallIdx;
      }

      checkPosition(charOffset+1, nextNode, checkStr, currStart);
    }

}




void sar_lookPath_c(sarNode_p rootNode, char * checkStr) {
  int currStart = 0;
  char startChar = checkStr[currStart];
  while ( startChar != '\0' ) {
    checkPosition(currStart, rootNode, checkStr, currStart);
    ++currStart;
    startChar = checkStr[currStart];
  }
}




sarNode_p sar_buildNode_c() {
  sarNode_p newNode;
  Newx(newNode, 1, sarNode_t);

  char * nodeChars;
  sarNode_p *nodes;
  newNode->charNumber = 0;
  newNode->sarNodes = nodes;
  newNode->sarPathChars = nodeChars;

  char * plusChars;
  sarNode_p *plusNodes;
  newNode->plusCharSize = 0;
  newNode->plusNodes = plusNodes;
  newNode->plusChars = plusChars;

  Newx(newNode->callFunc, 1, SV*);
  newNode->callFunc[0] = (SV*)NULL;
  newNode->nodeCalled = 0;
  return newNode;
}


void sar_nodeAddCharNode_c(sarNode_p node, sarNode_p newNode, char newChar) {
  int currSize = node->charNumber;

  int newSize = currSize+1;
  Renew(node->sarPathChars, newSize, char);
  Renew(node->sarNodes, newSize, sarNode_p);
  node->charNumber = newSize;

  int charOffset = 0;
  while(charOffset < currSize) {
    if (newChar < node->sarPathChars[charOffset]) {
      break;
    }
    ++charOffset;
  }

  int cpOffset = currSize;
  while(cpOffset > charOffset) {
    node->sarPathChars[cpOffset] = node->sarPathChars[cpOffset - 1];
    node->sarNodes[cpOffset] = node->sarNodes[cpOffset - 1];
    --cpOffset;
  }

  node->sarPathChars[cpOffset] = newChar;
  node->sarNodes[cpOffset] = newNode;
}



sarNode_p sar_nodeAddCharSorted_c(sarNode_p node, char newChar) {
  int existNodePos = sar_searchChar_c(node->sarPathChars, node->charNumber, newChar);
  if (existNodePos >= 0 ) {
    return node->sarNodes[existNodePos];
  }

  sarNode_p newNode = sar_buildNode_c();
  sar_nodeAddCharNode_c(node, newNode, newChar);
  return newNode;
}



void sar_setCallFunc_c(sarNode_p currNode, SV * callFunc, sarNodeWithFuncLL_p firstNWF) {

  if ( currNode->nodeCalled == 0 ) {
    int funcArrSize = 0;
    while ( currNode->callFunc[funcArrSize] != (SV*)NULL ) {
      ++funcArrSize;
    }

    Renew(currNode->callFunc, funcArrSize+2, SV*);
    currNode->callFunc[funcArrSize] = newSVsv(callFunc);
    ++funcArrSize;
    currNode->callFunc[funcArrSize] = (SV*)NULL;
    currNode->nodeCalled = 1;

    
    sar_addNWF_c(firstNWF, currNode);
  }


  //  if (currNode->callFunc == (SV*)NULL) {
    //    currNode->callFunc[0] = newSVsv(callFunc);
    //  }
    //  else {
    //    SvSetSV(currNode->callFunc, callFunc);
    //  }
}


void sar_buildPlusPath_c(char plusChar, sarNode_p currNode, char * regexp, SV * callFunc, sarNodeWithFuncLL_p firstNWF);

void sar_buildNodePath_c(sarNode_p currNode, char * regexp, SV * callFunc, sarNodeWithFuncLL_p firstNWF) {
  char pathChar = regexp[0];
  char nextChar = regexp[1];
  if ( nextChar == '\0' ) {
      sarNode_p newNode = sar_nodeAddCharSorted_c(currNode, pathChar);
      sar_setCallFunc_c(newNode, callFunc, firstNWF);
      return;
  }
  else {
    if ( pathChar == '\\') { 
      *regexp++;
      sar_buildNodePath_c(currNode, regexp, callFunc, firstNWF);
    }
    else if ( nextChar == '?' ) {
      sarNode_p newNode = sar_nodeAddCharSorted_c(currNode, pathChar);
      *regexp++;
      *regexp++;
      sar_buildNodePath_c(currNode, regexp, callFunc, firstNWF);
      sar_buildNodePath_c(newNode, regexp, callFunc, firstNWF);
    }
    else if ( nextChar == '*' ) {

      regexp[1] = '+';
      sar_buildNodePath_c(currNode, regexp, callFunc, firstNWF);
      *regexp++;
      *regexp++;
      sar_buildNodePath_c(currNode, regexp, callFunc, firstNWF);
    }
    else if ( nextChar == '+' ) {
      char charAfterPlus = regexp[2];
      if (pathChar == charAfterPlus) {
	char afterAfterChar = regexp[3];
	if (afterAfterChar == '?' || afterAfterChar == '+' || afterAfterChar == '*') {
	  *regexp++;
	  regexp[0] = pathChar;
	  regexp[1] = pathChar;
	  regexp[2] = '+';
	  sar_buildNodePath_c(currNode, regexp, callFunc, firstNWF);
	}
	else {
	  regexp[1] = pathChar;
	  regexp[2] = '+';
	  sar_buildNodePath_c(currNode, regexp, callFunc, firstNWF);
	}
      }
      else {
	*regexp++;
	sar_buildPlusPath_c(pathChar, currNode, regexp, callFunc, firstNWF);
      }
    }
    else {
      sarNode_p newNode = sar_nodeAddCharSorted_c(currNode, pathChar);
      *regexp++;
      sar_buildNodePath_c(newNode, regexp, callFunc, firstNWF);
    }
  }
}


void sar_buildPath_c(sarNode_p rootNode, char * regexp, SV * callFunc) {
  sarNodeWithFuncLL_p firstNWF = sar_buildNWFNode_c();
  sar_buildNodePath_c(rootNode, regexp, callFunc, firstNWF);
  sar_clearNWFNodes_c(firstNWF);
}




void sar_buildPlusPath_c(char plusChar, sarNode_p currNode, char * regexp, SV * callFunc, sarNodeWithFuncLL_p firstNWF) {
  int currPlusSize = currNode->plusCharSize;

  int newSize = currPlusSize+1;
  Renew(currNode->plusChars, newSize, char);
  Renew(currNode->plusNodes, newSize, sarNode_p);
  currNode->plusCharSize = newSize;

  int charOffset = 0;
  while(charOffset < currPlusSize) {
    if (plusChar < currNode->plusChars[charOffset]) {
      break;
    }
    ++charOffset;
  }

  int cpOffset = currPlusSize;
  while(cpOffset > charOffset) {
    currNode->plusChars[cpOffset] = currNode->plusChars[cpOffset - 1];
    currNode->plusNodes[cpOffset] = currNode->plusNodes[cpOffset - 1];
    --cpOffset;
  }
  currNode->plusChars[cpOffset] = plusChar;

  sarNode_p plusNode = sar_buildNode_c();
  currNode->plusNodes[cpOffset] = plusNode;
  sar_nodeAddCharNode_c(plusNode, plusNode, plusChar);

  *regexp++;
  char nextChar = *regexp;
  if ( nextChar == '\0' ) {
      sar_setCallFunc_c(plusNode, callFunc, firstNWF);
      return;
  }
  else {
    sar_buildNodePath_c(plusNode, regexp, callFunc, firstNWF);
  }
}



void sar_cleanAll_c(sarNode_p node) {
  if (node->nodeCalled > 0) {
    return;
  }
  node->nodeCalled = 1;

  int charNumber = node->charNumber;
  if (charNumber > 0) {
    int i;
    for(i=0; i<charNumber; ++i) {
      sar_cleanAll_c(node->sarNodes[i]);
    }
  }

  int plusNumber = node->plusCharSize;
  if (plusNumber > 0) {
    int i;
    for(i=0; i<plusNumber; ++i) {
      sar_cleanAll_c(node->plusNodes[i]);
    }
  }


  int currCallIdx = 0;
  while ( node->callFunc[currCallIdx] != (SV*)NULL ) {
    SvREFCNT_dec(node->callFunc[currCallIdx]);
    ++currCallIdx;
  }
  Safefree(node->callFunc);

  Safefree(node->sarPathChars);
  Safefree(node->sarNodes);
  Safefree(node->plusChars);
  Safefree(node->plusNodes);
  Safefree(node);
}




