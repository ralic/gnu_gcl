
(IN-PACKAGE "COMPILER") 
(PROCLAIM '(FTYPE (FUNCTION (T) FIXNUM) F-TYPE)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T) FIXNUM) PROCLAIMED-ARGD ANALYZE-REGS1
            ANALYZE-REGS)) 
(PROCLAIM
    '(FTYPE (FUNCTION ((VECTOR CHARACTER)) T) DASH-TO-UNDERSCORE)) 
(PROCLAIM '(FTYPE (FUNCTION (T) (VALUES T T)) GET-SYM)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T) UNSIGNED-SHORT) VAR-DYNAMIC VAR-REGISTER)) 
(PROCLAIM '(FTYPE (FUNCTION (FIXNUM FIXNUM) T) MLIN)) 
(PROCLAIM '(FTYPE (FUNCTION (LIST FIXNUM) T) BINARY-NEST-INT)) 
(PROCLAIM '(FTYPE (FUNCTION ((ARRAY T (*))) T) COPY-ARRAY)) 
(PROCLAIM
    '(FTYPE (FUNCTION ((VECTOR CHARACTER) FIXNUM FIXNUM) T)
            DASH-TO-UNDERSCORE-INT)) 
(PROCLAIM '(FTYPE (FUNCTION (T T *) *) T3DEFUN-AUX)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T (ARRAY T (*)) FIXNUM T) FIXNUM) PUSH-ARRAY)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T) *) IS-EQ-TEST-ITEM-LIST C2COMPILER-LET
            C2IF C2LABELS C2FLET WT-INLINE)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T *) T) DO-VECTOR-MAP DO-SEQUENCE-SEARCH
            DO-LIST-SEARCH C2LAMBDA-EXPR INLINE-ARGS
            AREF-PROPAGATOR C2FUNCALL ARRAY-ROW-MAJOR-INDEX-EXPANDER
            FLOOR-PROPAGATOR)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T) *) C2DM C2APPLY-OPTIMIZE C2RETURN-FROM
            C1DM-V C1DM-VL)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T (ARRAY T (*)) SEQIND SEQIND T) FIXNUM)
            BSEARCHLEQ)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T) T) cons-tp-limit ASSIGN-DOWN-VARS TOO-FEW-ARGS
            TOO-MANY-ARGS ASH-PROPAGATOR T3DEFCFUN
            NOTE-BRANCH-ELIMINATION BOOLE3 C2PROGV SET-VAR
            CMP-EXPAND-MACRO AND-FORM-TYPE C2GO C2TAGBODY
            C2MULTIPLE-VALUE-BIND C2MAPCAN C2MAPC C2MAPCAR C2LET* C2LET
            C2CASE CJF CJT C2PRINC C2FUNCALL-SFUN MAKE-INLINE-STRING
            C1MAP-FUNCTIONS CAN-BE-REPLACED* DECLARE-LET-BINDINGS-NEW DECLARE-LET-BINDINGS-NEW1
            C1DM FIX-DOWN-ARGS DECLS-FROM-PROCLS CMP-ASET-INLINE
            GET-INLINE-INFO SUBLIS1-INLINE C1STRUCTURE-REF1
            BIND-ALL-VARS-INT PULL-EVALS-INT CHECK-FORM-TYPE
            WT-IF-PROCLAIMED WT-MAKE-CCLOSURE WT-INLINE-SHORT-FLOAT
            WT-INLINE-LONG-FLOAT WT-INLINE-CHARACTER WT-INLINE-INTEGER
            WT-INLINE-FIXNUM WT-INLINE-COND CHECK-VDECL
            ADD-FUNCTION-DECLARATION ADD-FUNCTION-PROCLAMATION
            ADD-FAST-LINK)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T *) T) POSSIBLE-EQ-LIST-SEARCH NUM-TYPE-REL
            WT-SIMPLE-CALL)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T) T) T3DEFUN-NORMAL T3DEFUN-VARARG
            C1MAKE-VAR C2SWITCH INLINE-TYPE-MATCHES C2STRUCTURE-REF
            C2CALL-UNKNOWN-GLOBAL C2CALL-GLOBAL MY-CALL PUT-PROCLS
            WT-GLOBAL-ENTRY)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T T) T) T3DEFENTRY T3DEFUN-LOCAL-ENTRY
            T3DEFUN T2DEFENTRY T2DEFUN C2STRUCTURE-SET
            BINDING-DECLS-NEW C1APPLY-OPTIMIZE)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T T T) T) BINDING-DECLS-NEW1 T3DEFMACRO T2DEFMACRO DEFSYSFUN)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T T *) T) T3LOCAL-FUN T3LOCAL-DCFUN)) 
(PROCLAIM '(FTYPE (FUNCTION NIL *) WT-FASD-DATA-FILE WT-DATA-FILE)) 
(PROCLAIM
    '(FTYPE (FUNCTION NIL T) VS-PUSH CCB-VS-PUSH CVS-PUSH
            PRINT-CURRENT-FORM BABOON WFS-ERROR INC-INLINE-BLOCKS
            INIT-ENV MULTIPLE-VALUES-P TAIL-RECURSION-POSSIBLE C1T
            C1NIL RESET-TOP WT-DATA-END WT-DATA-BEGIN WT-CVARS
            ADD-LOAD-TIME-SHARP-COMMA WT-NEXT-VAR-ARG WT-FIRST-VAR-ARG
            CLOSE-INLINE-BLOCKS)) 
(PROCLAIM '(FTYPE (FUNCTION (*) *) INLINE-BOOLE3)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T) *) CMP-TOPLEVEL-EVAL CMP-EVAL C2OR C2AND
            C2PROGN C2EXPR T1EVAL-WHEN T1EXPR FUNCTION-STRING SET-LOC
            CMP-MACROEXP-WITH-COMPILER-MACROS EQUALP-IS-EQ-TP
            EQUAL-IS-EQ-TP EQL-IS-EQ-TP PULL-EVALS WT-SHORT-FLOAT-LOC
            WT-LONG-FLOAT-LOC WT-CHARACTER-LOC WT-FIXNUM-LOC WT-LOC
            WT-TO-STRING)) 
(PROCLAIM
    '(FTYPE (FUNCTION (*) T) CS-PUSH FCALLN-INLINE MAKE-VAR
            RANDOM-PROPAGATOR MAKE-TAG LIST*-INLINE MAKE-INFO
            LIST-INLINE CMP-ARRAY-DIMENSION-INLINE-TYPES
            CMP-ASET-INLINE-TYPES CMP-AREF-INLINE-TYPES
            CMP-ARRAY-ELEMENT-TYPE MAKE-FUN MAKE-BLK WT-CLINK
            WT-C-PUSH)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T) T) CMP-NORM-TP SCH-GLOBAL COERCE-TO-INTEGER-TYPE T3CLINES
            VOLATILE IS-LOCAL-VAR-TYPE IS-LOCAL-ARG-TYPE
            IS-GLOBAL-ARG-TYPE LONG-FLOAT-LOC-P COERCE-TO-ONE-VALUE
            COPY-INFO CONSTANT-FOLD-P CONS-TO-LISTA SCH-LOCAL-FUN
            LOCAL-COMPILE-DECLS CONS-TYPE-LENGTH CONS-TO-RIGHT
            VERIFY-DATA-VECTOR PUSH-DATA-INCF C2LOCATION C2VAR
            C2VAR-KIND VAR-P VAR-TYPE VAR-LOC VAR-REF-CCB VAR-REF
            VAR-KIND VAR-NAME C1PSETQ C1PROGV C1SETQ C1ADD-GLOBALS
            C1VREF C1VAR UNDEFINED-VARIABLE CMP-MACROEXPAND-1
            CMP-MACROEXPAND PROMOTED-C-TYPE INTEGER-TYPEP
            RESET-INFO-TYPE TYPE-FILTER LITERALP DEFAULT-INIT T2DECLARE
            T2ORDINARY C2GO-CCB C2GO-CLB C2GO-LOCAL C2TAGBODY-CCB
            C2TAGBODY-CLB C2TAGBODY-BODY C2TAGBODY-LOCAL C2FUNCTION
            C2VALUES WRITE-BLOCK-OPEN C2DM-RESERVE-V C2DM-RESERVE-VL
            C2DOWNWARD-FUNCTION UNWIND-NO-EXIT INLINE-TYPE INFO-P
            INFO-REFERRED-ARRAY INFO-CHANGED-ARRAY INFO-VOLATILE
            INFO-SP-CHANGE INFO-TYPE ARGS-CAUSE-SIDE-EFFECT
            INLINE-BOOLE3-STRING C2GET C2RPLACD C2RPLACA
            ARRAY-ELEMENT-SUBTYPE WRAP-LITERALS
            SYSTEM:UNDEF-COMPILER-MACRO C2EXPR* PROCLAMATION PROCLAIM
            INLINE-POSSIBLE C2FUNCALL-AUX C2BIND T1DEFLA T1DEFENTRY
            T1DEFCFUN T1CLINES T1DEFINE-STRUCTURE T1ORDINARY T1DEFMACRO
            REP-TYPE VARARG-P T1DEFUN T1PROGN SET-UP-VAR-CVS REGISTER
            PARSE-CVSPECS MAXARGS MAKE-SETF-FUNCTION-PROXY-SYMBOL
            FUNCTION-SYMBOL TAG-P TAG-SWITCH TAG-VAR TAG-UNWIND-EXIT
            TAG-LABEL TAG-REF-CCB TAG-REF-CLB TAG-REF TAG-NAME C1SWITCH
            C1GO C1TAGBODY C1FUNCTION C1COMPILER-LET C1THE C1DECLARE
            C1EVAL-WHEN C1QUOTE C1MULTIPLE-VALUE-BIND
            C1MULTIPLE-VALUE-SETQ C1VALUES C1MULTIPLE-VALUE-PROG1
            C1MULTIPLE-VALUE-CALL C1MAP C1MAP-INTO C1MAPCON C1MAPCAN
            C1MAPL C1MAPC C1MAPLIST C1MAPCAR SET-TOP SET-RETURN
            FIXNUM-LOC-P TYPE-OF-FORM T-TO-NIL PUSH-MACROLETS NIL-TO-T
            C1STACK-LET C1LET* C1LET NEED-TO-SET-VS-POINTERS
            C1DM-BAD-KEY C1DOWNWARD-FUNCTION VAR-ARRAY-TYPE VAR-REP-LOC
            MAKE-LIST-INLINE C-CAST C1ECASE C1OR C1AND FMLA-EVAL-CONST
            C1FMLA-CONSTANT C1IF C1LIST-NTH C1LIST C1RPLACA-NTHCDR
            C1NTHCDR C1NTHCDR-CONDITION C1NTH C1NTH-CONDITION
            GET-INCLUDED RESULT-TYPE C1GET C1LENGTH C1ASH
            C1ASH-CONDITION C1BOOLE3 C1BOOLE-CONDITION C1MAKE-ARRAY
            C1CMP-ARRAY-ELEMENT-TYPE CMP-ARRAY-ELEMENT-SUBTYPE
            TEST-TO-TF C1IS-EQ-TEST-ITEM-LIST NUM-TYPE-BOUNDS
            EQUALP-IS-EQ EQUAL-IS-EQ EQL-IS-EQ C1RPLACD C1RPLACA
            C1FUNCALL C1APPLY C1TERPRI C1PRINC C1LOCAL-CLOSURE
            C1LOCAL-FUN FUN-P FUN-INFO FUN-LEVEL FUN-CFUN FUN-REF-CCB
            FUN-REF FUN-NAME C1MACROLET C1LABELS C1FLET NAME-SD1
            NAME-TO-SD C1STRUCTURE-SET C1STRUCTURE-REF C1PROGN
            REPLACE-CONSTANT BIND-ALL-VARS SEQIND-WRAP NEEDS-PRE-EVAL
            FIX-OPT C1DEFINE-STRUCTURE C1LOAD-TIME-VALUE C1SHARP-COMMA
            C1EXPR GET-LOCAL-RETURN-TYPE GET-LOCAL-ARG-TYPES
            GET-RETURN-TYPE GET-ARG-TYPES SET-PUSH-CATCH-FRAME
            SAVE-FUNOB SAVE-AVMA FUNCTION-RETURN-TYPE
            PUSH-ARGS-LISPCALL PUSH-ARGS FUNCTION-ARG-TYPES C1THROW
            C1UNWIND-PROTECT C1CATCH DECLARATION-TYPE C1FUNOB
            CMP-MACRO-FUNCTION C1RETURN-FROM C1BLOCK AET-C-TYPE
            WT-DATA-PACKAGE-OPERATION WT-DATA1 WT-H1 WT1 WT-LIST
            WT-CCB-VS WT-VS* WT-VS CLINK WT-VAR-DECL WT-DOWN
            CHECK-DOWNWARD CHECK-VREF CTOP-WRITE ADD-ADDRESS
            WT-SWITCH-CASE ADD-LOOP-REGISTERS ADD-REG1
            WT-SYMBOL-FUNCTION WT-INTEGER-LOC WT-VV WT-CADR WT-CDR
            WT-CAR WT-VS-BASE SHORT-FLOAT-LOC-P CHARACTER-LOC-P
            WT-DOWNWARD-CLOSURE-MACRO THE-PARAMETER WT-FUNCALL-C
            WT-FUNCTION-LINK FLAGS-POS ADD-CONSTANT ADD-OBJECT
            ADD-SYMBOL BLK-P BLK-VAR BLK-VALUE-TO-GO BLK-EXIT
            BLK-REF-CCB BLK-REF-CLB BLK-REF BLK-NAME)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T) *) C2DECL-BODY C2RETURN-LOCAL C2BLOCK-LOCAL
            C2BLOCK LIST-TP-TEST C1SYMBOL-FUN C1BODY WT-INLINE-LOC)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T *) T) OBJECT-TYPE SUPER-RANGE CMPNOTE CMPWARN CMPERR INTEGER-NORM-FORM
            INIT-NAME UNWIND-EXIT C1LAMBDA-EXPR C1CASE
            FAST-LINK-PROCLAIMED-TYPE-P WT-COMMENT ADD-INIT WT-CVAR)) 
(PROCLAIM '(FTYPE (FUNCTION (T FIXNUM T) T) C-FUNCTION-NAME)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T) T) set-var-init-type do-setq-tp CMP-NTHCDR COMPILER-CLEAR-COMPILER-PROPERTIES
            COMPILER-DEF-HOOK CONS-INLINE IS-REP-REFERRED COERCE-LOC
            CONVERT-CASE-TO-SWITCH CO1SUBLIS CO1SPECIAL-FIX-DECL
            CO1CONSTANT-FOLD CO1VECTOR-PUSH CO1WRITE-CHAR CO1WRITE-BYTE
            CO1READ-CHAR CO1READ-BYTE CO1CONS CO1SCHAR CO1TYPEP CO1EQL
            CO1LDB DO-PREDICATE DO-NUM-RELATIONS LOGICAL-OUTER-NEST
            LOGICAL-BINARY-NEST DO-EQ-ET-AL CO1STRUCTURE-PREDICATE
            COERCE-LOC-STRUCTURE-REF ASET-EXPANDER SET-VS C2PSETQ
            C2SETQ C1SETQ1 INTEGER-TYPE-AND TYPE>= TYPE-AND TYPE-AND-INT TYPE<=
            T2SHARP-COMMA C2MULTIPLE-VALUE-SETQ C2MULTIPLE-VALUE-PROG1
            C2MULTIPLE-VALUE-CALL C2STACK-LET C2DM-BIND-INIT
            C2DM-BIND-LOC C2DM-BIND-VL C2LAMBDA-EXPR-WITH-KEY
            C2LAMBDA-EXPR-WITHOUT-KEY UNWIND-BDS
            ARGS-INFO-REFERRED-VARS ARGS-INFO-CHANGED-VARS
            C2LIST-NTH-IMMEDIATE CFAST-WRITE C2APPLY C2CALL-LOCAL
            IF-PROTECT-FUN-INF INCR-TO-PLUS INVERT-BINARY-NEST
            C2EXPR-TOP* C2EXPR-TOP ARRAY-DIMENSION-EXPANDER
            PROCLAIM-VAR C2THROW C2UNWIND-PROTECT C2CATCH INLINE-PROC
            C2CALL-LAMBDA C2RETURN-CCB C2RETURN-CLB C2BLOCK-CCB
            C2BLOCK-CLB C2BIND-INIT C2BIND-LOC AREF-EXPANDER SET-DBIND
            MAYBE-EVAL CMPFIX-ARGS JUMPS-TO-P MULTIPLE-VALUE-CHECK
            DECLARE-MULTIPLE-VALUE-BINDINGS PUSH-CHANGED-VARS
            VAR-IS-CHANGED RECURSIVELY-CMP-MACROEXPAND CAN-BE-REPLACED
            CMP-ARRAY-DIMENSION-INLINE NEED-TO-PROTECT GET-INLINE-LOC
            CMP-AREF-INLINE SET-JUMP-FALSE SET-JUMP-TRUE C1FMLA
            FAST-READ C1CONSTANT-VALUE C1ARGS C1PROGN* C1LAMBDA-FUN
            RESULT-TYPE-FROM-ARGS DECR-TO-MINUS BINARY-NEST C1EXPR*
            BIND-BEFORE-CONS SET-BDS-BIND C1DECL-BODY WT-VAR
            WT-REQUIREDS WT-V*-MACROS ADD-DEBUG-INFO SYSTEM::ADD-DEBUG
            WT-SHORT-FLOAT-VALUE WT-LONG-FLOAT-VALUE WT-CHARACTER-VALUE
            WT-FIXNUM-VALUE WT-MAKE-DCLOSURE ADD-INFO STRUCT-TYPE-OPT
            SHIFT<< SHIFT>> CHECK-FNAME-ARGS)) 