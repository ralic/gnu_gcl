bool eql1(object, object);
bool equal1(object, object);
bool equalp1(object, object);
bool file_exists(object);
bool integer_bitp(object,object);
double big_to_double(object);
frame_ptr frs_sch_catch(object);
frame_ptr frs_sch(object);
int get_lim_data(void);
int length(object);
int number_compare(object, object);
int number_evenp(object);
int number_minusp(object);
int number_oddp(object);
int number_plusp(object);
int number_zerop(object);
long int fixint(object);
object alloc_object(enum type);
object call_proc_cs2(object,...);
object call_proc_new(object,void **,int,object,va_list);
object coerce_to_string();
object elt();
object fixnum_big_shift(fixnum,fixnum);
object fixnum_times(fixnum,fixnum);
object fSgensym0(void);
object fSgensym1ig(object);
object fSgensym1s(object);
object fSinit_function(object,object,object,object, fixnum,fixnum,fixnum);
object fSsputprop(object,object,object);
object get();
object get_gcd(object, object);
object get_lcm();
object Icall_gen_error_handler(object,object,object,object,ufixnum,...);
object integer_count(object);
object integer_length(object);
object integer_shift(object,object);
object listA(int,...);
object list(int,...);
object log_op2(fixnum,object,object);
object make_complex(object, object);
object make_cons(object, object);
object make_fixnum1(long);
object make_list();
object make_longfloat(longfloat);
object make_shortfloat(double);
object make_simple_string();
object number_abs(object);
object number_divide(object, object);
object number_dpb(object,object,object);
object number_dpf(object,object,object);
object number_ldb(object,object);
object number_ldbt(object,object);
object number_minus(object, object);
object number_negate(object);
object number_plus(object, object);
object number_signum(object);
object number_times(object, object);
object on_stack_cons();
object princ();
object read_char1(object,object);
object structure_ref();
object structure_set();
object symbol_function(object);
object symbol_name();
object symbol_name();
object symbol_value();
object terpri();
object vs_overflow(void);
void bds_overflow(void);
void bds_unwind(bds_ptr);
void do_init(object *);
void frs_overflow(void);
void intdivrem(object,object,fixnum,object *,object *);
void Lsymbol_value(void);
void princ_char(int,object);
void princ_str(char *, object);
void princ_str(char *, object);
void sethash(object,object,object);
void setq(object, object);
void super_funcall_no_event(object);
void system_error(void);
void unwind(frame_ptr, object);
int object_to_int(object);
fixnum object_to_fixnum(object);
char object_to_char(object);
void not_a_symbol(object);
object number_expt(object,object);
object fLrow_major_aref(object,fixnum);
void *alloca(unsigned long);
object car();
object cdr();
object caar();
object cadr();
object cdar();
object cddr();
object caaar();
object caadr();
object cadar();
object caddr();
object cdaar();
object cdadr();
object cddar();
object cdddr();
object caaaar();
object caaadr();
object caadar();
object caaddr();
object cadaar();
object cadadr();
object caddar();
object cadddr();
object cdaaar();
object cdaadr();
object cdadar();
object cdaddr();
object cddaar();
object cddadr();
object cdddar();
object cddddr();
object fcalln1(object,...);
object append();
object aset1(object,fixnum,object);
void call_or_link(object,void **);
object call_proc0(object, void *);
object call_vproc_new(object,void *,object,va_list);
void check_arg_failed (int);
void check_other_key (object,int, ...);
object elt_set();
void FEerror (char *, int, ... );
int feof(void *);
void FEwrong_type_argument(object, object);
void funcall(object);
int getc(void *);
object getf();
struct htent *gethash(object,object);
void invalid_macro_call(void);
long labs(long);
object list_vector_new();
object make_cclosure_new(void (*)(),object,object,object);
object nconc();
object nreverse();
object one_plus();
object one_minus();
object on_stack_list_vector_new(int,object,va_list);
object on_stack_make_list();
void parse_key (object *, bool,bool,int, ... ); 
int parse_key_new_new(int,object *,void *,object,va_list);
int parse_key_rest_new (object,int,object *,void *,object,va_list);
object prin1();
object print();
object putprop();
object remprop();
object reverse();
object simple_symlispcall();
object sputprop();
void symlispcall(object,object *,int);
void too_few_arguments (void);
void too_many_arguments (void);
object wrong_type_argument(object,object);
bool oeql(object,object);
void call_or_link_closure(object,void **,void **);
void check_alist(object);
void lispcall(object *,int);
object make_cclosure(void (*)(),object,object,object,char *,int);
object simple_lispcall(object *,int);
object sublis1();
void turbo_closure (object);
char *object_to_string(object);
int putc(int,void *);
void siLcopy_stream();
long strlen(const char *);
object on_stack_cons();
object on_stack_list(int,...);
object on_stack_list_vector_new(int,object,va_list);
object on_stack_make_list();
int obj_to_mpz(object,MP_INT *);
int obj_to_mpz1(object,MP_INT *,void *);
int mpz_to_mpz(MP_INT *,MP_INT *);
int mpz_to_mpz1(MP_INT *,MP_INT *,void *);
void isetq_fix(MP_INT *,int);
MP_INT * otoi(object x);
object read_byte1();
int not_a_variable(object);
object make_integer();
