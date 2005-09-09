
;; Modified data base including return values types
;; and making the arglists correct if they have optional args.
;;

(in-package 'compiler)

(DEFSYSFUN 'GENSYM "Lgensym" '(*) 'T NIL NIL) 
(DEFSYSFUN 'SUBSEQ "Lsubseq" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'MINUSP "Lminusp" '(T) 'T NIL T) 
(DEFSYSFUN 'INTEGER-DECODE-FLOAT "Linteger_decode_float" '(T)
    '(VALUES T T T) NIL NIL) 
(DEFSYSFUN '- "Lminus" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'INT-CHAR "Lint_char" '(T) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'CHAR-INT "Lchar_int" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN '/= "Lall_different" '(T *) 'T NIL T) 
(DEFSYSFUN 'COPY-SEQ "Lcopy_seq" '(T) 'T NIL NIL) 
(DEFSYSFUN 'KEYWORDP "Lkeywordp" '(T) 'T NIL T) 
(DEFSYSFUN 'NAME-CHAR "Lname_char" '(T) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'CHAR-NAME "Lchar_name" '(T) 'T NIL NIL) 
(DEFSYSFUN 'RASSOC-IF "Lrassoc_if" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'MAKE-LIST "Lmake_list" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'HOST-NAMESTRING "Lhost_namestring" '(T) 'STRING NIL NIL) 
(DEFSYSFUN 'MAKE-ECHO-STREAM "Lmake_echo_stream" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'NTH "Lnth" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'SIN "Lsin" '(T) 'T NIL NIL) 
(DEFSYSFUN 'NUMERATOR "Lnumerator" '(T) 'T NIL NIL) 
(DEFSYSFUN 'ARRAY-RANK "Larray_rank" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'CAAR "Lcaar" '(T) 'T NIL NIL) 
;#-clcs (DEFSYSFUN 'LOAD "Lload" '(T *) 'T NIL NIL) 
;#-clcs (DEFSYSFUN 'OPEN "Lopen" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'BOTH-CASE-P "Lboth_case_p" '(T) 'T NIL T) 
(DEFSYSFUN 'NULL "Lnull" '(T) 'T NIL T) 
(DEFSYSFUN 'RENAME-FILE "Lrename_file" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'FILE-AUTHOR "Lfile_author" '(T) 'T NIL NIL) 
(DEFSYSFUN 'STRING-CAPITALIZE "Lstring_capitalize" '(T *) 'STRING NIL
    NIL) 
(DEFSYSFUN 'MACROEXPAND "Lmacroexpand" '(T *) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'NCONC "Lnconc" '(*) 'T NIL NIL) 
(DEFSYSFUN 'BOOLE "Lboole" '(T T T) 'T NIL NIL) 
(DEFSYSFUN 'TAILP "Ltailp" '(T T) 'T NIL T) 
(DEFSYSFUN 'CONSP "Lconsp" '(T) 'T NIL T) 
(DEFSYSFUN 'LISTP "Llistp" '(T) 'T NIL T) 
(DEFSYSFUN 'MAPCAN "Lmapcan" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'LENGTH "Llength" '(T) 'FIXNUM T NIL) 
(DEFSYSFUN 'RASSOC "Lrassoc" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'PPRINT "Lpprint" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'PATHNAME-HOST "Lpathname_host" '(T) 'T NIL NIL) 
(DEFSYSFUN 'NSUBST-IF-NOT "Lnsubst_if_not" '(T T T *) 'T NIL NIL) 
(DEFSYSFUN 'FILE-POSITION "Lfile_position" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'STRING< "Lstring_l" '(T T *) 'T NIL T) 
(DEFSYSFUN 'REVERSE "Lreverse" '(T) 'T NIL NIL) 
(DEFSYSFUN 'STREAMP "Lstreamp" '(T) 'T NIL T) 
(DEFSYSFUN 'SYSTEM::PUTPROP "siLputprop" '(T T T) 'T NIL NIL) 
(DEFSYSFUN 'REMPROP "Lremprop" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'SYMBOL-PACKAGE "Lsymbol_package" '(T) 'T NIL NIL) 
(DEFSYSFUN 'NSTRING-UPCASE "Lnstring_upcase" '(T *) 'STRING NIL NIL) 
(DEFSYSFUN 'STRING>= "Lstring_ge" '(T T *) 'T NIL T) 
(DEFSYSFUN 'REALPART "Lrealpart" '(T) 'T NIL NIL) 
;;broken on suns..
;(DEFSYSFUN 'USER-HOMEDIR-PATHNAME "Luser_homedir_pathname" '(*) 'T NIL
;    NIL) 
(DEFSYSFUN 'NBUTLAST "Lnbutlast" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'ARRAY-DIMENSION "Larray_dimension" '(T T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'CDR "Lcdr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'EQL "Leql" '(T T) 'T NIL T) 
(DEFSYSFUN 'LOG "Llog" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'DIRECTORY "Ldirectory" '(T) 'T NIL NIL) 
(DEFSYSFUN 'STRING-NOT-EQUAL "Lstring_not_equal" '(T T *) 'T NIL T) 
(DEFSYSFUN 'SHADOWING-IMPORT "Lshadowing_import" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'MAPC "Lmapc" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'MAPL "Lmapl" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'MAKUNBOUND "Lmakunbound" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CONS "Lcons" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'LIST "Llist" '(*) 'T NIL NIL) 
(DEFSYSFUN 'USE-PACKAGE "Luse_package" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'FILE-LENGTH "Lfile_length" '(T) 'T NIL NIL) 
(DEFSYSFUN 'MAKE-SYMBOL "Lmake_symbol" '(T) 'T NIL NIL) 
(DEFSYSFUN 'STRING-RIGHT-TRIM "Lstring_right_trim" '(T T) 'STRING NIL
    NIL) 
(DEFSYSFUN 'ENOUGH-NAMESTRING "Lenough_namestring" '(T *) 'STRING NIL
    NIL) 
(DEFSYSFUN 'PRINT "Lprint" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'CDDAAR "Lcddaar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CDADAR "Lcdadar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CDAADR "Lcdaadr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CADDAR "Lcaddar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CADADR "Lcadadr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CAADDR "Lcaaddr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'SET-MACRO-CHARACTER "Lset_macro_character" '(T T *) 'T NIL
    NIL) 
(DEFSYSFUN 'FORCE-OUTPUT "Lforce_output" '(*) 'T NIL NIL) 
(DEFSYSFUN 'NTHCDR "Lnthcdr" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'LOGIOR "Llogior" '(*) 'T NIL NIL) 
(DEFSYSFUN 'CHAR-DOWNCASE "Lchar_downcase" '(T) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'STRING-CHAR-P "Lstring_char_p" '(T) 'T NIL T) 
(DEFSYSFUN 'STREAM-ELEMENT-TYPE "Lstream_element_type" '(T) 'T NIL NIL) 
(DEFSYSFUN 'PACKAGE-USED-BY-LIST "Lpackage_used_by_list" '(T) 'T NIL
    NIL) 
(DEFSYSFUN '/ "Ldivide" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'MAPHASH "Lmaphash" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'STRING= "Lstring_eq" '(T T *) 'T NIL T) 
(DEFSYSFUN 'PAIRLIS "Lpairlis" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'SYMBOLP "Lsymbolp" '(T) 'T NIL T) 
(DEFSYSFUN 'CHAR-NOT-LESSP "Lchar_not_lessp" '(T *) 'T NIL T) 
(DEFSYSFUN '1+ "Lone_plus" '(T) 'T NIL NIL) 
(DEFSYSFUN 'BY "Lby" 'NIL 'T NIL NIL) 
(DEFSYSFUN 'NSUBST-IF "Lnsubst_if" '(T T T *) 'T NIL NIL) 
(DEFSYSFUN 'COPY-LIST "Lcopy_list" '(T) 'T NIL NIL) 
(DEFSYSFUN 'TAN "Ltan" '(T) 'T NIL NIL) 
(DEFSYSFUN 'SET "Lset" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'FUNCTIONP "Lfunctionp" '(T) 'T NIL T) 
(DEFSYSFUN 'WRITE-BYTE "Lwrite_byte" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'LAST "Llast" '(T) 'T NIL NIL) 
(DEFSYSFUN 'MAKE-STRING "Lmake_string" '(T *) 'STRING NIL NIL) 
(DEFSYSFUN 'CAAAR "Lcaaar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'LIST-LENGTH "Llist_length" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CDDDR "Lcdddr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'PRIN1 "Lprin1" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'PRINC "Lprinc" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'LOWER-CASE-P "Llower_case_p" '(T) 'T NIL T) 
(DEFSYSFUN 'CHAR<= "Lchar_le" '(T *) 'T NIL T) 
(DEFSYSFUN 'STRING-EQUAL "Lstring_equal" '(T T *) 'T NIL T) 
(DEFSYSFUN 'CLEAR-OUTPUT "Lclear_output" '(*) 'T NIL NIL) 
#-clcs (DEFSYSFUN 'CERROR "Lcerror" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'TERPRI "Lterpri" '(*) 'T NIL NIL) 
(DEFSYSFUN 'NSUBST "Lnsubst" '(T T T *) 'T NIL NIL) 
(DEFSYSFUN 'UNUSE-PACKAGE "Lunuse_package" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'STRING-NOT-GREATERP "Lstring_not_greaterp" '(T T *) 'T NIL
    T) 
(DEFSYSFUN 'STRING> "Lstring_g" '(T T *) 'T NIL T) 
(DEFSYSFUN 'FINISH-OUTPUT "Lfinish_output" '(*) 'T NIL NIL) 
(DEFSYSFUN 'SPECIAL-FORM-P "Lspecial_form_p" '(T) 'T NIL T) 
(DEFSYSFUN 'STRINGP "Lstringp" '(T) 'T NIL T) 
(DEFSYSFUN 'GET-INTERNAL-RUN-TIME "Lget_internal_run_time" 'NIL 'T NIL
    NIL) 
(DEFSYSFUN 'TRUNCATE "Ltruncate" '(T *) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'CODE-CHAR "Lcode_char" '(T *) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'CHAR-CODE "Lchar_code" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'SIMPLE-STRING-P "Lsimple_string_p" '(T) 'T NIL T) 
(DEFSYSFUN 'REVAPPEND "Lrevappend" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'HASH-TABLE-COUNT "Lhash_table_count" '(T) 'T NIL NIL) 
(DEFSYSFUN 'PACKAGE-USE-LIST "Lpackage_use_list" '(T) 'T NIL NIL) 
(DEFSYSFUN 'REM "Lrem" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'MIN "Lmin" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'APPLYHOOK "Lapplyhook" '(T T T T *) 'T NIL NIL) 
(DEFSYSFUN 'EXP "Lexp" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CHAR-LESSP "Lchar_lessp" '(T *) 'T NIL T) 
(DEFSYSFUN 'CDAR "Lcdar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CADR "Lcadr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'LIST-ALL-PACKAGES "Llist_all_packages" 'NIL 'T NIL NIL) 
(DEFSYSFUN 'REST "Lcdr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'COPY-SYMBOL "Lcopy_symbol" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'ACONS "Lacons" '(T T T) 'T NIL NIL) 
(DEFSYSFUN 'ADJUSTABLE-ARRAY-P "Ladjustable_array_p" '(T) 'T NIL T) 
(DEFSYSFUN 'SVREF "Lsvref" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'APPLY "Lapply" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'DECODE-FLOAT "Ldecode_float" '(T) '(VALUES T T T) NIL NIL) 
(DEFSYSFUN 'SUBST-IF-NOT "Lsubst_if_not" '(T T T *) 'T NIL NIL) 
(DEFSYSFUN 'RPLACA "Lrplaca" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'SYMBOL-PLIST "Lsymbol_plist" '(T) 'T NIL NIL) 
(DEFSYSFUN 'WRITE-STRING "Lwrite_string" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'LOGEQV "Llogeqv" '(*) 'T NIL NIL) 
(DEFSYSFUN 'STRING "Lstring" '(T) 'STRING NIL NIL) 
(DEFSYSFUN 'STRING-UPCASE "Lstring_upcase" '(T *) 'STRING NIL NIL) 
(DEFSYSFUN 'CEILING "Lceiling" '(T *) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'GETHASH "Lgethash" '(T T *) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'TYPE-OF "Ltype_of" '(T) 'T NIL NIL) 
(DEFSYSFUN 'BUTLAST "Lbutlast" '(T *) 'T NIL NIL) 
(DEFSYSFUN '1- "Lone_minus" '(T) 'T NIL NIL) 
(DEFSYSFUN 'MAKE-HASH-TABLE "Lmake_hash_table" '(*) 'T NIL NIL) 
(DEFSYSFUN 'STRING/= "Lstring_neq" '(T T *) 'T NIL T) 
(DEFSYSFUN '<= "Lmonotonically_nondecreasing" '(T *) 'T NIL T) 
(DEFSYSFUN 'MAKE-BROADCAST-STREAM "Lmake_broadcast_stream" '(*) 'T NIL
    NIL) 
(DEFSYSFUN 'IMAGPART "Limagpart" '(T) 'T NIL NIL) 
(DEFSYSFUN 'INTEGERP "Lintegerp" '(T) 'T NIL T) 
(DEFSYSFUN 'READ-CHAR "Lread_char" '(*) 'T NIL NIL) 
(DEFSYSFUN 'PEEK-CHAR "Lpeek_char" '(*) 'T NIL NIL) 
(DEFSYSFUN 'CHAR-FONT "Lchar_font" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'STRING-GREATERP "Lstring_greaterp" '(T T *) 'T NIL T) 
(DEFSYSFUN 'OUTPUT-STREAM-P "Loutput_stream_p" '(T) 'T NIL T) 
(DEFSYSFUN 'ASH "Lash" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'LCM "Llcm" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'ELT "Lelt" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'COS "Lcos" '(T) 'T NIL NIL) 
(DEFSYSFUN 'NSTRING-DOWNCASE "Lnstring_downcase" '(T *) 'STRING NIL
    NIL) 
(DEFSYSFUN 'COPY-ALIST "Lcopy_alist" '(T) 'T NIL NIL) 
(DEFSYSFUN 'ATAN "Latan" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'DELETE-FILE "Ldelete_file" '(T) 'T NIL NIL) 
(DEFSYSFUN 'FLOAT-RADIX "Lfloat_radix" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'SYMBOL-NAME "Lsymbol_name" '(T) 'STRING NIL NIL) 
(DEFSYSFUN 'CLEAR-INPUT "Lclear_input" '(*) 'T NIL NIL) 
(DEFSYSFUN 'FIND-SYMBOL "Lfind_symbol" '(T *) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'CHAR< "Lchar_l" '(T *) 'T NIL T) 
(DEFSYSFUN 'HASH-TABLE-P "Lhash_table_p" '(T) 'T NIL T) 
(DEFSYSFUN 'EVENP "Levenp" '(T) 'T NIL T) 
(DEFSYSFUN 'SYSTEM::CMOD "siLcmod" '(T) 'T NIL T) 
(DEFSYSFUN 'SYSTEM::CPLUS "siLcplus" '(T T) 'T NIL T) 
(DEFSYSFUN 'SYSTEM::CTIMES "siLctimes" '(T T) 'T NIL T) 
(DEFSYSFUN 'SYSTEM::CDIFFERENCE "siLcdifference" '(T T) 'T NIL T) 
(DEFSYSFUN 'ZEROP "Lzerop" '(T) 'T NIL T) 
(DEFSYSFUN 'CAAAAR "Lcaaaar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CHAR>= "Lchar_ge" '(T *) 'T NIL T) 
(DEFSYSFUN 'CDDDAR "Lcdddar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CDDADR "Lcddadr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CDADDR "Lcdaddr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CADDDR "Lcadddr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'FILL-POINTER "Lfill_pointer" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'MAPCAR "Lmapcar" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'FLOATP "Lfloatp" '(T) 'T NIL T) 
(DEFSYSFUN 'SHADOW "Lshadow" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'MACROEXPAND-1 "Lmacroexpand_1" '(T *) '(VALUES T T) NIL
    NIL) 
(DEFSYSFUN 'SXHASH "Lsxhash" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'LISTEN "Llisten" '(*) 'T NIL NIL) 
(DEFSYSFUN 'ARRAYP "Larrayp" '(T) 'T NIL T) 
(DEFSYSFUN 'MAKE-PATHNAME "Lmake_pathname" '(*) 'T NIL NIL) 
(DEFSYSFUN 'PATHNAME-TYPE "Lpathname_type" '(T) 'T NIL NIL) 
(DEFSYSFUN 'FUNCALL "Lfuncall" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'CLRHASH "Lclrhash" '(T) 'T NIL NIL) 
(DEFSYSFUN 'GRAPHIC-CHAR-P "Lgraphic_char_p" '(T) 'T NIL T) 
(DEFSYSFUN 'FBOUNDP "Lfboundp" '(T) 'T NIL T) 
(DEFSYSFUN 'NSUBLIS "Lnsublis" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'CHAR-NOT-EQUAL "Lchar_not_equal" '(T *) 'T NIL T) 
(DEFSYSFUN 'MACRO-FUNCTION "Lmacro_function" '(T) 'T NIL NIL) 
(DEFSYSFUN 'SUBST-IF "Lsubst_if" '(T T T *) 'T NIL NIL) 
(DEFSYSFUN 'COMPLEXP "Lcomplexp" '(T) 'T NIL T) 
(DEFSYSFUN 'READ-LINE "Lread_line" '(*) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'PATHNAMEP "Lpathnamep" '(T) 'T NIL T) 
(DEFSYSFUN 'MAX "Lmax" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'IN-PACKAGE "Lin_package" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'READTABLEP "Lreadtablep" '(T) 'T NIL T) 
(DEFSYSFUN 'FLOAT-SIGN "Lfloat_sign" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'CHARACTERP "Lcharacterp" '(T) 'T NIL T) 
(DEFSYSFUN 'READ "Lread" '(*) 'T NIL NIL) 
(DEFSYSFUN 'NAMESTRING "Lnamestring" '(T) 'T NIL NIL) 
(DEFSYSFUN 'UNREAD-CHAR "Lunread_char" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'CDAAR "Lcdaar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CADAR "Lcadar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CAADR "Lcaadr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CHAR= "Lchar_eq" '(T *) 'T NIL T) 
(DEFSYSFUN 'ALPHA-CHAR-P "Lalpha_char_p" '(T) 'T NIL T) 
(DEFSYSFUN 'STRING-TRIM "Lstring_trim" '(T T) 'STRING NIL NIL) 
(DEFSYSFUN 'MAKE-PACKAGE "Lmake_package" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'CLOSE "Lclose" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'DENOMINATOR "Ldenominator" '(T) 'T NIL NIL) 
(DEFSYSFUN 'FLOAT "Lfloat" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'FIRST "Lcar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'ROUND "Lround" '(T *) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'SUBST "Lsubst" '(T T T *) 'T NIL NIL) 
(DEFSYSFUN 'UPPER-CASE-P "Lupper_case_p" '(T) 'T NIL T) 
(DEFSYSFUN 'ARRAY-ELEMENT-TYPE "Larray_element_type" '(T) 'T NIL NIL) 
(DEFSYSFUN 'ADJOIN "Ladjoin" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'LOGAND "Llogand" '(*) 'T NIL NIL) 
(DEFSYSFUN 'MAPCON "Lmapcon" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'INTERN "Lintern" '(T *) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'VALUES "Lvalues" '(*) '* NIL NIL) 
(DEFSYSFUN 'EXPORT "Lexport" '(T *) 'T NIL NIL) 
(DEFSYSFUN '* "Ltimes" '(*) 'T NIL NIL) 
(DEFSYSFUN '< "Lmonotonically_increasing" '(T *) 'T NIL T) 
(DEFSYSFUN 'COMPLEX "Lcomplex" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'SET-SYNTAX-FROM-CHAR "Lset_syntax_from_char" '(T T *) 'T
    NIL NIL) 
(DEFSYSFUN 'CHAR-BIT "Lchar_bit" '(T T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'INTEGER-LENGTH "Linteger_length" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'PACKAGEP "Lpackagep" '(T) 'T NIL T) 
(DEFSYSFUN 'INPUT-STREAM-P "Linput_stream_p" '(T) 'T NIL T) 
(DEFSYSFUN '>= "Lmonotonically_nonincreasing" '(T *) 'T NIL T) 
(DEFSYSFUN 'PATHNAME "Lpathname" '(T) 'T NIL NIL) 
(DEFSYSFUN 'EQ "Leq" '(T T) 'T NIL T) 
(DEFSYSFUN 'MAKE-CHAR "Lmake_char" '(T *) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'FILE-NAMESTRING "Lfile_namestring" '(T) 'STRING NIL NIL) 
(DEFSYSFUN 'CHARACTER "Lcharacter" '(T) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'SYMBOL-FUNCTION "Lsymbol_function" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CONSTANTP "Lconstantp" '(T) 'T NIL T) 
(DEFSYSFUN 'CHAR-EQUAL "Lchar_equal" '(T *) 'T NIL T) 
(DEFSYSFUN 'TREE-EQUAL "Ltree_equal" '(T T *) 'T NIL T) 
(DEFSYSFUN 'CDDR "Lcddr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'GETF "Lgetf" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'SAVE "Lsave" '(T) 'T NIL NIL) 
(DEFSYSFUN 'MAKE-RANDOM-STATE "Lmake_random_state" '(*) 'T NIL NIL) 
(DEFSYSFUN 'CHAR-NOT-GREATERP "Lchar_not_greaterp" '(T *) 'T NIL T) 
(DEFSYSFUN 'EXPT "Lexpt" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'SQRT "Lsqrt" '(T) 'T NIL NIL) 
(DEFSYSFUN 'SCALE-FLOAT "Lscale_float" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'CHAR> "Lchar_g" '(T *) 'T NIL T) 
(DEFSYSFUN 'LDIFF "Lldiff" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'ASSOC-IF-NOT "Lassoc_if_not" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'BIT-VECTOR-P "Lbit_vector_p" '(T) 'T NIL T) 
(DEFSYSFUN 'NSTRING-CAPITALIZE "Lnstring_capitalize" '(T *) 'STRING NIL
    NIL) 
(DEFSYSFUN 'SYMBOL-VALUE "Lsymbol_value" '(T) 'T NIL NIL) 
(DEFSYSFUN 'RPLACD "Lrplacd" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'BOUNDP "Lboundp" '(T) 'T NIL T) 
(DEFSYSFUN 'EQUALP "Lequalp" '(T T) 'T NIL T) 
(DEFSYSFUN 'SIMPLE-BIT-VECTOR-P "Lsimple_bit_vector_p" '(T) 'T NIL T) 
(DEFSYSFUN 'MEMBER-IF-NOT "Lmember_if_not" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'MAKE-TWO-WAY-STREAM "Lmake_two_way_stream" '(T T) 'T NIL
    NIL) 
(DEFSYSFUN 'PARSE-INTEGER "Lparse_integer" '(T *) 'T NIL NIL) 
(DEFSYSFUN '+ "Lplus" '(*) 'T NIL NIL) 
(DEFSYSFUN '= "Lall_the_same" '(T *) 'T NIL T) 
(DEFSYSFUN 'GENTEMP "Lgentemp" '(*) 'T NIL NIL) 
(DEFSYSFUN 'RENAME-PACKAGE "Lrename_package" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'COMMONP "Lcommonp" '(T) 'T NIL T) 
(DEFSYSFUN 'NUMBERP "Lnumberp" '(T) 'T NIL T) 
(DEFSYSFUN 'COPY-READTABLE "Lcopy_readtable" '(*) 'T NIL NIL) 
(DEFSYSFUN 'RANDOM-STATE-P "Lrandom_state_p" '(T) 'T NIL T) 
(DEFSYSFUN 'DIRECTORY-NAMESTRING "Ldirectory_namestring" '(T) 'STRING
    NIL NIL) 
(DEFSYSFUN 'STANDARD-CHAR-P "Lstandard_char_p" '(T) 'T NIL T) 
(DEFSYSFUN 'TRUENAME "Ltruename" '(T) 'T NIL NIL) 
(DEFSYSFUN 'IDENTITY "Lidentity" '(T) 'T NIL NIL) 
(DEFSYSFUN 'NREVERSE "Lnreverse" '(T) 'T NIL NIL) 
(DEFSYSFUN 'PATHNAME-DEVICE "Lpathname_device" '(T) 'T NIL NIL) 
(DEFSYSFUN 'UNINTERN "Lunintern" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'UNEXPORT "Lunexport" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'FLOAT-PRECISION "Lfloat_precision" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'STRING-DOWNCASE "Lstring_downcase" '(T *) 'STRING NIL NIL) 
(DEFSYSFUN 'CAR "Lcar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CONJUGATE "Lconjugate" '(T) 'T NIL NIL) 
(DEFSYSFUN 'NOT "Lnull" '(T) 'T NIL T) 
(DEFSYSFUN 'READ-CHAR-NO-HANG "Lread_char_no_hang" '(*) 'T NIL NIL) 
(DEFSYSFUN 'FRESH-LINE "Lfresh_line" '(*) 'T NIL NIL) 
(DEFSYSFUN 'WRITE-CHAR "Lwrite_char" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'PARSE-NAMESTRING "Lparse_namestring" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'STRING-NOT-LESSP "Lstring_not_lessp" '(T T *) 'T NIL T) 
(DEFSYSFUN 'CHAR "Lchar" '(T T) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'AREF "Laref" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'PACKAGE-NICKNAMES "Lpackage_nicknames" '(T) 'T NIL NIL) 
(DEFSYSFUN 'ENDP "Lendp" '(T) 'T NIL T) 
(DEFSYSFUN 'ODDP "Loddp" '(T) 'T NIL T) 
(DEFSYSFUN 'CHAR-UPCASE "Lchar_upcase" '(T) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'LIST* "LlistA" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'VALUES-LIST "Lvalues_list" '(T) '* NIL NIL) 
(DEFSYSFUN 'EQUAL "Lequal" '(T T) 'T NIL T) 
(DEFSYSFUN 'DIGIT-CHAR-P "Ldigit_char_p" '(T *) 'T NIL NIL) 
#-clcs (DEFSYSFUN 'ERROR "Lerror" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'CHAR/= "Lchar_neq" '(T *) 'T NIL T) 
(DEFSYSFUN 'PATHNAME-DIRECTORY "Lpathname_directory" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CDAAAR "Lcdaaar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CADAAR "Lcadaar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CAADAR "Lcaadar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CAAADR "Lcaaadr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CDDDDR "Lcddddr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'GET-MACRO-CHARACTER "Lget_macro_character" '(T *) 'T NIL
    NIL) 
(DEFSYSFUN 'FORMAT "Lformat" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'COMPILED-FUNCTION-P "Lcompiled_function_p" '(T) 'T NIL T) 
(DEFSYSFUN 'SUBLIS "Lsublis" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'PATHNAME-NAME "Lpathname_name" '(T) 'T NIL NIL) 
(DEFSYSFUN 'IMPORT "Limport" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'LOGXOR "Llogxor" '(*) 'T NIL NIL) 
(DEFSYSFUN 'RASSOC-IF-NOT "Lrassoc_if_not" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'CHAR-GREATERP "Lchar_greaterp" '(T *) 'T NIL T) 
(DEFSYSFUN 'MAKE-SYNONYM-STREAM "Lmake_synonym_stream" '(T) 'T NIL NIL) 
(DEFSYSFUN 'ALPHANUMERICP "Lalphanumericp" '(T) 'T NIL T) 
(DEFSYSFUN 'REMHASH "Lremhash" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'NRECONC "Lreconc" '(T T) 'T NIL NIL) 
(DEFSYSFUN '> "Lmonotonically_decreasing" '(T *) 'T NIL T) 
(DEFSYSFUN 'LOGBITP "Llogbitp" '(T T) 'T NIL T) 
(DEFSYSFUN 'MAPLIST "Lmaplist" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'VECTORP "Lvectorp" '(T) 'T NIL T) 
(DEFSYSFUN 'ASSOC-IF "Lassoc_if" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'GET-PROPERTIES "Lget_properties" '(T T) '* NIL NIL) 
(DEFSYSFUN 'STRING<= "Lstring_le" '(T T *) 'T NIL T) 
(DEFSYSFUN 'EVALHOOK "Levalhook" '(T T T *) 'T NIL NIL) 
(DEFSYSFUN 'FILE-WRITE-DATE "Lfile_write_date" '(T) 'T NIL NIL) 
(DEFSYSFUN 'LOGCOUNT "Llogcount" '(T) 'T NIL NIL) 
(DEFSYSFUN 'MERGE-PATHNAMES "Lmerge_pathnames" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'MEMBER-IF "Lmember_if" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'READ-BYTE "Lread_byte" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'SIMPLE-VECTOR-P "Lsimple_vector_p" '(T) 'T NIL T) 
(DEFSYSFUN 'CHAR-BITS "Lchar_bits" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'COPY-TREE "Lcopy_tree" '(T) 'T NIL NIL) 
(DEFSYSFUN 'GCD "Lgcd" '(*) 'T NIL NIL) 
(DEFSYSFUN 'BYE "Lby" 'NIL 'T NIL NIL) 
;(DEFSYSFUN 'QUIT "Lquit" 'NIL 'T NIL NIL) 
;(DEFSYSFUN 'EXIT "Lexit" 'NIL 'T NIL NIL) 
(DEFSYSFUN 'GET "Lget" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'MOD "Lmod" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'DIGIT-CHAR "Ldigit_char" '(T *) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'PROBE-FILE "Lprobe_file" '(T) 'T NIL NIL) 
(DEFSYSFUN 'STRING-LEFT-TRIM "Lstring_left_trim" '(T T) 'STRING NIL
    NIL) 
(DEFSYSFUN 'PATHNAME-VERSION "Lpathname_version" '(T) 'T NIL NIL) 
(DEFSYSFUN 'WRITE-LINE "Lwrite_line" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'EVAL "Leval" '(T) 'T NIL NIL) 
(DEFSYSFUN 'ATOM "Latom" '(T) 'T NIL T) 
(DEFSYSFUN 'CDDAR "Lcddar" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CDADR "Lcdadr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'CADDR "Lcaddr" '(T) 'T NIL NIL) 
(DEFSYSFUN 'FMAKUNBOUND "Lfmakunbound" '(T) 'T NIL NIL) 
(DEFSYSFUN 'SLEEP "Lsleep" '(T) 'T NIL NIL) 
(DEFSYSFUN 'PACKAGE-NAME "Lpackage_name" '(T) 'T NIL NIL) 
(DEFSYSFUN 'FIND-PACKAGE "Lfind_package" '(T) 'T NIL NIL) 
(DEFSYSFUN 'ASSOC "Lassoc" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'SET-CHAR-BIT "Lset_char_bit" '(T T T) 'CHARACTER NIL NIL) 
(DEFSYSFUN 'FLOOR "Lfloor" '(T *) '(VALUES T T) NIL NIL) 
(DEFSYSFUN 'WRITE "Lwrite" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'PLUSP "Lplusp" '(T) 'T NIL T) 
(DEFSYSFUN 'FLOAT-DIGITS "Lfloat_digits" '(T) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'READ-DELIMITED-LIST "Lread_delimited_list" '(T *) 'T NIL
    NIL) 
(DEFSYSFUN 'APPEND "Lappend" '(*) 'T NIL NIL) 
(DEFSYSFUN 'MEMBER "Lmember" '(T T *) 'T NIL NIL) 
(DEFSYSFUN 'STRING-LESSP "Lstring_lessp" '(T T *) 'T NIL T) 
(DEFSYSFUN 'RANDOM "Lrandom" '(T *) 'T NIL NIL) 
(DEFSYSFUN 'SYSTEM::SPECIALP "siLspecialp" '(T) 'T NIL T) 
(DEFSYSFUN 'SYSTEM::OUTPUT-STREAM-STRING "siLoutput_stream_string" '(T)
    'T NIL NIL) 
;#-clcs (DEFSYSFUN 'SYSTEM::ERROR-SET "siLerror_set" '(T) '* NIL NIL) 
(DEFSYSFUN 'SYSTEM::STRUCTUREP "siLstructurep" '(T) 'T NIL T) 
(DEFSYSFUN 'SYSTEM::COPY-STREAM "siLcopy_stream" '(T T) 'T NIL NIL) 
(DEFSYSFUN 'SYSTEM::INIT-SYSTEM "siLinit_system" 'NIL 'T NIL NIL) 
(DEFSYSFUN 'SYSTEM::STRING-TO-OBJECT "siLstring_to_object" '(T) 'T NIL
    NIL) 
(DEFSYSFUN 'SYSTEM::RESET-STACK-LIMITS "siLreset_stack_limits" 'NIL 'T
    NIL NIL) 
(DEFSYSFUN 'SYSTEM::DISPLACED-ARRAY-P "siLdisplaced_array_p" '(T) 'T NIL
    T) 
(DEFSYSFUN 'SYSTEM::RPLACA-NTHCDR "siLrplaca_nthcdr" NIL T NIL NIL) 
(DEFSYSFUN 'SYSTEM::LIST-NTH "siLlist_nth" NIL T NIL NIL) 
;(DEFSYSFUN 'SYSTEM::MAKE-PURE-ARRAY "siLmake_pure_array" NIL T NIL NIL) 
(DEFSYSFUN 'SYSTEM::MAKE-VECTOR "siLmake_vector" NIL 'VECTOR NIL NIL) 
;(DEFSYSFUN 'SYSTEM::ARRAY-DISPLACEMENT "siLarray_displacement" NIL T NIL NIL) 
(DEFSYSFUN 'SYSTEM::ASET "siLaset" '(ARRAY *) NIL NIL NIL) 
(DEFSYSFUN 'SYSTEM::SVSET "siLsvset" '(SIMPLE-VECTOR FIXNUM T) T NIL
    NIL) 
(DEFSYSFUN 'SYSTEM::FILL-POINTER-SET "siLfill_pointer_set"
    '(VECTOR FIXNUM) 'FIXNUM NIL NIL) 
(DEFSYSFUN 'SYSTEM::REPLACE-ARRAY "siLreplace_array" NIL T NIL NIL) 
(DEFSYSFUN 'SYSTEM::FSET "siLfset" '(SYMBOL T) NIL NIL NIL) 
(DEFSYSFUN 'SYSTEM::HASH-SET "siLhash_set" NIL T NIL NIL) 
(DEFSYSFUN 'BOOLE3 "Lboole" NIL T NIL NIL) 
(DEFSYSFUN 'SYSTEM::PACKAGE-INTERNAL "siLpackage_internal" NIL T NIL
    NIL) 
(DEFSYSFUN 'SYSTEM::PACKAGE-EXTERNAL "siLpackage_external" NIL T NIL
    NIL) 
(DEFSYSFUN 'SYSTEM::ELT-SET "siLelt_set" '(SEQUENCE FIXNUM T) T NIL NIL) 
(DEFSYSFUN 'SYSTEM::CHAR-SET "siLchar_set" '(STRING FIXNUM CHARACTER)
    'CHARACTER NIL NIL) 
(DEFSYSFUN 'SYSTEM::MAKE-STRUCTURE "siLmake_structure" NIL T NIL NIL) 
(DEFSYSFUN 'SYSTEM::STRUCTURE-NAME "siLstructure_name" '(T) 'SYMBOL NIL
    NIL) 
(DEFSYSFUN 'SYSTEM::STRUCTURE-REF "siLstructure_ref" '(T T FIXNUM) T NIL
    NIL) 
(DEFSYSFUN 'SYSTEM::STRUCTURE-SET "siLstructure_set" '(T T FIXNUM T) T
    NIL NIL) 
(DEFSYSFUN 'SYSTEM::PUT-F "siLput_f" NIL '(T T) NIL NIL) 
(DEFSYSFUN 'SYSTEM::REM-F "siLrem_f" NIL '(T T) NIL NIL) 
(DEFSYSFUN 'SYSTEM::SET-SYMBOL-PLIST "siLset_symbol_plist" '(SYMBOL T) T
    NIL NIL) 
(DEFSYSFUN 'SI::BIT-ARRAY-OP "siLbit_array_op" NIL T NIL NIL)





