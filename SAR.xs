

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "regex_sar.h"
#include "node_with_func.c"
#include "node_path.c"



MODULE = Regexp::SAR		PACKAGE = Regexp::SAR		


void
buildPath(rootNode, regexp, callFunc)
	sarNode_t * rootNode;
	char * regexp;
	SV * callFunc;
CODE:
	sar_buildPath_c(rootNode, regexp, callFunc);


sarNode_t *
buildRootNode()
CODE:
	RETVAL = sar_buildNode_c();
OUTPUT:
	RETVAL



void
cleanAll(rootNode)
	sarNode_t * rootNode;
CODE:
	sar_cleanAll_c(rootNode);

sarNode_t * 
nodeAddCharSorted(node, newChar);
	sarNode_t * node;
	char newChar;
CODE:
	RETVAL = sar_nodeAddCharSorted_c(node, newChar);
OUTPUT:
	RETVAL


int
searchNode(node, pathChar)
	sarNode_t * node;
	char pathChar;
CODE:
	RETVAL = sar_searchChar_c(node->sarPathChars, node->charNumber, pathChar);
OUTPUT:
	RETVAL


void
lookPath(rootNode, checkStr)
	sarNode_t * rootNode;
	char * checkStr;
CODE:
	sar_lookPath_c(rootNode, checkStr);



int
getCharsNumber(node)
	sarNode_t * node;
CODE:
	RETVAL = node->charNumber;
OUTPUT:
	RETVAL




char *
getCharsAsStr(node)
	sarNode_t * node;
INIT:
	char * retTmp;
	char * sarChars;
	int charsNumber;
	int currOffset;
CODE:
	charsNumber = node->charNumber;
	Newx(RETVAL, charsNumber + 1, char);
	retTmp = RETVAL;
	sarChars = node->sarPathChars;
	for(currOffset = 0; currOffset < charsNumber; ++currOffset) {
		*retTmp++ = *sarChars++;
	}
	* retTmp ='\0';
OUTPUT:
	RETVAL
CLEANUP:
	Safefree(RETVAL);

