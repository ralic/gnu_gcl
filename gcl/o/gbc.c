/*
  Copyright (C) 1994 M. Hagiya, W. Schelter, T. Yuasa
  
  This file is part of GNU Common Lisp, herein referred to as GCL
  
  GCL is free software; you can redistribute it and/or modify it under
  the terms of the GNU LIBRARY GENERAL PUBLIC LICENSE as published by
  the Free Software Foundation; either version 2, or (at your option)
  any later version.
  
  GCL is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public 
  License for more details.
  
  You should have received a copy of the GNU Library General Public License 
  along with GCL; see the file COPYING.  If not, write to the Free Software
  Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
  
*/

/*
  GBC.c
  IMPLEMENTATION-DEPENDENT
*/

#define	DEBUG

#define IN_GBC
#define NEED_MP_H
#include <string.h>
#include <stdlib.h>
#include "include.h"
#include "page.h"


#ifdef SGC
static void
sgc_contblock_sweep_phase(void);

static void
sgc_sweep_phase(void);

static void
sgc_mark_phase(void);

static fixnum
sgc_count_writable(void);

#endif

static void
mark_c_stack(jmp_buf, int, void (*)(void *,void *,int));

static void
mark_contblock(void *, int);

/* the following in line definitions seem to be twice as fast (at
   least on mc68020) as going to the assembly function calls in bitop.c so
   since this is more portable and faster lets use them --W. Schelter
   These assume that DBEGIN is divisible by 32, or else we should have
   #define Shamt(x) (((((int) x -DBEGIN) >> 2) & ~(~0 << 5)))
*/ 
#define LOG_BITS_CHAR 3

#if CPTR_SIZE == 8
#define LOG_BYTES_CONTBLOCK 3
#elif CPTR_SIZE == 16
#define LOG_BYTES_CONTBLOCK 4
#else
#error Do not recognize CPTR_SIZE
#endif

void *
cb_in(void *p) {
  struct contblock **cbpp;
  int i;
  
  for (cbpp=&cb_pointer,i=0;*cbpp;cbpp=&((*cbpp)->cb_link),i++) {
    if ((void *)*cbpp<=p && ((void *)(*cbpp)+(*cbpp)->cb_size) >p)
      return *cbpp;
  }
  return NULL;
}

int
cb_print(void) {
  struct contblock **cbpp;
  int i;
  
  for (cbpp=&cb_pointer,i=0;*cbpp;cbpp=&((*cbpp)->cb_link),i++) {
    fprintf(stderr,"%u at %p\n",(*cbpp)->cb_size,*cbpp);
    fflush(stderr);
  }
  fprintf(stderr,"%u blocks\n",i);
  return 0;
}

#ifdef CONTBLOCK_MARK_DEBUG
int
cb_check(void) {
  struct contblock **cbpp;
  struct pageinfo *v;
  void *cbe;

  for (cbpp=&cb_pointer;*cbpp;cbpp=&((*cbpp)->cb_link)) {
    v=get_pageinfo(*cbpp);
    cbe=((void *)(*cbpp)+(*cbpp)->cb_size-1);
    if (cbe>(void *)v+v->in_use*PAGESIZE)
      return 1;
  }
  return 0;
}

int
m_check(void) {
  struct contblock **cbpp;
  void *v,*ve,*p,*pe;
  extern object malloc_list;
  object l;

  for (l=malloc_list;l!=Cnil;l=l->c.c_cdr) {
    p=l->c.c_car->st.st_self;
    pe=p+l->c.c_car->st.st_dim;
    for (cbpp=&cb_pointer;*cbpp;cbpp=&((*cbpp)->cb_link)) {
      v=(void *)(*cbpp);
      ve=(v+(*cbpp)->cb_size-1);
      printf("%p %p  %p %p\n",p,pe,v,ve);
      if ((v<=p && p < ve)||(v<pe && pe<=ve)) 
	return 1;
    }
  }
  return 0;
}

int
off_check(void *v,void *ve,fixnum i,struct pageinfo *pi) {
  massert(i>=0);
  massert(v+i<(void *)pi+pi->in_use*PAGESIZE);
  massert(i<(ve-v));
  return 0;
}
#endif


inline struct pageinfo *
get_pageinfo(void *x) {
  struct pageinfo *v=contblock_list_head;void *vv;
  for (;(vv=v) && (vv>=x || vv+v->in_use*PAGESIZE<=x);v=v->next);
  return v;
}

inline char
get_bit(char *v,struct pageinfo *pi,void *x) {
  void *ve=CB_DATA_START(pi);
  fixnum off=(x-ve)>>LOG_BYTES_CONTBLOCK,i=off>>LOG_BITS_CHAR,s=off&~(~0UL<<LOG_BITS_CHAR);
#ifdef CONTBLOCK_MARK_DEBUG
  off_check(v,ve,i,pi);
#endif
  return (v[i]>>s)&0x1;
}

inline void
set_bit(char *v,struct pageinfo *pi,void *x) {
  void *ve=CB_DATA_START(pi);
  fixnum off=(x-ve)>>LOG_BYTES_CONTBLOCK,i=off>>LOG_BITS_CHAR,s=off&~(~0UL<<LOG_BITS_CHAR);
#ifdef CONTBLOCK_MARK_DEBUG
  off_check(v,ve,i,pi);
#endif
  v[i]|=(1UL<<s);
}

#define bit_get(v,i,s) ((v[i]>>s)&0x1)
#define bit_set(v,i,s) (v[i]|=(1UL<<s))
#define ptr_get(v,i,s) (v+(((i<<LOG_BITS_CHAR)|s)<<LOG_BYTES_CONTBLOCK))
#define ptr_set(x,v,i,s) ({fixnum _o=(x-v)>>LOG_BYTES_CONTBLOCK;i=_o>>LOG_BITS_CHAR;s=_o&~(~0UL<<LOG_BITS_CHAR);})

inline void
set_bits(char *v,struct pageinfo *pi,void *x1,void *x2) {

  void *ds=CB_DATA_START(pi);
  fixnum i1,s1,i2,s2,se;

  ptr_set(x1,ds,i1,s1);
  ptr_set(x2,ds,i2,s2);

  if (i1==i2) {
    se=s2;
    s2=0;
  } else
    se=CHAR_SIZE;

  for (;s1<se;s1++)
    bit_set(v,i1,s1);
  if (i2>++i1) memset(v+i1,-1,(i2-i1));
  for (;--s2>=0;)
    bit_set(v,i2,s2);

}

inline void *
get_bits(char *v,struct pageinfo *pi,void *x) {

  void *ds=CB_DATA_START(pi),*de=CB_DATA_END(pi);
  fixnum i,s,ie=mbytes(pi->in_use);
  bool z;
  char cz;

  ptr_set(x,ds,i,s);
  z=bit_get(v,i,s);
  cz=z?-1:0;

  for (;++s<CHAR_SIZE && z==bit_get(v,i,s););
  if (s==CHAR_SIZE) {
    for (;++i<ie && v[i]==cz;);
    if (i<ie) for (s=-1;++s<CHAR_SIZE && z==bit_get(v,i,s);); else s=CHAR_SIZE-1;
    /* massert(s<CHAR_SIZE); */
  }
  ds=ptr_get(ds,i,s);

  /* for (;x<ds;x+=sizeof(struct contblock)) */
  /*   massert(z==get_bit(v,pi,x)); */

  return ds<de ? ds : de;
}

inline char
get_mark_bit(struct pageinfo *pi,void *x) {
  return get_bit(CB_MARK_START(pi),pi,x);
}

inline void
set_mark_bit(struct pageinfo *pi,void *x) {
  set_bit(CB_MARK_START(pi),pi,x);
}

inline void *
get_mark_bits(struct pageinfo *pi,void *x) {
  return get_bits(CB_MARK_START(pi),pi,x);
}

inline void
set_mark_bits(struct pageinfo *pi,void *x1,void *x2) {
  set_bits(CB_MARK_START(pi),pi,x1,x2);
}

inline char
get_sgc_bit(struct pageinfo *pi,void *x) {
  return get_bit(CB_SGCF_START(pi),pi,x);
}

inline void
set_sgc_bit(struct pageinfo *pi,void *x) {
  set_bit(CB_SGCF_START(pi),pi,x);
}

inline void *
get_sgc_bits(struct pageinfo *pi,void *x) {
  return get_bits(CB_SGCF_START(pi),pi,x);
}

inline void
set_sgc_bits(struct pageinfo *pi,void *x1,void *x2) {
  set_bits(CB_SGCF_START(pi),pi,x1,x2);
}

#ifdef KCLOVM
void mark_all_stacks();
bool ovm_process_created; 
#endif


static int gc_time = -1;
static int gc_start = 0;
static int gc_recursive = 0;
int runtime(void);
#ifdef SGC
int sgc_enabled=0;
#endif
long  first_protectable_page =0;

static char *copy_relblock(char *p, int s);

long real_maxpage;
long new_holepage;

struct apage {
  char apage_self[PAGESIZE];
};

/* long maxpage; */

object sSAnotify_gbcA;

#ifdef DEBUG
bool debug;
object sSAgbc_messageA;
#endif

#define	MARK_ORIGIN_MAX		300
#define	MARK_ORIGIN_BLOCK_MAX	20

object *mark_origin[MARK_ORIGIN_MAX];
int mark_origin_max;

struct {
  object *mob_addr;	/*  mark origin block address  */
  int	mob_size;	/*  mark origin block size  */
} mark_origin_block[MARK_ORIGIN_BLOCK_MAX];
int mark_origin_block_max;

enum type what_to_collect;

void
enter_mark_origin(object *p) {

  if (mark_origin_max >= MARK_ORIGIN_MAX)
    error("too many mark origins");

  mark_origin[mark_origin_max++] = p;

}

/* Whenever two arrays are linked together by displacement,
   if one is live, the other will be made live */
#define mark_displaced_field(ar) mark_object(ar->a.a_displaced)

#define LINK_ARRAY_MARKED(x_) ((*(unsigned long *)(x_))&0x1)
#define MARK_LINK_ARRAY(x_) ((*(unsigned long *)(x_))|=1UL)
#define CLEAR_LINK_ARRAY(x_) ((*(unsigned long *)(x_))&=~(1UL))

/* #define COLLECT_RELBLOCK_P (what_to_collect == t_relocatable || what_to_collect == t_contiguous) */
bool collect_both=0;

#define COLLECT_RELBLOCK_P (what_to_collect == t_relocatable || collect_both)

static void
mark_link_array(void *v,void *ve) {

  void **p,**pe;

  if (NULL_OR_ON_C_STACK(v))
    return;

  if (sLAlink_arrayA->s.s_dbind==Cnil)
    return;

  p=(void *)sLAlink_arrayA->s.s_dbind->v.v_self;
  pe=(void *)p+sLAlink_arrayA->s.s_dbind->v.v_fillp;

  if (is_marked(sLAlink_arrayA->s.s_dbind) && COLLECT_RELBLOCK_P && (void *)p>=(void *)heap_end) {
    fixnum j=rb_pointer1-rb_pointer;
    p=(void *)p+j;
    pe=(void *)pe+j;
  }

  for (;p<pe;p+=2)
    if (*p>=v && *p<ve) {
      massert(!LINK_ARRAY_MARKED(p));
#ifdef SGC
      if(!sgc_enabled || WRITABLE_PAGE_P(page(p)))
#endif
	MARK_LINK_ARRAY(p);
    }

}

static void
prune_link_array(void) {

  void **p,**pe,**n,**ne;

  if (sLAlink_arrayA->s.s_dbind==Cnil)
    return;

  ne=n=p=(void *)sLAlink_arrayA->s.s_dbind->v.v_self;
  pe=(void *)p+sLAlink_arrayA->s.s_dbind->v.v_fillp;

  while (p<pe) {
    if (*p) {
      *ne++=*p++;
      *ne++=*p++;
    } else
      p+=2;
  }

  sLAlink_arrayA->s.s_dbind->v.v_fillp=(ne-n)*sizeof(*n);

}


static void
sweep_link_array(void) {

  void ***p,***pe;

  if (sLAlink_arrayA->s.s_dbind==Cnil)
    return;

  p=(void *)sLAlink_arrayA->s.s_dbind->v.v_self;
  pe=(void *)p+sLAlink_arrayA->s.s_dbind->v.v_fillp;
  for (;p<pe;p+=2)
    if (*p) {
      if (LINK_ARRAY_MARKED(p))
	CLEAR_LINK_ARRAY(p);
      else {
	**p=p[1];
	*p=0;
      }
    }

  prune_link_array();

}

static inline fixnum
leaf_bytes(fixnum def_type,object x) {

  switch(def_type ? def_type : x->v.v_elttype){
  case aet_lf:
    return sizeof(longfloat)*x->v.v_dim;
  case aet_bit:
#define W_SIZE (8*sizeof(fixnum))
    return sizeof(fixnum)*((BV_OFFSET(x) + x->bv.bv_dim + W_SIZE -1)/W_SIZE);
  case aet_char:
  case aet_uchar:
    return sizeof(char)*x->v.v_dim;
  case aet_short:
  case aet_ushort:
    return sizeof(short)*x->v.v_dim;
  default:
    return sizeof(fixnum)*x->v.v_dim;
  }
}

ufixnum ncbm,nrbm,ngc_thresh;
DEFVAR("*LEAF-COLLECTION*",sSAleaf_collectionA,SI,Cnil,"");

#define MARK_LEAF_DATA(a_,b_,c_) mark_leaf_data(a_,(void **)&b_,c_,1)
#define MARK_LEAF_DATA_ALIGNED(a_,b_,c_,d_) mark_leaf_data(a_,(void **)&b_,c_,d_)

static inline void
mark_leaf_data(object x,void **pp,ufixnum s,ufixnum r) {
  void *p=*pp,*e=heap_end;
  ufixnum rs=(s+(r-1))&(~(r-1));
  object st=sSAleaf_collectionA->s.s_dbind;
  
  if (p<data_start || p<e ? what_to_collect!=t_contiguous : !COLLECT_RELBLOCK_P)
    return;

  if (st!=Cnil && rs<=st->st.st_dim-st->st.st_fillp && x && x->d.st>=ngc_thresh) {
    void *dp=PCEI(st->st.st_self+st->st.st_fillp,r);
    *pp=memcpy(dp,p,s);
    st->st.st_fillp=dp+s-(void *)st->st.st_self;
    x->d.st=0;
    return;
  } 

  if (x) x->d.st++;

  if (p>=e) {
    *pp=(void *)copy_relblock(p,s);
    nrbm+=s+(CEI(nrbm,r)-nrbm);
  } else {
    mark_contblock(p,s);
    ncbm+=s+(CEI(ncbm,r)-ncbm);
  }
}

#define mark_object(x) if (sgc_enabled ? ON_WRITABLE_PAGE(x) : !NULL_OR_ON_C_STACK(x)) mark_object1(x)

static void
mark_object1(object x) {
  
  fixnum i,j=0;/*FIXME*/

  if (is_marked_or_free(x))
    return;

  mark(x);

  switch (type_of(x)) {

  case t_cons:
    mark_object(x->c.c_car);
    mark_object(Scdr(x));/*FIXME*/
    break;

  case t_fixnum:
    break;
    
  case t_bignum:
    MARK_LEAF_DATA(x,MP_SELF(x),MP_ALLOCATED(x)*MP_LIMB_SIZE);
    break;

  case t_ratio:
    mark_object(x->rat.rat_num);
    mark_object(x->rat.rat_den);
    
  case t_shortfloat:
    break;
    
  case t_longfloat:
    break;
    
  case t_complex:
    mark_object(x->cmp.cmp_imag);
    mark_object(x->cmp.cmp_real);
    
  case t_character:
    break;
    
  case t_symbol:
    mark_object(x->s.s_plist);
    mark_object(x->s.s_gfdef);
    mark_object(x->s.s_dbind);
    MARK_LEAF_DATA(x,x->s.s_self,x->s.s_fillp);
    break;
    
  case t_package:
    mark_object(x->p.p_name);
    mark_object(x->p.p_nicknames);
    mark_object(x->p.p_shadowings);
    mark_object(x->p.p_uselist);
    mark_object(x->p.p_usedbylist);
    if (x->p.p_internal)
      for (i=0;i<x->p.p_internal_size;i++)
	mark_object(x->p.p_internal[i]);
    if (x->p.p_external)
      for (i=0;i<x->p.p_external_size;i++)
	mark_object(x->p.p_external[i]);
    MARK_LEAF_DATA(x,x->p.p_internal,x->p.p_internal_size*sizeof(object));
    MARK_LEAF_DATA(x,x->p.p_external,x->p.p_external_size*sizeof(object));
    break;
    
  case t_hashtable:
    mark_object(x->ht.ht_rhsize);
    mark_object(x->ht.ht_rhthresh);
    if (x->ht.ht_self)
      for (i=0;i<x->ht.ht_size;i++) {
	mark_object(x->ht.ht_self[i].hte_key);
	mark_object(x->ht.ht_self[i].hte_value);
      }
    MARK_LEAF_DATA(x,x->ht.ht_self,x->ht.ht_size*sizeof(*x->ht.ht_self));
    break;
    
  case t_array:
    MARK_LEAF_DATA(x,x->a.a_dims,sizeof(int)*x->a.a_rank);

  case t_vector:
  case t_bitvector:

    switch(j ? j : (enum aelttype)x->v.v_elttype) {
#define  ROUND_RB_POINTERS_DOUBLE				\
      {								\
	rb_pointer=PCEI(rb_pointer,sizeof(double));		\
	rb_pointer1=PCEI(rb_pointer1,sizeof(double));		\
      }
    case aet_lf:
      j= sizeof(longfloat)*x->v.v_dim;
      if ((COLLECT_RELBLOCK_P) &&  (void *)x->v.v_self>=(void *)heap_end)
	ROUND_RB_POINTERS_DOUBLE;/*FIXME gc space violation*/
      break;
    case aet_bit:
#define W_SIZE (8*sizeof(fixnum))
      j= sizeof(fixnum)*((BV_OFFSET(x) + x->bv.bv_dim + W_SIZE -1)/W_SIZE);
      break;
    case aet_char:
    case aet_uchar:
      j=sizeof(char)*x->v.v_dim;
      break;
    case aet_short:
    case aet_ushort:
      j=sizeof(short)*x->v.v_dim;
      break;
    case aet_object:
      if (x->v.v_displaced->c.c_car==Cnil && x->v.v_self)
	for (i=0;i<x->v.v_dim;i++)
	  mark_object(x->v.v_self[i]);
    default:
      j=sizeof(fixnum)*x->v.v_dim;
    }

  case t_string:/*FIXME*/
    j=j ? j : x->st.st_dim;

    if (x->v.v_displaced->c.c_car==Cnil) {
      void *p=x->v.v_self;
      MARK_LEAF_DATA(x,x->v.v_self,j);
      if (x->v.v_displaced!=Cnil) {
	j=(void *)x->v.v_self-p;
	x->v.v_self=p;
	adjust_displaced(x,j);
      }
    } 
    mark_object(x->v.v_displaced);
    break;
    
  case t_structure:
    {
      object def=x->str.str_def;
      unsigned char *s_type= &SLOT_TYPE(def,0);
      unsigned short *s_pos= &SLOT_POS(def,0);
      mark_object(x->str.str_def);
      if (x->str.str_self)
	for (i=0,j=S_DATA(def)->length;i<j;i++)
	  if (s_type[i]==0)
	    mark_object(STREF(object,x,s_pos[i]));
      MARK_LEAF_DATA(x,x->str.str_self,S_DATA(def)->size);
    }
    break;
    
  case t_stream:
    switch (x->sm.sm_mode) {
    case smm_input:
    case smm_output:
    case smm_io:
    case smm_socket:  
    case smm_probe:
      mark_object(x->sm.sm_object0);
      mark_object(x->sm.sm_object1);
      if (x->sm.sm_fp) {
	MARK_LEAF_DATA(x,x->sm.sm_buffer,BUFSIZ);
      }
      break;
    
    case smm_synonym:
      mark_object(x->sm.sm_object0);
      break;
      
    case smm_broadcast:
    case smm_concatenated:
      mark_object(x->sm.sm_object0);
      break;
      
    case smm_two_way:
    case smm_echo:
      mark_object(x->sm.sm_object0);
      mark_object(x->sm.sm_object1);
      break;
      
    case smm_string_input:
    case smm_string_output:
      mark_object(x->sm.sm_object0);
      break;
#ifdef USER_DEFINED_STREAMS
    case smm_user_defined:
      mark_object(x->sm.sm_object0);
      mark_object(x->sm.sm_object1);
      break;
#endif
    default:
      error("mark stream botch");
    }
    break;
    
  case t_random:
    MARK_LEAF_DATA_ALIGNED(x,x->rnd.rnd_state._mp_seed->_mp_d,x->rnd.rnd_state._mp_seed->_mp_alloc*MP_LIMB_SIZE,MP_LIMB_SIZE);
    break;
    
  case t_readtable:
    if (x->rt.rt_self)
      for (i=0;i<RTABSIZE;i++) {
	mark_object(x->rt.rt_self[i].rte_macro);
	if (x->rt.rt_self[i].rte_dtab) {
	  for (j=0;j<RTABSIZE;j++)
	    mark_object(x->rt.rt_self[i].rte_dtab[j]);
	  MARK_LEAF_DATA(x,x->rt.rt_self[i].rte_dtab,RTABSIZE*sizeof(object));
	}
      }
    MARK_LEAF_DATA(x,x->rt.rt_self,RTABSIZE*sizeof(struct rtent));
    break;
    
  case t_pathname:
    mark_object(x->pn.pn_host);
    mark_object(x->pn.pn_device);
    mark_object(x->pn.pn_directory);
    mark_object(x->pn.pn_name);
    mark_object(x->pn.pn_type);
    mark_object(x->pn.pn_version);
    break;
    
  case t_closure:
    for (i= 0;i<x->cl.cl_envdim;i++)
      mark_object(x->cl.cl_env[i]);
    MARK_LEAF_DATA(x,x->cl.cl_env,x->cl.cl_envdim*sizeof(object));
    
  case t_cfun:
  case t_sfun:
  case t_vfun:
  case t_afun:
  case t_gfun:	
    mark_object(x->cf.cf_name);
    mark_object(x->cf.cf_data);
    break;
    
  case t_cfdata:
    
    if (x->cfd.cfd_self)
      for (i=0;i<x->cfd.cfd_fillp;i++)
	mark_object(x->cfd.cfd_self[i]);
    if (what_to_collect == t_contiguous)
      mark_link_array(x->cfd.cfd_start,x->cfd.cfd_start+x->cfd.cfd_size);
    MARK_LEAF_DATA(NULL,x->cfd.cfd_start,x->cfd.cfd_size);/*Code cannot move*/
    break;

 case t_cclosure:
    mark_object(x->cc.cc_name);
    mark_object(x->cc.cc_env);
    mark_object(x->cc.cc_data);
    if (x->cc.cc_turbo) {
      x->cc.cc_turbo--;
      for (i=0;i<=fix(x->cc.cc_turbo[0]);i++)
 	mark_object(x->cc.cc_turbo[i]);
      MARK_LEAF_DATA(x,x->cc.cc_turbo,(1+fix(x->cc.cc_turbo[0]))*sizeof(*x->cc.cc_turbo));
      x->cc.cc_turbo++;
    }
    break;
    
  case t_spice:
    break;

 default:
#ifdef DEBUG
    if (debug)
      printf("\ttype = %d\n", type_of(x));
#endif
    error("mark botch");

  }

}

static long *c_stack_where;

void **contblock_stack_list=NULL;

#define PAGEINFO_P(pi) (pi->magic==PAGE_MAGIC && pi->type<=t_contiguous)

static void
mark_stack_carefully(void *topv, void *bottomv, int offset) {

  long pageoffset;
  long p;
  object x;
  struct typemanager *tm;
  register long *j;
  long *top=topv,*bottom=bottomv;
  
  /* if either of these happens we are marking the C stack
     and need to use a local */
  
  if (top==0) top = c_stack_where;
  if (bottom==0) bottom= c_stack_where;
  
  /* On machines which align local pointers on multiple of 2 rather
     than 4 we need to mark twice
  */
  
  if (offset) 
    mark_stack_carefully((((char *) top) +offset),bottom,0);
  
  for (j=top ; j >= bottom ; j--) {
    
    void *v=(void *)(*j),**a;
    struct pageinfo *pi;
    
    if (!VALID_DATA_ADDRESS_P(v)) continue;
    
    if ((p=page(v))<first_data_page) continue;
    
    pageoffset=v-(void *)pagetochar(p);
    pi=pagetoinfo(p);
    if (!PAGEINFO_P(pi)) continue;
    
    for (a=contblock_stack_list;a && a[0]!=pi;a=a[1]);
    if (a) continue;

    tm=tm_of(pi->type);
    if (tm->tm_type>=t_end) continue;

    if (pageoffset<0 || pageoffset>=tm->tm_size*tm->tm_nppage) continue;

    x=(object)(v-pageoffset%tm->tm_size);

    if (is_marked_or_free(x)) continue;

    mark_object(x);

  }

}


static void
mark_phase(void) {

  STATIC fixnum i, j;
  STATIC struct package *pp;
  STATIC bds_ptr bdp;
  STATIC frame_ptr frp;
  STATIC ihs_ptr ihsp;
  
  mark_object(Cnil->s.s_plist);
  mark_object(Ct->s.s_plist);
  
  mark_stack_carefully(vs_top-1,vs_org,0);
  mark_stack_carefully(MVloc+(sizeof(MVloc)/sizeof(object)),MVloc,0);

#ifdef DEBUG
  if (debug) {
    printf("value stack marked\n");
    fflush(stdout);
  }
#endif
  
  for (bdp = bds_org;  bdp<=bds_top;  bdp++) {
    mark_object(bdp->bds_sym);
    mark_object(bdp->bds_val);
  }
  
  for (frp = frs_org;  frp <= frs_top;  frp++)
    mark_object(frp->frs_val);
  
  for (ihsp = ihs_org;  ihsp <= ihs_top;  ihsp++)
    mark_object(ihsp->ihs_function);
  
  for (i = 0;  i < mark_origin_max;  i++)
    mark_object(*mark_origin[i]);
  for (i = 0;  i < mark_origin_block_max;  i++)
    for (j = 0;  j < mark_origin_block[i].mob_size;  j++)
      mark_object(mark_origin_block[i].mob_addr[j]);
  
  for (pp = pack_pointer;  pp != NULL;  pp = pp->p_link)
    mark_object((object)pp);
  
#ifdef DEBUG
  if (debug) {
    printf("symbol navigation\n");
    fflush(stdout);
  }
#endif
  
  /*
    if (what_to_collect != t_symbol &&
    (int)what_to_collect < (int)t_contiguous) {
  */
  
  /* {int size; */
  
  /* for (pp = pack_pointer;  pp != NULL;  pp = pp->p_link) { */
  /*   size = pp->p_internal_size; */
  /*   if (pp->p_internal != NULL) */
  /*     for (i = 0;  i < size;  i++) */
  /* 	mark_object(pp->p_internal[i]); */
  /*   size = pp->p_external_size; */
  /*   if (pp->p_external != NULL) */
  /*     for (i = 0;  i < size;  i++) */
  /* 	mark_object(pp->p_external[i]); */
  /* }} */
  
  /* mark the c stack */
#ifndef N_RECURSION_REQD
#define N_RECURSION_REQD 2
#endif
  mark_c_stack(0,N_RECURSION_REQD,mark_stack_carefully);
  
}

#if defined(__ia64__)
	asm("        .text");
	asm("        .psr abi64");
	asm("        .psr lsb");
	asm("        .lsb");
	asm("");
	asm("        .text");
	asm("        .align 16");
	asm("        .global GC_save_regs_in_stack");
	asm("        .proc GC_save_regs_in_stack");
	asm("GC_save_regs_in_stack:");
	asm("        .body");
	asm("        flushrs");
	asm("        ;;");
	asm("        mov r8=ar.bsp");
	asm("        br.ret.sptk.few rp");
	asm("        .endp GC_save_regs_in_stack");

void * GC_save_regs_in_stack();
#endif

#if defined(__hppa__) /* Courtesy of Lamont Jones */
/* the calling sequence */
struct regs {
	void *callee_saves[16];
};
void hppa_save_regs(struct regs);

/* the code */

	asm(".code");
	asm(".export hppa_save_regs, entry");
	asm(".proc");
	asm(".callinfo");
	asm(".label	hppa_save_regs");
	asm(".entry");

	asm("stw	%r3,0(%arg0)");
	asm("stw	%r4,4(%arg0)");
	asm("stw	%r5,8(%arg0)");
	asm("stw	%r6,12(%arg0)");
	asm("stw	%r7,16(%arg0)");
	asm("stw	%r8,20(%arg0)");
	asm("stw	%r9,24(%arg0)");
	asm("stw	%r10,28(%arg0)");
	asm("stw	%r11,32(%arg0)");
	asm("stw	%r12,36(%arg0)");
	asm("stw	%r13,40(%arg0)");
	asm("stw	%r14,44(%arg0)");
	asm("stw	%r15,48(%arg0)");
	asm("stw	%r16,52(%arg0)");
	asm("stw	%r17,56(%arg0)");
	asm("bv	0(%rp)");
	asm("stw	%r18,60(%arg0)");

	asm(".exit");
	asm(".procend");
	asm(".end");
#endif

static void
mark_c_stack(jmp_buf env1, int n, void (*fn)(void *,void *,int)) {

#if defined(__hppa__)
  struct regs hppa_regs;
#endif
  jmp_buf env;
  int where;
  if (n== N_RECURSION_REQD)
    c_stack_where = (long *) (void *) &env;
  if (n > 0 ) {  
#if defined(__hppa__)
    hppa_save_regs(hppa_regs);
#else    
    setjmp(env);
#endif
    mark_c_stack(env,n - 1,fn);
  } else {
      
    /* If the locals of type object in a C function could be
       aligned other than on multiples of sizeof (char *)
       then define this.  At the moment 2 is the only other
       legitimate value besides 0 */
    
#ifndef C_GC_OFFSET
#define C_GC_OFFSET 0
#endif
    {
      struct pageinfo *v,*tv;void **a;
      fixnum i;
      for (v=contblock_list_head,contblock_stack_list=NULL;v;v=v->next)
	for (i=1;i<v->in_use;i++) {
	  tv=pagetoinfo(page(v)+i);
	  if (PAGEINFO_P(tv)) {
	    a=contblock_stack_list;
	    /* printf("%p\n",tv); */
	    contblock_stack_list=alloca(2*sizeof(a));
	    contblock_stack_list[0]=tv;
	    contblock_stack_list[1]=a;
	  }}

      if (&where > cs_org)
	(*fn)(0,cs_org,C_GC_OFFSET);
      else
	(*fn)(cs_org,0,C_GC_OFFSET);

      contblock_stack_list=NULL;
    }}
  
#if defined(__ia64__)
    {
       extern void * __libc_ia64_register_backing_store_base;
       void * bst=GC_save_regs_in_stack();
       void * bsb=__libc_ia64_register_backing_store_base;

       if (bsb>bst)
          (*fn)(bsb,bst,C_GC_OFFSET);
       else
          (*fn)(bst,bsb,C_GC_OFFSET);
       
    }
#endif

}

static void
sweep_phase(void) {

  STATIC long j, k;
  STATIC object x;
  STATIC char *p;
  STATIC struct typemanager *tm;
  STATIC object f;
  STATIC struct pageinfo *v;
  
  for (v=cell_list_head;v;v=v->next) {

    tm = tm_of((enum type)v->type);
    
    p = pagetochar(page(v));
    f = tm->tm_free;
    k = 0;
    for (j = tm->tm_nppage; j > 0; --j, p += tm->tm_size) {
      x = (object)p;
      if (is_free(x))
	continue;
      else if (is_marked(x)) {
	unmark(x);
	continue;
      }

      SET_LINK(x,f);
      make_free(x);
      f = x;
      k++;
    }
    tm->tm_free = f;
    tm->tm_nfree += k;
    pagetoinfo(page(v))->in_use-=k;
    
  }

}

static void
contblock_sweep_phase(void) {

  STATIC char *s, *e, *p, *q;
  STATIC struct contblock *cbp;
  STATIC struct pageinfo *v;
  
  cb_pointer = NULL;
  ncb = 0;

  for (v=contblock_list_head;v;v=v->next) {
    bool z;

    s=CB_DATA_START(v);
    e=(void *)v+v->in_use*PAGESIZE;

    z=get_mark_bit(v,s);
    for (p=s;p<e;) {
      q=get_bits(CB_MARK_START(v),v,p);
      if (!z)
	insert_contblock(p,q-p);
      z=1-z;
      p=q;
    }

    bzero(CB_MARK_START(v),CB_SGCF_START(v)-CB_MARK_START(v));

  }
#ifdef DEBUG
  if (debug) {
    for (cbp = cb_pointer; cbp != NULL; cbp = cbp->cb_link)
      printf("%d-byte contblock\n", cbp->cb_size);
    fflush(stdout);
  }
#endif
  
  sweep_link_array();

}


int (*GBC_enter_hook)() = NULL;
int (*GBC_exit_hook)() = NULL;

/* void */
/* ttss(void) { */

/*   struct typemanager *tm; */
/*   void *x,*y; */

/*   for (tm=tm_table;tm<tm_table+t_end;tm++) { */

/*     for (x=tm->tm_free;x!=OBJNULL;x=(void *)((struct freelist *)x)->f_link) { */
/*       if (x==Cnil) */
/* 	printf("barr\n"); */
/*       /\* for (y=(void *)((struct freelist *)x)->f_link;y!=OBJNULL && y!=x;y=(void *)((struct freelist *)y)->f_link); *\/ */
/*       /\* if (y==x) *\/ */
/*       /\* 	printf("circle\n"); *\/ */
/*     } */
/*   } */

/* } */

fixnum fault_pages=0;

void
GBC(enum type t) {

  long i,j;
#ifdef DEBUG
  int tm=0;
#endif
  
  BEGIN_NO_INTERRUPT;

  if (t==t_other) {
    collect_both=1;
    t=t_contiguous;
  }
  if (t==t_contiguous)
    ncbm=0;
  if (COLLECT_RELBLOCK_P)
    nrbm=0;

  if (in_signal_handler && t == t_relocatable)
    error("cant gc relocatable in signal handler");
  
  if (GBC_enter_hook != NULL)
    (*GBC_enter_hook)();
  
  if (!GBC_enable)
      error("GBC is not enabled");
  interrupt_enable = FALSE;
  
  if (saving_system) {

    struct pageinfo *v;
    void *x;
    struct typemanager *tm=tm_of(t_stream);
    unsigned j;

    for (v=cell_list_head;v;v=v->next) 
      if (tm->tm_type==v->type)
	for (x=pagetochar(page(v)),j=tm->tm_nppage;j--;x+=tm->tm_size) {
	  object o=x;
	  if (type_of(o)==t_stream && !is_free(o) && o->sm.sm_fp && o->sm.sm_fp!=stdin && o->sm.sm_fp!=stdout)
	    close_stream(o);
	}

    t = t_relocatable; gc_time = -1;
    }


#ifdef DEBUG
  debug = symbol_value(sSAgbc_messageA) != Cnil;
#endif
  
  what_to_collect = t;
  
  tm_table[(int)t].tm_gbccount++;
  tm_table[(int)t].tm_adjgbccnt++;
  
#ifdef DEBUG
  if (debug || (sSAnotify_gbcA->s.s_dbind != Cnil)) {
    
    if (gc_time < 0) gc_time=0;
#ifdef SGC
    printf("[%s for %ld %s pages..",
	   (sgc_enabled ? "SGC" : "GC"),
	   (sgc_enabled ? sgc_count_type(t) : tm_of(t)->tm_npage),
	   (tm_table[(int)t].tm_name)+1);
#else
    printf("[%s for %ld %s pages..",
	   ("GC"),
	   (tm_of(t)->tm_npage),
	   (tm_table[(int)t].tm_name)+1);
#endif
#ifdef SGC
    if(sgc_enabled)
      printf("(%ld faulted pages, %ld writable, %ld read only)..",fault_pages,sgc_count_writable(),
	     (page(core_end)-first_data_page)-(page(rb_start)-page(heap_end))-sgc_count_writable());
#endif	  
    fflush(stdout);
  }
#endif
  if (gc_time >=0 && !gc_recursive++) {gc_start=runtime();}
  
  /* maxpage = page(heap_end); */
  
  if (COLLECT_RELBLOCK_P) {

    i=rb_pointer-rb_start+PAGESIZE;/*FIXME*/

    rb_start = heap_end + PAGESIZE*holepage;
    rb_end   = heap_end + (holepage + nrbpage) *PAGESIZE;
    
    if (rb_start < rb_pointer)
      rb_start1 = (char *)
	((long)(rb_pointer + PAGESIZE-1) & -(unsigned long)PAGESIZE);
    else
      rb_start1 = rb_start;
    
    /* as we walk through marking data, we replace the
       relocatable pointers
       in objects by the rb_pointer, advance that
       by the size, and copy the actual
       data there to rb_pointer1, and advance it by the size
       at the end [rb_start1,rb_pointer1] is copied
       to [rb_start,rb_pointer]
    */
    rb_pointer = rb_start;  /* where the new relblock will start */
    rb_pointer1 = rb_start1;/* where we will copy it to during gc*/
    
    i = (rb_end < (rb_start1 + i) ? (rb_start1 + i) : rb_end) - heap_end;
    alloc_page(-(i + PAGESIZE - 1)/PAGESIZE);
    
  }
  
#ifdef DEBUG
  if (debug) {
    printf("mark phase\n");
    fflush(stdout);
    tm = runtime();
  }
#endif
#ifdef SGC
  if(sgc_enabled)
    sgc_mark_phase();
  else
#endif	
    mark_phase();
#ifdef DEBUG
  if (debug) {
    printf("mark ended (%d)\n", runtime() - tm);
    fflush(stdout);
  }
#endif
  
#ifdef DEBUG
  if (debug) {
    printf("sweep phase\n");
    fflush(stdout);
    tm = runtime();
  }
#endif
#ifdef SGC
  if(sgc_enabled)
    sgc_sweep_phase();
  else
#endif	
    sweep_phase();
#ifdef DEBUG
  if (debug) {
    printf("sweep ended (%d)\n", runtime() - tm);
    fflush(stdout);
  }
#endif
  
  if (COLLECT_RELBLOCK_P) {
    
    /* sSAstatic_promotion_areaA->s.s_dbind=Cnil; */

    if (rb_start < rb_start1) {
      j = (rb_pointer-rb_start + PAGESIZE - 1)/PAGESIZE;
      memmove(rb_start,rb_start1,j*PAGESIZE);
    }
    
#ifdef SGC
    if (sgc_enabled)
      wrimap=(void *)sSAwritableA->s.s_dbind->v.v_self;
#endif

    rb_limit = rb_end - 2*RB_GETA;
    
  }

  if (t == t_contiguous) {
#ifdef DEBUG
    if (debug) {
      printf("contblock sweep phase\n");
      fflush(stdout);
      tm = runtime();
    }
#endif
    
#ifdef SGC
    if (sgc_enabled)
      sgc_contblock_sweep_phase();
    else
#endif
      contblock_sweep_phase();
#ifdef DEBUG
    if (debug)
      printf("contblock sweep ended (%d)\n",
	     runtime() - tm);
#endif
  }
  

/*   { */
/*     static int promoting; */
/*     if (!promoting && promotion_pointer>promotion_pointer1) { */
/*       object *p,st; */
/*       promoting=1; */
/*       st=alloc_simple_string(""); */
/*       for (p=promotion_pointer1;p<promotion_pointer;p++) { */
/* 	fixnum j; */
/* 	object x=*p; */
	
/* 	if (type_of(x)==t_string) */

/*  	  j=x->st.st_dim; */

/* 	else switch (x->v.v_elttype) { */

/* 	  case aet_lf: */
/* 	    j=sizeof(longfloat)*x->v.v_dim; */
/* 	    break; */
/* 	  case aet_bit: */
/* #define W_SIZE (8*sizeof(fixnum)) */
/* 	    j=sizeof(fixnum)*((BV_OFFSET(x) + x->bv.bv_dim + W_SIZE -1)/W_SIZE); */
/* 	    break; */
/* 	  case aet_char: */
/* 	  case aet_uchar: */
/* 	    j=sizeof(char)*x->v.v_dim; */
/* 	    break; */
/* 	  case aet_short: */
/* 	  case aet_ushort: */
/* 	    j=sizeof(short)*x->v.v_dim; */
/* 	    break; */
/* 	  default: */
/* 	    j=sizeof(fixnum)*x->v.v_dim; */
/* 	  } */

/* 	st->st.st_dim=j; */
/* 	st->st.st_self=alloc_contblock(st->st.st_dim); */
/* 	fprintf(stderr,"Promoting vector leaf bytes %lu at %p, %p -> %p\n",j,x,x->v.v_self,st->st.st_self); */
/* 	fflush(stderr); */
/* 	memcpy(st->st.st_self,x->v.v_self,st->st.st_dim); */
/* 	x->v.v_self=(void *)st->st.st_self; */
/*       } */
/*       promoting=0; */
/*     } */
/*   } */
	

#ifdef DEBUG
  if (debug) {
    for (i = 0, j = 0;  i < (int)t_end;  i++) {
      if (tm_table[i].tm_type == (enum type)i) {
	printf("%13s: %8ld used %8ld free %4ld/%ld pages\n",
	       tm_table[i].tm_name,
	       TM_NUSED(tm_table[i]),
	       tm_table[i].tm_nfree,
	       tm_table[i].tm_npage,
	       tm_table[i].tm_maxpage);
	j += tm_table[i].tm_npage;
      } else
	printf("%13s: linked to %s\n",
	       tm_table[i].tm_name,
	       tm_table[(int)tm_table[i].tm_type].tm_name);
    }
    printf("contblock: %ld blocks %ld pages\n", ncb, ncbpage);
    printf("hole: %ld pages\n", holepage);
    printf("relblock: %ld bytes used %ld bytes free %ld pages\n",
	   (long)(rb_pointer - rb_start), (long)(rb_end - rb_pointer), nrbpage);
    printf("GBC ended\n");
    fflush(stdout);
  }
#endif
  
  interrupt_enable = TRUE;
  
  if (GBC_exit_hook != NULL)
    (*GBC_exit_hook)();
  
  if(gc_time>=0 && !--gc_recursive) {gc_time=gc_time+(gc_start=(runtime()-gc_start));}
  
  if (sSAnotify_gbcA->s.s_dbind != Cnil) {
    
    if (gc_recursive)
      fprintf(stdout, "(T=...).GC finished]\n");
    else
      fprintf(stdout, "(T=%d).GC finished]\n",gc_start);
    fflush(stdout);

  }
  
  {
    extern long opt_maxpage(struct typemanager *);

#define IGNORE_MAX_PAGES (sSAignore_maximum_pagesA ==0 || sSAignore_maximum_pagesA->s.s_dbind !=sLnil) 
#define OPTIMIZE_MAX_PAGES (sSAoptimize_maximum_pagesA ==0 || sSAoptimize_maximum_pagesA->s.s_dbind !=sLnil) 

    if (IGNORE_MAX_PAGES && OPTIMIZE_MAX_PAGES)
      opt_maxpage(tm_table+t);
    
  }

  /* {static int mv; */
  /*   if (!mv  && COLLECT_RELBLOCK_P) { */
  /*     mv=1; */
  /*     if (relb_copied) { */
  /* 	sSAstatic_promotion_areaA->s.s_dbind=(VFUN_NARGS=4,fSmake_vector1(make_fixnum(relb_copied),make_fixnum(aet_char),Ct,make_fixnum(0))); */
  /* 	fprintf(stderr,"Making static promotion area %lu bytes\n",relb_copied); */
  /* 	fflush(stderr); */
  /* 	relb_copied=0; */
  /*     } else { */
  /* 	fprintf(stderr,"Releasing static promotion area\n"); */
  /* 	fflush(stderr); */
  /* 	sSAstatic_promotion_areaA->s.s_dbind=Cnil; */
  /*     } */
  /*     mv=0; */
  /*   } */
  /* } */

  collect_both=0;

  END_NO_INTERRUPT;

  CHECK_INTERRUPT;

  /* ttss(); */

}

static void
FFN(siLheap_report)(void) {

  int i;
  
  check_arg(0);
  
  vs_check_push(make_fixnum(sizeof(fixnum)*CHAR_SIZE));
  vs_push(make_fixnum(PAGESIZE));
  vs_push(make_fixnum((ufixnum)data_start));
  vs_push(make_fixnum((ufixnum)data_start+(real_maxpage<<PAGEWIDTH)));
  vs_push(make_fixnum(0));/*SHARED_LIB_HEAP_CEILING*/
  i=sizeof(fixnum)*CHAR_SIZE-2;
  i=1<<i;
  vs_push(make_fixnum(((unsigned long)cs_base+i-1)&-i));
  vs_push(make_fixnum(abs(cs_base-cs_org)));
  vs_push(make_fixnum((CSTACK_DIRECTION+1)>>1));
  vs_push(make_fixnum(CSTACK_ALIGNMENT));
  vs_push(make_fixnum(abs(cs_limit-cs_org)));/*CSSIZE*/
#if defined(IM_FIX_BASE) && defined(IM_FIX_LIM)
#ifdef LOW_IM_FIX
  vs_push(make_fixnum(-LOW_IM_FIX));
  vs_push(make_fixnum(1UL<<LOW_SHFT));
#else
  vs_push(make_fixnum(IM_FIX_BASE));
  vs_push(make_fixnum(IM_FIX_LIM));
#endif
#else  
  vs_push(make_fixnum(0));
  vs_push(make_fixnum(0));
#endif
  vs_push(make_fixnum(phys_pages));

}  

static void
FFN(siLroom_report)(void) {

  int i;
  
  check_arg(0);
  
  vs_check_push(make_fixnum(real_maxpage-first_data_page));
  vs_push(make_fixnum(available_pages));
  vs_push(make_fixnum(ncbpage));
  vs_push(make_fixnum(maxcbpage));
  vs_push(make_fixnum(ncb));
  vs_push(make_fixnum(cbgbccount));
  vs_push(make_fixnum(holepage));
  vs_push(make_fixnum(rb_pointer - rb_start));
  vs_push(make_fixnum(rb_end - rb_pointer));
  vs_push(make_fixnum(nrbpage));
  vs_push(make_fixnum(maxrbpage));
  vs_push(make_fixnum(rbgbccount));
  for (i = 0;  i < (int)t_end;  i++) {
    if (tm_table[i].tm_type == (enum type)i) {
      vs_check_push(make_fixnum(TM_NUSED(tm_table[i])));
      vs_push(make_fixnum(tm_table[i].tm_nfree+tm_table[i].tm_alt_nfree));
      vs_push(make_fixnum(tm_table[i].tm_npage));
      vs_push(make_fixnum(tm_table[i].tm_maxpage));
      vs_push(make_fixnum(tm_table[i].tm_gbccount));
    } else {
      vs_check_push(Cnil);
      vs_push(make_fixnum(tm_table[i].tm_type));
      vs_push(Cnil);
      vs_push(Cnil);
      vs_push(Cnil);
    }
  }
}

static void
FFN(siLreset_gbc_count)(void) {

  int i;
  
  check_arg(0);
  
  for (i = 0;  i < t_other;  i++)
    tm_table[i].tm_gbccount = tm_table[i].tm_adjgbccnt = tm_table[i].tm_opt_maxpage = 0;
}

/* copy S bytes starting at P to beyond rb_pointer1 (temporarily)
   but return a pointer to where this will be copied back to,
   when gc is done.  alignment of rb_pointer is kept at a multiple
   of sizeof(char *);
*/

static char *
copy_relblock(char *p, int s)
{ char *res = rb_pointer;
 char *q = rb_pointer1;
 s = CEI(s,PTR_ALIGN);
 rb_pointer += s;
 rb_pointer1 += s;
 
 memmove(q,p,s);
 /* while (--s >= 0) */
 /*   { *q++ = *p++;} */
 
 return res;
}


static void
mark_contblock(void *p, int s) {

  STATIC char *q;
  STATIC char *x, *y;
  struct pageinfo *v;
  
  if (NULL_OR_ON_C_STACK(p))
    return;

  q = p + s;
  /* SGC cont pages: contblock pages must be no smaller than
     sizeof(struct contblock).  CM 20030827 */
  x = (char *)PFLR(p,CPTR_SIZE);
  y = (char *)PCEI(q,CPTR_SIZE);
  v=get_pageinfo(x);
#ifdef SGC
  if (!sgc_enabled || (v->sgc_flags&SGC_PAGE_FLAG))
#endif
    set_mark_bits(v,x,y);
}

DEFUN_NEW("GBC",object,fLgbc,LISP,1,1,NONE,OO,OO,OO,OO,(object x0),"") {

  /* 1 args */
  
  if (x0 == Ct)
    GBC(t_other);
  else if (x0 == Cnil)
    GBC(t_cons);
  else if (eql(small_fixnum(0),x0))
    GBC(t_contiguous);
  else {
    x0 = small_fixnum(1);
    GBC(t_relocatable);
  }
  RETURN1(x0);
}

static void
FFN(siLgbc_time)(void) {
  if (vs_top>vs_base)
    gc_time=fix(vs_base[0]);
  else {
    vs_base[0]=make_fixnum(gc_time);
    vs_top=vs_base+1;
  }
}

#ifdef SGC
#include "sgbc.c"
#endif

DEFVAR("*NOTIFY-GBC*",sSAnotify_gbcA,SI,Cnil,"");
#ifdef DEBUG
DEFVAR("*GBC-MESSAGE*",sSAgbc_messageA,SI,Cnil,"");
#endif

void
gcl_init_GBC(void) {

  make_si_function("HEAP-REPORT", siLheap_report);
  make_si_function("ROOM-REPORT", siLroom_report);
  make_si_function("RESET-GBC-COUNT", siLreset_gbc_count);
  make_si_function("GBC-TIME",siLgbc_time);
#ifdef SGC
  make_si_function("SGC-ON",siLsgc_on);
#endif

}
