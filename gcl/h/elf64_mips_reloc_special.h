static ul cgp,stub1,stube,gotsym,locgotno,ggot; static Rela *hr;

#undef ELF_R_SYM 
#define ELF_R_SYM(a_) (a_&0xffffffff) 
#undef ELF_R_TYPE 
#define ELF_R_TYPE(a_) (((a_>>40)&0xff) ? ((a_>>40)&0xff) : ((a_>>56)&0xff)) 
#define ELF_R_FTYPE(a_) ((a_>>56)&0xff)

static int
write_stub(ul s,ul *got) {

  int *goti;
  
  s=((int *)s)[3]&MASK(16);
  s+=locgotno-gotsym;
  s*=sizeof(*got);
  s+=ggot-cgp;
  
  goti=(void *)(got+1);
  *got=(ul)goti;
  *goti++=(0x37<<26)|(0x19<<21)|(0x19<<16)|16;
  *goti++=(0x37<<26)|(0x19<<21)|(0x19<<16)|(s&MASK(16));
  *goti++=0x03200008;
  *goti++=0x00200825;
  got=(void *)goti;
  *got=cgp;

  return 0;
  
}

static int
make_got_room_for_stub(Shdr *sec1,Shdr *sece,Sym *sym,const char *st1,ul *gs) {

  Shdr *ssec=sec1+sym->st_shndx;
  struct node *a;
  if ((ssec>=sece || !ALLOC_SEC(ssec)) && 
      (a=find_sym_ptable(st1+sym->st_name)) &&
      a->address>=stub1 && a->address<stube)
    (*gs)+=3;

  return 0;

}

static int
find_special_params(void *v,Shdr *sec1,Shdr *sece,const char *sn,
		    const char *st1,Sym *ds1,Sym *dse,Sym *sym,Sym *syme) {
  
  Shdr *sec;
  ul *q;
  void *p,*pe;

  for (;sym<syme && strcmp("_gp",st1+sym->st_name);sym++);
  massert(sym<syme);
  cgp=sym->st_value;

  massert(sec=get_section(".dynamic",sec1,sece,sn));
  for (p=(void *)sec->sh_addr,pe=p+sec->sh_size;p<pe;p+=sec->sh_entsize) {
    q=p;
    if (q[0]==DT_MIPS_GOTSYM)
      gotsym=q[1];
    if (q[0]==DT_MIPS_LOCAL_GOTNO)
      locgotno=q[1];
    
  }
  massert(gotsym && locgotno);

  massert(sec=get_section(".got",sec1,sece,sn));
  ggot=sec->sh_addr;

  massert(sec=get_section(".MIPS.stubs",sec1,sece,sn));
  stub1=sec->sh_addr;
  stube=stub1+sec->sh_size;
      
  return 0;

}

static int
label_got_symbols(void *v1,Shdr *sec1,Shdr *sece,Sym *sym1,Sym *syme,const char *st1,ul *gs) {

  Rela *r;
  Sym *sym;
  Shdr *sec;
  void *v,*ve;
  ul q=0,a,b;

  for (sym=sym1;sym<syme;sym++)
    sym->st_size=0;

  for (*gs=0,sec=sec1;sec<sece;sec++)
    if (sec->sh_type==SHT_RELA)
      for (v=v1+sec->sh_offset,ve=v+sec->sh_size,r=v;v<ve;v+=sec->sh_entsize,r=v)
	if (ELF_R_TYPE(r->r_info)==R_MIPS_CALL16||
	    ELF_R_TYPE(r->r_info)==R_MIPS_GOT_DISP||
	    ELF_R_TYPE(r->r_info)==R_MIPS_GOT_PAGE) {

	  sym=sym1+ELF_R_SYM(r->r_info);

	  a=r->r_addend>>15;

	  if (a>=sizeof(sym->st_size) || !((sym->st_size>>(a*8))&0xff)) {

	    q=++*gs;
	    if (a<sizeof(sym->st_size)) {
	      massert(q<=0xff);
	      sym->st_size|=(q<<(a*8));
	    }
	    
	    massert(!make_got_room_for_stub(sec1,sece,sym,st1,gs));

	  }

	  b=sizeof(r->r_addend)*4; 
	  massert(!(r->r_addend>>b)); 
	  q=a>=sizeof(sym->st_size) ? q : (sym->st_size>>(a*8))&0xff; 
	  r->r_addend|=(q<<=b); 

	}
  
  return 0;
  
}
